import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class GhostModeToggleCard extends ConsumerWidget {
  const GhostModeToggleCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGhostMode = ref.watch(isGhostModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      backgroundColor: isGhostMode
          ? (isDark ? const Color(0xFF28183F) : AppColors.ghostModeBg)
          : null,
      borderColor: isGhostMode ? AppColors.ghostMode : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.ghostMode.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.visibility_off_rounded,
                  color: AppColors.ghostMode,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isGhostMode ? 'Ghost Mode is ON' : 'Ghost Mode',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isGhostMode ? AppColors.ghostMode : (isDark ? Colors.white : AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isGhostMode
                          ? "You're currently invisible in Discover."
                          : 'Temporarily hide your profile from search & classmate recommendations.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: isGhostMode,
                activeColor: AppColors.ghostMode,
                onChanged: (val) {
                  ref.read(authNotifierProvider.notifier).toggleGhostMode(val);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
