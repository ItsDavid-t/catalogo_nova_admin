import 'package:echo_stock/domain/entities/product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Product entity', () {
    test('normalize marca outOfStock cuando stock es 0', () {
      final product = Product(
        id: 1,
        name: 'Cafe',
        stock: 0,
        imgUrl: 'img.png',
        status: ProductStatus.available,
        createdAt: DateTime.now(),
        costPrice: 10,
        sellPrice: 20,
      );

      final normalized = product.normalize();

      expect(normalized.status, ProductStatus.outOfStock);
    });

    test(
      'normalize restaura available cuando hay stock positivo y estado outOfStock',
      () {
        final product = Product(
          id: 1,
          name: 'Cafe',
          stock: 2,
          imgUrl: 'img.png',
          status: ProductStatus.outOfStock,
          createdAt: DateTime.now(),
          costPrice: 10,
          sellPrice: 20,
        );

        final normalized = product.normalize();

        expect(normalized.status, ProductStatus.available);
      },
    );

    test(
      'isLowStock es verdadero cuando el stock está por debajo del umbral',
      () {
        final product = Product(
          id: 1,
          name: 'Cafe',
          stock: 2,
          lowStockAlert: 5,
          imgUrl: 'img.png',
          status: ProductStatus.available,
          createdAt: DateTime.now(),
          costPrice: 10,
          sellPrice: 20,
        );

        expect(product.isLowStock, isTrue);
      },
    );

    test('toMap incluye shop_id solo si shopId no es nulo', () {
      final product = Product(
        id: 1,
        name: 'Cafe',
        stock: 1,
        imgUrl: 'img.png',
        status: ProductStatus.available,
        createdAt: DateTime.now(),
        costPrice: 10,
        sellPrice: 20,
        shopId: 'shop-123',
      );

      final map = product.toMap();

      expect(map['shop_id'], 'shop-123');
      expect(map.containsKey('shop_id'), isTrue);

      final productWithoutShop = Product(
        id: 2,
        name: 'Cafe sin tienda',
        stock: 1,
        imgUrl: 'img.png',
        status: ProductStatus.available,
        createdAt: DateTime.now(),
        costPrice: 10,
        sellPrice: 20,
      );
      final mapWithoutShop = productWithoutShop.toMap();

      expect(mapWithoutShop.containsKey('shop_id'), isFalse);
    });
  });
}
