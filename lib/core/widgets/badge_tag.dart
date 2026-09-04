import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class BadgeTag extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const BadgeTag({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.fontSize = 11.5,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = backgroundColor ?? (isDark ? const Color(0xFF1E293B) : AppColors.tagBgLight);
    final fg = textColor ?? (isDark ? const Color(0xFF94A3B8) : AppColors.tagTextLight);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: fg,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}
