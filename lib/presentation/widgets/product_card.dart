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

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.2),
          child: Icon(Icons.inventory_2_outlined, color: statusColor),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estado: ${product.statusLabel}',
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              if ((product.classification ?? '').trim().isNotEmpty)
                Text(
                  'Clasificación: ${product.classification}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
        ),
        trailing: onReadonly ? null : Icon(Icons.circle, size: 14, color: statusColor),
      ),
    );
  }
}
