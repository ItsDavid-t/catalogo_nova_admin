import 'package:echo_stock/domain/entities/category.dart';
import 'package:flutter/material.dart';

class CategoryList extends StatelessWidget {
  const CategoryList({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    this.isLowStockSelected = false,
    this.onLowStockSelected,
  });

  final List<Category> categories;
  final int? selectedCategoryId;
  final void Function(Category) onCategorySelected;
  final bool isLowStockSelected;
  final VoidCallback? onLowStockSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + (onLowStockSelected != null ? 1 : 0),
        itemBuilder: (context, index) {
          if (onLowStockSelected != null && index == 0) {
            return Padding(
              padding: const EdgeInsets.all(4),
              child: FilterChip(
                avatar: CircleAvatar(
                  backgroundColor: isLowStockSelected
                      ? const Color.fromARGB(255, 46, 62, 74)
                      : Theme.of(context).colorScheme.primary,
                  child: const Icon(
                    Icons.priority_high_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
                showCheckmark: false,
                selected: isLowStockSelected,
                label: const Text('Poco Stock'),
                onSelected: (_) => onLowStockSelected!(),
              ),
            );
          }

          final categoryIndex = onLowStockSelected != null ? index - 1 : index;
          final category = categories[categoryIndex];
          return Padding(
            padding: const EdgeInsets.all(4),
            child: ChoiceChip(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              showCheckmark: false,
              avatar: const Icon(Icons.category_outlined, size: 18),
              selected: category.id == selectedCategoryId,
              label: Text(category.name),
              onSelected: (_) => onCategorySelected(category),
            ),
          );
        },
      ),
    );
  }
}
