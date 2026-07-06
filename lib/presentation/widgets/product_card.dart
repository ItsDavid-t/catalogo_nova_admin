import 'package:flutter/material.dart';
import 'package:echo_stock/domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onDelete;
  final bool onReadonly;

  const ProductCard({
    super.key,
    required this.product,
    this.onDelete,
    required this.onReadonly,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (product.status) {
      ProductStatus.available => Colors.green,
      ProductStatus.reserved => Colors.orange,
      ProductStatus.outOfStock => Colors.red,
    };
    final stockColor = product.isEffectivelyOutOfStock
        ? Colors.red
        : product.isLowStock
        ? Colors.orange
        : Colors.grey;

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withAlpha(25), width: 1),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Status indicator
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            // Product info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(30),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          product.normalize().status.displayName,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // Stock
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.inventory_2,
                              size: 13,
                              color: stockColor,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${product.stock}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      // Price
                      Text(
                        '${product.currency} ${product.sellPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if ((product.classification ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.label_outline,
                          size: 12,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            product.classification ?? 'Sin clasificación',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Trailing icon
            if (!onReadonly)
              Icon(
                product.isEffectivelyOutOfStock
                    ? Icons.remove_shopping_cart
                    : product.isLowStock
                    ? Icons.warning
                    : Icons.check_circle,
                size: 18,
                color: product.isEffectivelyOutOfStock
                    ? Colors.red
                    : product.isLowStock
                    ? Colors.orange
                    : statusColor,
              ),
          ],
        ),
      ),
    );
  }
}
