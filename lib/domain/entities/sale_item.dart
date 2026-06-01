class SaleItem {
  final int? id;
  final int saleId;
  final int productId;
  final int quantity;
  final double priceAtSale;

  const SaleItem({
    this.id,
    required this.saleId,
    required this.productId,
    required this.quantity,
    required this.priceAtSale,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_id': saleId,
      'product_id': productId,
      'quantity': quantity,
      'price_at_sale': priceAtSale,
    };
  }

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      id: map['id'] as int?,
      saleId: map['sale_id'] as int,
      productId: map['product_id'] as int,
      quantity: map['quantity'] as int,
      priceAtSale: _toDouble(map['price_at_sale']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}
