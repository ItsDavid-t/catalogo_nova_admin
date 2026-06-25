import 'package:echo_stock/domain/entities/product.dart';
import 'package:echo_stock/domain/usecases/finance/build_product_lookup.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Crea correctamente los mapas para busquedas rápidas', () {
    //Preparar datos
    final products = [
      Product(
        id: 1,
        name: "Telefono",
        stock: 4,
        imgUrl: " ",
        status: ProductStatus.available,
        createdAt: DateTime.now(),
        costPrice: 300,
        sellPrice: 4000,
      ),
    ];

    final useCase = BuildProductLookup();

    // Ejecutar
    final result = useCase(products);

    //Comprobar
    expect(result.names[1], 'Telefono');
    expect(result.costs[1], 300);
  });

  test('Solo agrega  productos con id valido', () {
    //Preparar datos
    final products = [
      Product(
        id: 1,
        name: "Telefono",
        stock: 4,
        imgUrl: " ",
        status: ProductStatus.available,
        createdAt: DateTime.now(),
        costPrice: 300,
        sellPrice: 4000,
      ),
      Product(
        id: null,
        name: "Lapotop",
        stock: 2,
        imgUrl: ' ',
        status: ProductStatus.available,
        createdAt: DateTime.now(),
        costPrice: 500,
        sellPrice: 6000,
      ),
    ];

    final useCase = BuildProductLookup();

    // Ejecutar
    final result = useCase(products);

    //Comprobar
    expect(result.names.length, 1);
    expect(result.costs.length, 1);

    expect(result.names[1], 'Telefono');
    expect(result.costs[1], 300);
  });

  test("Me retorna mapa vacíos cuando la lista este vacía", () {
    //Preparar datos
    final products = <Product>[];

    final useCase = BuildProductLookup();

    // Ejecutar
    final result = useCase(products);

    //Comprobar
    expect(result.names, isEmpty);
    expect(result.costs, isEmpty);
  });
  test('Construye correctamente lookup con multiples productos', () {
    final products = [
      Product(
        id: 1,
        name: 'Telefono',
        stock: 4,
        imgUrl: '',
        status: ProductStatus.available,
        createdAt: DateTime.now(),
        costPrice: 300,
        sellPrice: 4000,
      ),
      Product(
        id: 2,
        name: 'Laptop',
        stock: 2,
        imgUrl: '',
        status: ProductStatus.available,
        createdAt: DateTime.now(),
        costPrice: 500,
        sellPrice: 6000,
      ),
    ];

    final useCase = BuildProductLookup();

    final result = useCase(products);

    expect(result.names.length, 2);
    expect(result.costs.length, 2);

    expect(result.names[1], 'Telefono');
    expect(result.names[2], 'Laptop');

    expect(result.costs[1], 300);
    expect(result.costs[2], 500);
  });
}
