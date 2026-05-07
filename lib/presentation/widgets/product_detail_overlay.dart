import 'dart:ui';

import 'package:echo_stock/domain/entities/product.dart';
import 'package:flutter/material.dart';

class ProductDetailOverlay extends StatefulWidget {
  final Product product;
  const ProductDetailOverlay({super.key, required this.product});

  @override
  State<ProductDetailOverlay> createState() => _ProductDetailOverlayState();
}

class _ProductDetailOverlayState extends State<ProductDetailOverlay> {
  @override
  Widget build(BuildContext context) {
    final statusColor = switch (widget.product.status) {
      ProductStatus.available => Colors.green,
      ProductStatus.reserved => Colors.orange,
      ProductStatus.outOfStock => Colors.red,
    };

    return Stack(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.black.withValues(alpha: 0)),
          ),
        ),
        Center(
          child: Container(
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.8),
              boxShadow: [BoxShadow(blurRadius: 10, offset: Offset(0, 5))],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      widget.product.name,
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 16),
                  Divider(
                    color: Theme.of(context).colorScheme.secondary,
                    thickness: 0.5,
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        avatar: Icon(Icons.info_outline, color: statusColor),
                        label: Text(widget.product.statusLabel),
                      ),
                      if (widget.product.categoryId != null)
                        Chip(
                          avatar: const Icon(Icons.category_outlined),
                          label: Text('Categoría #${widget.product.categoryId}'),
                        ),
                    ],
                  ),

                  if (widget.product.classification != null &&
                      widget.product.classification!.isNotEmpty) ...[
                    SizedBox(height: 16),
                    Divider(
                      color: Theme.of(context).colorScheme.secondary,
                      thickness: 0.5,
                    ),
                    SizedBox(height: 12),
                    if (widget.product.classification != null &&
                        widget.product.classification!.isNotEmpty) ...[
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.category, size: 30),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.product.classification.toString(),

                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                    ],

                  ],

                  if (widget.product.description != null) ...[
                    SizedBox(height: 16),
                    Divider(
                      color: Theme.of(context).colorScheme.secondary,
                      thickness: 0.5,
                    ),
                    SizedBox(height: 12),
                    Text(
                      widget.product.description.toString(),
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.justify,
                    ),
                  ],
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FilledButton.icon(
                        onPressed: () => Navigator.pop(context, 'edit'),
                        icon: Icon(Icons.edit),
                        label: Text('Editar'),
                      ),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close),
                        label: Text('Cerrar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
