import 'package:echo_stock/domain/entities/product.dart';

/// Recibe una lista de productos y construye dos mapas para búsquedas rápidas
class BuildProductLookup {
  const BuildProductLookup();

  ({Map<int, double> costs, Map<int, String> names}) call(
    List<Product> products,
  ) {
    final costs = <int, double>{};
    final names = <int, String>{};

    for (final product in products) {
      if (product.id == null) continue;
      costs[product.id!] = product.costPrice;
      names[product.id!] = product.name;
    }

    return (costs: costs, names: names);
  }
}
