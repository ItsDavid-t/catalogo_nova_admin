import 'package:echo_stock/domain/entities/product.dart';
import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  final int productId;
  final String productName;
  final int quantity;
  final double sellPrice;
  final double costPrice;
  final int availableStock;

  const CartItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.sellPrice,
    required this.costPrice,
    required this.availableStock,
  });

  double get lineTotal => sellPrice * quantity;

  factory CartItem.fromProduct(Product product, {int quantity = 1}) {
    return CartItem(
      productId: product.id!,
      productName: product.name,
      quantity: quantity,
      sellPrice: product.sellPrice,
      costPrice: product.costPrice,
      availableStock: product.stock,
    );
  }

  CartItem copyWith({int? quantity}) {
    return CartItem(
      productId: productId,
      productName: productName,
      quantity: quantity ?? this.quantity,
      sellPrice: sellPrice,
      costPrice: costPrice,
      availableStock: availableStock,
    );
  }

  bool get canIncrement => quantity < availableStock;

  @override
  List<Object?> get props => [
    productId,
    productName,
    quantity,
    sellPrice,
    costPrice,
    availableStock,
  ];
}
