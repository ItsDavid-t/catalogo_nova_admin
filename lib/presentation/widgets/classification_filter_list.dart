import 'package:flutter/material.dart';

class ClassificationFilterList extends StatelessWidget {
  const ClassificationFilterList({
    super.key,
    required this.tags,
    required this.selectedClassifications,
    required this.onSelected,
    this.selectedColor,
  });

  final List<String> tags;
  final List<String> selectedClassifications;
  final void Function(String, bool) onSelected;
  final Color? selectedColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tags.length,
        itemBuilder: (context, index) {
          final tag = tags[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              selected: selectedClassifications.contains(tag),
              selectedColor: selectedColor,
              label: Text(_capitalize(tag)),
              onSelected: (selected) => onSelected(tag, selected),
            ),
          );
        },
      ),
    );
  }
}

String _capitalize(String text) {
  if (text.isEmpty) return text;
  return '${text[0].toUpperCase()}${text.substring(1)}';
}
