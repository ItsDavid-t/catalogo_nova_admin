import 'package:echo_stock/domain/entities/sale_item.dart';

class Sale {
  final int? id;
  final String shopId;
  final double totalAmount;
  final String paymentMethod;
  final DateTime createdAt;
  final List<SaleItem> items;

  const Sale({
    this.id,
    required this.shopId,
    required this.totalAmount,
    required this.paymentMethod,
    required this.createdAt,
    this.items = const [],
  });

  Map<String, dynamic> toHeaderMap() {
    return {
      'id': id,
      'shop_id': shopId,
      'total_amount': totalAmount,
      'payment_method': paymentMethod,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    final rawItems = map['sale_item'];
    final items = rawItems is List
        ? rawItems
              .map((e) => SaleItem.fromMap(e as Map<String, dynamic>))
              .toList()
        : <SaleItem>[];

    return Sale(
      id: map['id'] as int?,
      shopId: map['shop_id'] as String,
      totalAmount: _toDouble(map['total_amount']),
      paymentMethod: (map['payment_method'] as String?) ?? 'venta',
      createdAt:
          DateTime.tryParse((map['created_at'] ?? '') as String) ??
          DateTime.now(),
      items: items,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}
