import 'package:flutter/material.dart';

void showAppSnackBar(
  BuildContext context, {
  required String message,
  Color? backgroundColor,
  SnackBarAction? action,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        action: action,
        behavior: SnackBarBehavior.floating,
      ),
    );
}

Widget buildInlineErrorBanner({
  required String message,
  VoidCallback? onRetry,
  String? retryLabel,
  VoidCallback? onSecondaryAction,
  String? secondaryLabel,
}) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.red.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(message, style: const TextStyle(color: Colors.redAccent)),
        if (onRetry != null || onSecondaryAction != null) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              if (onRetry != null)
                TextButton(onPressed: onRetry, child: Text(retryLabel ?? 'Reintentar')),
              if (onSecondaryAction != null)
                TextButton(
                  onPressed: onSecondaryAction,
                  child: Text(secondaryLabel ?? 'Acción'),
                ),
            ],
          ),
        ],
      ],
    ),
  );
}
