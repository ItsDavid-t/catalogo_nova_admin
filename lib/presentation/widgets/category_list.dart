import 'package:echo_stock/domain/entities/category.dart';
import 'package:flutter/material.dart';

class CategoryList extends StatelessWidget {
  const CategoryList({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  final List<Category> categories;
  final int? selectedCategoryId;
  final void Function(Category) onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
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
