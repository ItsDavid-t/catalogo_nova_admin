import 'dart:typed_data';

import 'package:echo_stock/domain/core/failures.dart';
import 'package:echo_stock/domain/entities/cart_item.dart';
import 'package:echo_stock/domain/entities/product.dart';
import 'package:echo_stock/domain/entities/sale.dart';
import 'package:echo_stock/domain/repositories/product_repository.dart';
import 'package:echo_stock/domain/repositories/sale_repository.dart';
import 'package:echo_stock/domain/core/filters/sale_filters.dart';
import 'package:echo_stock/domain/usecases/finance/build_finance_insights.dart';
import 'package:echo_stock/domain/usecases/finance/build_product_lookup.dart';
import 'package:echo_stock/domain/usecases/finance/calculate_profit_loss.dart';
import 'package:echo_stock/domain/usecases/alerts/evaluate_alert_rules.dart';
import 'package:echo_stock/domain/usecases/sale/create_sale.dart';
import 'package:echo_stock/domain/usecases/sale/process_sale.dart';
import 'package:echo_stock/domain/usecases/sale/get_sales_by_shop.dart';
import 'package:echo_stock/presentation/cubit/sale/sale_cubit.dart';
import 'package:echo_stock/presentation/cubit/sale/sale_state.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeSaleRepository implements SaleRepository {
  final bool createFails;

  FakeSaleRepository({this.createFails = false});

  @override
  Future<Either<Failure, Sale>> createSale(Sale sale) async {
    if (createFails) {
      return Left(DatabaseFailure('No se pudo crear la venta'));
    }
    return Right(sale.copyWith(id: 100));
  }

  @override
  Future<Either<Failure, List<Sale>>> getSalesByShop(
    String shopId, {
    SalesFilter? filter,
  }) async {
    return const Right([]);
  }
}

class FakeProductRepository implements ProductRepository {
  final Map<int, Product> products;
  final bool decrementFails;

  FakeProductRepository({required this.products, this.decrementFails = false});

  @override
  Future<Either<Failure, Product>> getProductById(int id) async {
    final product = products[id];
    if (product == null) {
      return Left(NotFoundFailure('Producto no encontrado: $id'));
    }
    return Right(product);
  }

  @override
  Future<Either<Failure, Unit>> decrementProductStock(
    int productId,
    int quantity,
  ) async {
    if (decrementFails) {
      return Left(DatabaseFailure('No se pudo decrementar stock'));
    }
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> addProduct(Product product) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> archiveProduct(int id) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> deleteProduct(int id) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> deleteProductImage(String imgUrl) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Product>>> getAllProducts(String? shopId) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Product>>> getOutOfStockProducts() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Product>>> getOutOfStockProductsByCategories(
    int categoryId,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Product>>> getProductsByCategories(
    int categoryId,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Map<String, String>>> uploadProductImage(
    Uint8List bytes,
    String fileName,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> updateProduct(Product product) {
    throw UnimplementedError();
  }
}

SaleCubit createSaleCubit({
  SaleRepository? saleRepository,
  ProductRepository? productRepository,
}) {
  final saleRepo = saleRepository ?? FakeSaleRepository();
  final productRepo =
      productRepository ??
      FakeProductRepository(products: const <int, Product>{});

  final processSale = ProcessSale(
    CreateSale(saleRepo),
    ValidateSaleStock(productRepo),
    DecrementStockForSale(productRepo),
  );

  return SaleCubit(
    GetSalesByShop(saleRepo),
    processSale,
    CalculateProfitLoss(),
    const BuildProductLookup(),
    const BuildFinanceInsights(),
    EvaluateAlertRules(),
  );
}

void main() {
  group('SaleCubit', () {
    test(
      'emite SaleFailure y CartUpdated cuando no hay stock disponible',
      () async {
        final cubit = createSaleCubit();
        final futureStates = cubit.stream.take(2).toList();

        final item = CartItem(
          productId: 1,
          productName: 'Producto sin stock',
          quantity: 1,
          sellPrice: 10.0,
          costPrice: 5.0,
          availableStock: 0,
        );

        cubit.addProductToCart(item);
        final events = await futureStates;

        expect(events, [
          const SaleFailure('Producto sin stock disponible'),
          const CartUpdated(cartItems: [], totalAmount: 0),
        ]);
        expect(cubit.cartItems, isEmpty);
        expect(cubit.totalAmount, 0);

        await cubit.close();
      },
    );

    test(
      'confirmSale con carrito vacío emite SaleFailure y CartUpdated',
      () async {
        final cubit = createSaleCubit();
        final futureStates = cubit.stream.take(2).toList();

        await cubit.confirmSale(shopId: 'shop-1');
        final events = await futureStates;

        expect(events, [
          const SaleFailure('El carrito está vacío'),
          const CartUpdated(cartItems: [], totalAmount: 0),
        ]);
        expect(cubit.cartItems, isEmpty);
        expect(cubit.totalAmount, 0);

        await cubit.close();
      },
    );

    test(
      'confirmSale exitoso limpia el carrito y emite SaleConfirmed',
      () async {
        final saleRepo = FakeSaleRepository();
        final product = Product(
          id: 1,
          name: 'Telefono',
          stock: 5,
          imgUrl: 'img.png',
          status: ProductStatus.available,
          createdAt: DateTime.now(),
          costPrice: 300,
          sellPrice: 4000,
        );
        final productRepo = FakeProductRepository(products: {1: product});

        final cubit = createSaleCubit(
          saleRepository: saleRepo,
          productRepository: productRepo,
        );
        final futureStates = cubit.stream.take(3).toList();

        cubit.addProductToCart(
          CartItem(
            productId: 1,
            productName: 'Telefono',
            quantity: 2,
            sellPrice: 4000,
            costPrice: 300,
            availableStock: 5,
          ),
        );

        await cubit.confirmSale(shopId: 'shop-1');
        final events = await futureStates;

        expect(events[1], isA<SaleCreating>());
        expect(events[2], isA<SaleConfirmed>());
        final confirmed = events[2] as SaleConfirmed;
        expect(confirmed.sale.shopId, 'shop-1');
        expect(confirmed.sale.totalAmount, 8000);
        expect(cubit.cartItems, isEmpty);
        expect(cubit.totalAmount, 0);

        await cubit.close();
      },
    );

    test('clearCart emite estado vacío después de agregar productos', () async {
      final cubit = createSaleCubit();
      final futureStates = cubit.stream.take(2).toList();

      cubit.addProductToCart(
        CartItem(
          productId: 1,
          productName: 'Telefono',
          quantity: 1,
          sellPrice: 100,
          costPrice: 50,
          availableStock: 5,
        ),
      );
      cubit.clearCart();

      final events = await futureStates;
      expect(events.last, const CartUpdated(cartItems: [], totalAmount: 0));
      expect(cubit.cartItems, isEmpty);
      expect(cubit.totalAmount, 0);

      await cubit.close();
    });
  });
}
