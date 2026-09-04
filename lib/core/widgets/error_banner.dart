import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;
  final bool isWarning;

  const ErrorBanner({
    super.key,
    required this.message,
    this.onDismiss,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isWarning ? AppColors.warning : AppColors.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(
            isWarning ? Icons.warning_amber_rounded : Icons.error_outline_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: Icon(
                Icons.close_rounded,
                color: color,
                size: 18,
              ),
            ),
        ],
      ),
    );
  }
}
