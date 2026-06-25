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

  test('Cuando le paso una lista vacía', () async {
    // Preparar datos
    final useCase = CalculateProfitLoss();

    // Ejecutar
    final result = await useCase([]);

    // Comprobar
    expect(result.totalRevenue, 0);
    expect(result.totalCost, 0);
    expect(result.grossProfit, 0);
    expect(result.grossMarginPercent, 0);
  });
  test('Calcula multiples ventas', () async {
    final sales = [
      Sale(
        shopId: '1',
        totalAmount: 100,
        paymentMethod: 'cash',
        createdAt: DateTime.now(),
        items: [
          SaleItem(
            saleId: 1,
            productId: 1,
            quantity: 1,
            priceAtSale: 100,
            costAtSale: 50,
          ),
        ],
      ),
      Sale(
        shopId: '1',
        totalAmount: 200,
        paymentMethod: 'cash',
        createdAt: DateTime.now(),
        items: [
          SaleItem(
            saleId: 2,
            productId: 2,
            quantity: 1,
            priceAtSale: 200,
            costAtSale: 100,
          ),
        ],
      ),
    ];

    final result = await CalculateProfitLoss()(sales);

    expect(result.totalRevenue, 300);
    expect(result.totalCost, 150);
    expect(result.grossProfit, 150);
  });

  test('Usa productCosts cuando costAtSale es 0', () async {
    final sales = [
      Sale(
        shopId: '1',
        totalAmount: 100,
        paymentMethod: 'cash',
        createdAt: DateTime.now(),
        items: [
          SaleItem(
            saleId: 1,
            productId: 1,
            quantity: 2,
            priceAtSale: 100,
            costAtSale: 0,
          ),
        ],
      ),
    ];

    final result = await CalculateProfitLoss()(sales, productCosts: {1: 40});

    expect(result.totalRevenue, 200);
    expect(result.totalCost, 80);
    expect(result.grossProfit, 120);
  });
  test('Maneja ventas mixtas', () async {
    final sales = [
      Sale(
        shopId: '1',
        totalAmount: 0,
        paymentMethod: 'cash',
        createdAt: DateTime.now(),
        items: [
          SaleItem(
            saleId: 1,
            productId: 1,
            quantity: 1,
            priceAtSale: 100,
            costAtSale: 50,
          ),
          SaleItem(
            saleId: 1,
            productId: 2,
            quantity: 1,
            priceAtSale: 200,
            costAtSale: 0,
          ),
        ],
      ),
    ];

    final result = await CalculateProfitLoss()(sales, productCosts: {2: 80});

    expect(result.totalRevenue, 300);
    expect(result.totalCost, 130);
    expect(result.grossProfit, 170);
  });
}
