enum AlertSeverity { info, warning, critical }

enum AlertType { lowStock, outOfStock, negativeMargin, lowMargin }

class AlertRule {
  final AlertType type;
  final String title;
  final String message;
  final AlertSeverity severity;
  final int? productId;

  AlertRule({
    required this.type,
    required this.title,
    required this.message,
    required this.severity,
    this.productId,
  });
}
