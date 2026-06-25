import 'package:echo_stock/domain/entities/sale_item.dart';
import 'package:equatable/equatable.dart';

class Sale extends Equatable {
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
  }) : assert(shopId != ''),
       assert(totalAmount >= 0);

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
    final rawDate = map['created_at'];
    final rawItems = map['sale_item'];
    final items = rawItems is List
        ? rawItems
              .map((e) => SaleItem.fromMap(e as Map<String, dynamic>))
              .toList()
        : <SaleItem>[];

    return Sale(
      id: map['id'] as int?,
      shopId:
          map['shop_id']?.toString() ??
          (throw Exception('shop_id is required')),
      totalAmount: _toDouble(map['total_amount']),
      paymentMethod: (map['payment_method'] as String?) ?? 'venta',
      createdAt: rawDate is String
          ? DateTime.tryParse(rawDate) ?? DateTime.now()
          : rawDate is DateTime
          ? rawDate
          : DateTime.now(),
      items: items,
    );
  }

  Sale copyWith({
    int? id,
    String? shopId,
    double? totalAmount,
    String? paymentMethod,
    DateTime? createdAt,
    List<SaleItem>? items,
  }) {
    return Sale(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  @override
  List<Object?> get props => [
    id,
    shopId,
    totalAmount,
    paymentMethod,
    createdAt,
    items,
  ];
}
