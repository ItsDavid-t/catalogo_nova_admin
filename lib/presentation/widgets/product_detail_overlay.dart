import 'dart:ui';

import 'package:echo_stock/domain/core/di/service_locator.dart';
import 'package:echo_stock/domain/entities/product.dart';
import 'package:echo_stock/domain/usecases/category/get_category_by_id.dart';
import 'package:flutter/material.dart';

class ProductDetailOverlay extends StatefulWidget {
  final Product product;
  final String? categoryName;
  const ProductDetailOverlay({
    super.key,
    required this.product,
    this.categoryName,
  });

  @override
  State<ProductDetailOverlay> createState() => _ProductDetailOverlayState();
}

class _ProductDetailOverlayState extends State<ProductDetailOverlay> {
  String? _categoryName;
  bool _loadingCategory = false;

  @override
  void initState() {
    super.initState();
    _categoryName = widget.categoryName;
    if (widget.product.categoryId != null && _categoryName == null) {
      _loadCategoryName();
    }
  }

  Future<void> _loadCategoryName() async {
    setState(() {
      _loadingCategory = true;
    });

    final result = await sl<GetCategoryById>().call(widget.product.categoryId!);
    result.fold(
      (_) {
        if (!mounted) return;
        setState(() {
          _categoryName = 'Categoría desconocida';
          _loadingCategory = false;
        });
      },
      (category) {
        if (!mounted) return;
        setState(() {
          _categoryName = category.name;
          _loadingCategory = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (widget.product.status) {
      ProductStatus.available => Colors.green,
      ProductStatus.reserved => Colors.orange,
      ProductStatus.outOfStock => Colors.red,
    };

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
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
              padding: EdgeInsets.zero,
              margin: EdgeInsets.all(20),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [BoxShadow(blurRadius: 10, offset: Offset(0, 5))],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagen del producto
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      child: Container(
                        width: double.infinity,
                        height: 250,
                        color: Colors.grey[200],
                        child: widget.product.imgUrl.isNotEmpty
                            ? Image.network(
                                widget.product.imgUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.image_not_supported_outlined,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Imagen no disponible',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              )
                            : Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                    ),
                    // Contenido
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nombre
                          Center(
                            child: Text(
                              widget.product.name,
                              style: Theme.of(context).textTheme.headlineLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 12),
                          Divider(
                            color: Theme.of(context).colorScheme.secondary,
                            thickness: 0.5,
                          ),
                          SizedBox(height: 12),
                          // Estado y categoría
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Chip(
                                avatar: Icon(
                                  Icons.info_outline,
                                  color: statusColor,
                                ),
                                label: Text(
                                  widget.product.normalize().statusLabel,
                                ),
                              ),
                              if (widget.product.categoryId != null)
                                Chip(
                                  avatar: const Icon(Icons.category_outlined),
                                  label: Text(
                                    _categoryName ??
                                        (_loadingCategory
                                            ? 'Cargando categoría...'
                                            : 'Categoría desconocida'),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 12),
                          // Clasificación
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
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
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
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.secondary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: widget.product.isEffectivelyOutOfStock
                                    ? Colors.red.withValues(alpha: 0.4)
                                    : widget.product.isLowStock
                                    ? Colors.orange.withValues(alpha: 0.4)
                                    : Theme.of(context).colorScheme.secondary
                                          .withValues(alpha: 0.3),
                              ),
                            ),
                            padding: EdgeInsets.all(12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Stock:',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                Text(
                                  '${widget.product.stock}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color:
                                            widget
                                                .product
                                                .isEffectivelyOutOfStock
                                            ? Colors.red
                                            : widget.product.isLowStock
                                            ? Colors.orange
                                            : Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          if (widget.product.lowStockAlert > 0) ...[
                            SizedBox(height: 8),
                            Text(
                              'Alerta de stock mínimo: ${widget.product.lowStockAlert}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey),
                            ),
                          ],
                          SizedBox(height: 12),
                          // Precios
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.secondary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.secondary.withValues(alpha: 0.3),
                              ),
                            ),
                            padding: EdgeInsets.all(12),
                            child: Column(
                              children: [
                                if (widget.product.costPrice > 0)
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Precio de Costo:',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                      Text(
                                        '\$${widget.product.costPrice.toStringAsFixed(2)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                            ),
                                      ),
                                    ],
                                  ),
                                if (widget.product.costPrice > 0 &&
                                    widget.product.sellPrice > 0)
                                  SizedBox(height: 8),
                                if (widget.product.sellPrice > 0)
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Precio de Venta:',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                      Text(
                                        '\$${widget.product.sellPrice.toStringAsFixed(2)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                            ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(height: 12),
                          // Descripción
                          if (widget.product.description != null &&
                              (widget.product.description ?? '')
                                  .isNotEmpty) ...[
                            SizedBox(height: 8),
                            Divider(
                              color: Theme.of(context).colorScheme.secondary,
                              thickness: 0.5,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Descripción',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text(
                              widget.product.description.toString(),
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.justify,
                            ),
                          ],
                          SizedBox(height: 24),
                          // Botones
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
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
