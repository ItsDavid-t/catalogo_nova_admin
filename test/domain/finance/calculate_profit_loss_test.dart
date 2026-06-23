import 'package:echo_stock/domain/entities/sale.dart';
import 'package:echo_stock/domain/entities/sale_item.dart';
import 'package:echo_stock/domain/usecases/finance/calculate_profit_loss.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Calcula correctamente ingresos, costos y ganacia', () async {
    // Preparar datos
    final sale = Sale(
      shopId: 'shop1',
      totalAmount: 20000,
      paymentMethod: 'cash',
      createdAt: DateTime.now(),
      items: [
        SaleItem(
          saleId: 1,
          productId: 1,
          quantity: 1,
          priceAtSale: 20000,
          costAtSale: 15000,
        ),
      ],
    );
    final useCase = CalculateProfitLoss();

    // Ejecutar
    final result = await useCase([sale]);

    // Comprobar
    expect(result.totalRevenue, 20000);
    expect(result.totalCost, 15000);
    expect(result.grossProfit, 5000);
    expect(result.grossMarginPercent, 25);
  });
}
