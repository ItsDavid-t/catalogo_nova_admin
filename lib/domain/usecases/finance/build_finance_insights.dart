import 'package:echo_stock/domain/entities/finance_insights.dart';
import 'package:echo_stock/domain/entities/sale.dart';

class BuildFinanceInsights {
  const BuildFinanceInsights();

  Future<List<FinanceInsights>> call(
    List<Sale> sales, {
    Map<int, String>? productNames,
  }) async {
    return _buildInsights(sales, productNames: productNames);
  }

  List<FinanceInsights> _buildInsights(
    List<Sale> sales, {
    Map<int, String>? productNames,
  }) {
    final acc = <int, _Accumulator>{};

    for (final sale in sales) {
      for (final item in sale.items) {
        final current = acc.putIfAbsent(
          item.productId,
          () => _Accumulator(item.productId),
        );

        current.productName =
            productNames?[item.productId] ?? current.productName;
        current.quantity += item.quantity;

        final revenue = item.priceAtSale * item.quantity;
        final cost = item.costAtSale * item.quantity;

        current.revenue += revenue;
        current.cost += cost;
      }
    }

    return acc.values.map((accumulator) {
      final profit = accumulator.revenue - accumulator.cost;
      final marginPercent = accumulator.revenue > 0
          ? (profit / accumulator.revenue) * 100
          : 0.0;

      return FinanceInsights(
        productId: accumulator.productId,
        productName: accumulator.productName,
        quantity: accumulator.quantity,
        revenue: accumulator.revenue,
        cost: accumulator.cost,
        profit: profit,
        marginPercent: marginPercent,
      );
    }).toList();
  }
}

class _Accumulator {
  final int productId;
  String productName = '';
  int quantity = 0;
  double revenue = 0.0;
  double cost = 0.0;

  _Accumulator(this.productId);
}
