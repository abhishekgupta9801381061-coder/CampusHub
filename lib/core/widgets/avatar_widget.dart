import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AvatarWidget extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final double radius;
  final bool isGhost;

  const AvatarWidget({
    super.key,
    required this.name,
    this.avatarUrl,
    this.radius = 24,
    this.isGhost = false,
  });

  String _getInitials(String fullName) {
    final parts = fullName.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget avatarCore;
    if (isGhost) {
      avatarCore = CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.ghostMode.withOpacity(0.15),
        child: Icon(
          Icons.visibility_off_rounded,
          size: radius * 0.9,
          color: AppColors.ghostMode,
        ),
      );
    } else if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      avatarCore = CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(avatarUrl!),
        backgroundColor: isDark ? AppColors.surfaceDark : const Color(0xFFE2E8F0),
      );
    } else {
      avatarCore = CircleAvatar(
        radius: radius,
        backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        child: Text(
          _getInitials(name),
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.primary,
            fontSize: radius * 0.75,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return avatarCore;
  }
}
