import 'package:echo_stock/domain/entities/sale.dart';
import 'package:echo_stock/domain/entities/profit_loss.dart';

class CalculateProfitLoss {
  CalculateProfitLoss();

  Future<ProfitLoss> call(
    List<Sale> sales, {
    Map<int, double>? productCosts,
    Map<int, String>? productNames,
  }) async {
    final costs = productCosts ?? {};
    final names = productNames ?? {};

    double totalRevenue = 0;
    double totalCost = 0;
    int totalItems = 0;
    //Acumula estadísticas por producto para construir
    // el reporte detallado al finalizar el cálculo
    final Map<int, _MutableProduct> acc = {};

    for (final sale in sales) {
      for (final item in sale.items) {
        final revenue = item.priceAtSale * item.quantity;
        // Se usa el costo guardado en la venta cuando existe
        // Esto evita que cambios porsteriores en el costo del producto
        // alteren los reportes históricos
        final costPerUnit = item.costAtSale > 0
            ? item.costAtSale
            : (costs[item.productId] ?? 0.0);
        final cost = costPerUnit * item.quantity;

        totalRevenue += revenue;
        totalCost += cost;
        totalItems += item.quantity;

        final entry = acc[item.productId] ??= _MutableProduct(
          item.productId,
          names[item.productId],
        );
        entry.quantity += item.quantity;
        entry.revenue += revenue;
        entry.cost += cost;
      }
    }

    final byProduct = <int, ProductProfit>{};
    acc.forEach((pid, mutable) {
      final profit = mutable.revenue - mutable.cost;
      byProduct[pid] = ProductProfit(
        productId: pid,
        productName: mutable.productName,
        quantity: mutable.quantity,
        revenue: mutable.revenue,
        cost: mutable.cost,
        profit: profit,
      );
    });

    final grossProfit = totalRevenue - totalCost;
    //El margen se calcula sobre los ingresos totales
    // Si no hay ingresos entonces se devulve 0 para evitar la división por 0
    final grossMargin = totalRevenue > 0
        ? (grossProfit / totalRevenue) * 100
        : 0.0;

    return ProfitLoss(
      totalRevenue: totalRevenue,
      totalCost: totalCost,
      grossProfit: grossProfit,
      grossMarginPercent: grossMargin,
      totalItemsSold: totalItems,
      salesCount: sales.length,
      byProduct: byProduct,
    );
  }
}

/// Estructura temporal utlizada durante el cálculo
/// Permite acumular cantidades, ingresos y costos
/// antes de generar objetos ProductProfit finales
class _MutableProduct {
  final int productId;
  final String? productName;
  int quantity = 0;
  double revenue = 0.0;
  double cost = 0.0;

  _MutableProduct(this.productId, this.productName);
}
