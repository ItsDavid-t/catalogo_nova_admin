import 'package:equatable/equatable.dart';

class SaleItem extends Equatable {
  final int? id;
  final int saleId;
  final int productId;
  final int quantity;
  final double priceAtSale;
  final double costAtSale;

  const SaleItem({
    this.id,
    required this.saleId,
    required this.productId,
    required this.quantity,
    required this.priceAtSale,
    required this.costAtSale,
  }) : assert(saleId > 0),
       assert(productId > 0),
       assert(quantity > 0),
       assert(priceAtSale >= 0),
       assert(costAtSale >= 0);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_id': saleId,
      'product_id': productId,
      'quantity': quantity,
      'price_at_sale': priceAtSale,
      'cost_at_sale': costAtSale,
    };
  }

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      id: map['id'] as int?,
      saleId: map['sale_id'] as int,
      productId: map['product_id'] as int,
      quantity: map['quantity'] as int,
      priceAtSale: _toDouble(map['price_at_sale']),
      costAtSale: _toDouble(map['cost_at_sale']),
    );
  }

  SaleItem copyWith({
    int? id,
    int? saleId,
    int? productId,
    int? quantity,
    double? priceAtSale,
    double? costAtSale,
  }) {
    return SaleItem(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      priceAtSale: priceAtSale ?? this.priceAtSale,
      costAtSale: costAtSale ?? this.costAtSale,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  @override
  List<Object?> get props => [
    id,
    saleId,
    productId,
    quantity,
    priceAtSale,
    costAtSale,
  ];

  double get subtotal => quantity * priceAtSale;
}
