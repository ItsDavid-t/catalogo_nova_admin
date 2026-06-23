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
}
