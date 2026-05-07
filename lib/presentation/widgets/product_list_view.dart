import 'package:echo_stock/domain/entities/product.dart';
import 'package:echo_stock/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';

class ProductListView extends StatelessWidget {
  const ProductListView({
    super.key,
    required this.products,
    required this.onRemoveProduct,
    required this.onTapProduct,
    required this.onLongPressProduct,
  });

  final List<Product> products;
  final void Function(Product) onRemoveProduct;
  final void Function(Product) onTapProduct;
  final void Function(Product) onLongPressProduct;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: const ValueKey('home_list'),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Dismissible(
          key: Key(product.id.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.redAccent,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) => onRemoveProduct(product),
          child: InkWell(
            onTap: () => onTapProduct(product),
            onLongPress: () => onLongPressProduct(product),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ProductCard(product: product, onReadonly: false),
            ),
          ),
        );
      },
    );
  }
}
