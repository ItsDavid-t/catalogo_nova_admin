import 'package:echo_stock/domain/entities/cart_item.dart';
import 'package:echo_stock/domain/entities/product.dart';
import 'package:echo_stock/domain/entities/sale.dart';
import 'package:echo_stock/domain/entities/sale_item.dart';
import 'package:echo_stock/domain/usecases/finance/build_product_lookup.dart';
import 'package:echo_stock/domain/usecases/finance/calculate_profit_loss.dart';
import 'package:echo_stock/domain/usecases/sale/get_sales_by_shop.dart';
import 'package:echo_stock/domain/usecases/sale/process_sale.dart';
import 'package:echo_stock/presentation/cubit/sale/sale_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SaleCubit extends Cubit<SaleState> {
  static const _defaultPaymentMethod = 'venta';

  final GetSalesByShop _getSalesByShop;
  final ProcessSale _processSale;
  final CalculateProfitLoss _calculateProfitLoss;
  final BuildProductLookup _buildProductLookup;

  final List<CartItem> _cartItems = [];
  double _totalAmount = 0;

  SaleCubit(
    this._getSalesByShop,
    this._processSale,
    this._calculateProfitLoss,
    this._buildProductLookup,
  ) : super(const SaleInitial());

  List<CartItem> get cartItems => List.unmodifiable(_cartItems);
  double get totalAmount => _totalAmount;

  void _emitCart() {
    emit(
      CartUpdated(
        cartItems: List.unmodifiable(_cartItems),
        totalAmount: _totalAmount,
      ),
    );
  }

  Future<void> loadSales(String shopId) async {
    emit(const SaleLoading());
    final result = await _getSalesByShop(shopId);

    result.fold(
      (failure) => emit(SaleFailure(failure.message)),
      (sales) => emit(SaleLoaded(sales)),
    );
  }

  Future<void> calculateFinanceForSales(
    List<Sale> sales, {
    Map<int, double>? productCosts,
    Map<int, String>? productNames,
  }) async {
    emit(const SaleLoading());
    final profitLoss = await _calculateProfitLoss(
      sales,
      productCosts: productCosts,
      productNames: productNames,
    );
    emit(SaleFinanceLoaded(profitLoss));
  }

  void addProductToCart(CartItem item) {
    if (item.availableStock <= 0) {
      emit(const SaleFailure('Producto sin stock disponible'));
      _emitCart();
      return;
    }

    final index = _cartItems.indexWhere(
      (cartItem) => cartItem.productId == item.productId,
    );

    if (index >= 0) {
      final current = _cartItems[index];
      if (!current.canIncrement) {
        emit(
          SaleFailure('Stock máximo alcanzado para "${current.productName}"'),
        );
        _emitCart();
        return;
      }
      _cartItems[index] = current.copyWith(quantity: current.quantity + 1);
    } else {
      _cartItems.add(item);
    }

    _recalculateTotal();
    _emitCart();
  }

  void incrementCartItem(int productId) {
    final index = _cartItems.indexWhere((item) => item.productId == productId);
    if (index < 0) return;

    final current = _cartItems[index];
    if (!current.canIncrement) {
      emit(SaleFailure('Stock máximo alcanzado para "${current.productName}"'));
      _emitCart();
      return;
    }

    _cartItems[index] = current.copyWith(quantity: current.quantity + 1);
    _recalculateTotal();
    _emitCart();
  }

  void decrementCartItem(int productId) {
    final index = _cartItems.indexWhere((item) => item.productId == productId);
    if (index < 0) return;

    final current = _cartItems[index];
    if (current.quantity <= 1) {
      _cartItems.removeAt(index);
    } else {
      _cartItems[index] = current.copyWith(quantity: current.quantity - 1);
    }

    _recalculateTotal();
    _emitCart();
  }

  void removeProductFromCart(int productId) {
    _cartItems.removeWhere((item) => item.productId == productId);
    _recalculateTotal();
    _emitCart();
  }

  void clearCart() {
    _cartItems.clear();
    _totalAmount = 0;
    _emitCart();
  }

  Future<void> confirmSale({required String shopId}) async {
    if (_cartItems.isEmpty) {
      emit(const SaleFailure('El carrito está vacío'));
      _emitCart();
      return;
    }

    emit(const SaleCreating());

    final sale = Sale(
      shopId: shopId,
      totalAmount: _totalAmount,
      paymentMethod: _defaultPaymentMethod,
      createdAt: DateTime.now(),
      items: _cartItems
          .map(
            (item) => SaleItem(
              saleId: 0,
              productId: item.productId,
              quantity: item.quantity,
              priceAtSale: item.sellPrice,
              costAtSale: item.costPrice,
            ),
          )
          .toList(),
    );

    final result = await _processSale(sale);
    result.fold(
      (failure) {
        emit(SaleFailure(failure.message));
        _emitCart();
      },
      (created) {
        _cartItems.clear();
        _totalAmount = 0;
        emit(SaleConfirmed(created, 'Venta registrada correctamente'));
        _emitCart();
      },
    );
  }

  void _recalculateTotal() {
    _totalAmount = _cartItems.fold<double>(
      0.0,
      (sum, item) => sum + item.lineTotal,
    );
  }

  ({Map<int, double> costs, Map<int, String> names}) buildLookupFromProducts(
    List<Product> products,
  ) {
    return _buildProductLookup(products);
  }
}
