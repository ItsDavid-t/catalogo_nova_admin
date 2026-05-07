import 'package:echo_stock/presentation/cubit/product/product_cubit.dart';
import 'package:echo_stock/presentation/cubit/product/product_state.dart';
import 'package:echo_stock/domain/entities/product.dart';
import 'package:echo_stock/presentation/widgets/classification_filter_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductFiltrerPanel extends StatefulWidget {
  const ProductFiltrerPanel({super.key});

  @override
  State<ProductFiltrerPanel> createState() => _ProductFiltrerPanelState();
}

class _ProductFiltrerPanelState extends State<ProductFiltrerPanel> {
  String _getSortOptionText(ProductOption option) {
    switch (option) {
      case ProductOption.nameAz:
        return 'Nombre A-Z';
      case ProductOption.nameZa:
        return 'Nombre Z-A';
      case ProductOption.statusAvailable:
        return 'Disponible primero';
      case ProductOption.statusReserved:
        return 'Reservado primero';
      case ProductOption.statusOutOfStock:
        return 'Sin stock primero';
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final productState = context.watch<ProductCubit>().state;
    if (productState is! ProductLoaded) {
      return const SizedBox.shrink();
    }

    final productLoaded = productState;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Theme(
          data: Theme.of(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Filtros de búsqueda',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Divider(color: Theme.of(context).dividerColor.withAlpha(179)),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: DropdownButtonFormField<ProductOption>(
                    initialValue: productLoaded.sortOption,
                    decoration: const InputDecoration(
                      labelText: 'Ordenar por',
                      border: InputBorder.none,
                    ),
                    items: ProductOption.values.map((option) {
                      return DropdownMenuItem(
                        value: option,
                        child: Text(_getSortOptionText(option)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        context.read<ProductCubit>().changeSortOption(value);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estados',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ProductStatus.values.map((status) {
                          final selected = productLoaded.selectedStatus.contains(
                            status,
                          );
                          return FilterChip(
                            label: Text(status.name),
                            selected: selected,
                            onSelected: (value) {
                              final updateList = List<ProductStatus>.from(
                                productLoaded.selectedStatus,
                              );
                              if (value) {
                                updateList.add(status);
                              } else {
                                updateList.remove(status);
                              }
                              context.read<ProductCubit>().filterByStatus(updateList);
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Clasificaciones',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      productLoaded.products.isNotEmpty
                          ? ClassificationFilterList(
                              tags: productLoaded.products
                                  .map(
                                    (p) =>
                                        (p.classification == null ||
                                            p.classification!.trim().isEmpty)
                                        ? 'sin clasificación'
                                        : p.classification!
                                              .toLowerCase()
                                              .trim(),
                                  )
                                  .toSet()
                                  .toList()
                                  .cast<String>(),
                              selectedClassifications:
                                  productLoaded.selectedClassification,
                              onSelected: (tag, selected) {
                                final updateList = List<String>.from(
                                  productLoaded.selectedClassification,
                                );

                                if (selected) {
                                  updateList.add(tag.toLowerCase().trim());
                                } else {
                                  updateList.remove(tag.toLowerCase().trim());
                                }
                                context
                                    .read<ProductCubit>()
                                    .filterByClassification(updateList);
                              },
                            )
                          : Text(
                              'No hay clasificaciones disponibles',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
