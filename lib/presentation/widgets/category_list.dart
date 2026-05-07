import 'package:echo_stock/domain/entities/category.dart';
import 'package:flutter/material.dart';

class CategoryList extends StatelessWidget {
  const CategoryList({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    required this.onSelected,
    required this.isLowStockSelected,
    required this.isRecycleBin,
  });

  final List<Category> categories;
  final int? selectedCategoryId;
  final void Function(Category) onCategorySelected;
  final bool isLowStockSelected;
  final VoidCallback onSelected;
  final bool isRecycleBin;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.all(4),

              child: FilterChip(
                avatar: CircleAvatar(
                  backgroundColor: isLowStockSelected
                      ? const Color.fromARGB(255, 46, 62, 74)
                      : Theme.of(context).colorScheme.primary,
                  child: isRecycleBin
                      ? Icon(Icons.history, size: 14, color: Colors.white)
                      : Icon(
                          Icons.priority_high_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                ),
                showCheckmark: false,
                selected: isLowStockSelected,
                label: isRecycleBin ? Text('Pocos Días') : Text('Poco Stock'),
                onSelected: (_) => onSelected(),
              ),
            );
          } else {
            final category = categories[index - 1];
            return Padding(
              padding: const EdgeInsets.all(4),
              child: ChoiceChip(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                showCheckmark: false,
                avatar: const Icon(Icons.category_outlined, size: 18),
                selected: category.id == selectedCategoryId,
                label: Text(category.name),
                onSelected: (_) => onCategorySelected(category),
              ),
            );
          }
        },
      ),
    );
  }
}
