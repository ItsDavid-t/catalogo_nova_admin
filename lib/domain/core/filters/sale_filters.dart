enum SalesTimeFilterType { day, month, year, custom }

class SalesFilter {
  final SalesTimeFilterType type;
  final DateTime? from;
  final DateTime? to;

  const SalesFilter({required this.type, this.from, this.to});

  factory SalesFilter.day(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return SalesFilter(type: SalesTimeFilterType.day, from: start, to: end);
  }

  factory SalesFilter.month(DateTime date) {
    final start = DateTime(date.year, date.month, 1);
    final end = DateTime(date.year, date.month + 1, 1);
    return SalesFilter(type: SalesTimeFilterType.month, from: start, to: end);
  }

  factory SalesFilter.year(DateTime date) {
    final start = DateTime(date.year, 1, 1);
    final end = DateTime(date.year + 1, 1, 1);
    return SalesFilter(type: SalesTimeFilterType.year, from: start, to: end);
  }

  factory SalesFilter.custom(DateTime from, DateTime to) {
    return SalesFilter(type: SalesTimeFilterType.custom, from: from, to: to);
  }
}
