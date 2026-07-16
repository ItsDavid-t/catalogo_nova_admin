import 'package:echo_stock/domain/entities/alert_rule.dart';
import 'package:echo_stock/domain/entities/product.dart';
import 'package:echo_stock/domain/entities/sale.dart';
import 'package:echo_stock/domain/usecases/finance/build_finance_insights.dart';
import 'package:echo_stock/domain/entities/finance_insights.dart';

class EvaluateAlertRules {
  const EvaluateAlertRules();

  Future<List<AlertRule>> call({
    required List<Product> products,
    required List<Sale> sales,
    Map<int, String>? productNames,
  }) async {
    return await _buildAlerts(products, sales, productNames: productNames);
  }

  Future<List<AlertRule>> _buildAlerts(
    List<Product> products,
    List<Sale> sales, {
    Map<int, String>? productNames,
  }) async {
    final alerts = <AlertRule>[];

    final insights = await const BuildFinanceInsights().call(
      sales,
      productNames: productNames,
    );

    const double lowMarginThreshold = 15.0;

    for (final product in products) {
      final id = product.id;
      final name = id != null
          ? (productNames?[id] ?? product.name)
          : product.name;

      if (product.stock <= 0) {
        alerts.add(
          AlertRule(
            type: AlertType.outOfStock,
            title: 'Producto agotado',
            message: '$name está agotado.',
            severity: AlertSeverity.critical,
            productId: id,
          ),
        );
        continue;
      }

      if (product.lowStockAlert > 0 && product.stock < product.lowStockAlert) {
        alerts.add(
          AlertRule(
            type: AlertType.lowStock,
            title: 'Existencias bajas',
            message: '$name tiene pocas existencias (${product.stock}).',
            severity: AlertSeverity.warning,
            productId: id,
          ),
        );
      }

      if (id != null) {
        final insight = insights.firstWhere(
          (i) => i.productId == id,
          orElse: () => FinanceInsights(
            productId: id,
            productName: name,
            quantity: 0,
            revenue: 0,
            cost: 0,
            profit: 0,
            marginPercent: 0,
          ),
        );

        if (insight.profit < 0) {
          alerts.add(
            AlertRule(
              type: AlertType.negativeMargin,
              title: 'Margen negativo',
              message:
                  '$name está generando pérdidas (\$${insight.profit.toStringAsFixed(2)}).',
              severity: AlertSeverity.critical,
              productId: id,
            ),
          );
        } else if (insight.marginPercent > 0 &&
            insight.marginPercent < lowMarginThreshold) {
          alerts.add(
            AlertRule(
              type: AlertType.lowMargin,
              title: 'Margen bajo',
              message:
                  '$name tiene margen bajo (${insight.marginPercent.toStringAsFixed(1)}%).',
              severity: AlertSeverity.warning,
              productId: id,
            ),
          );
        }
      }
    }

    return alerts;
  }
}
