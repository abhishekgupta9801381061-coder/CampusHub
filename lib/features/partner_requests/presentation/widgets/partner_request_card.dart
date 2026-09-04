import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/avatar_widget.dart';
import '../../../../core/widgets/badge_tag.dart';
import '../../domain/partner_request.dart';

class PartnerRequestCard extends StatelessWidget {
  final PartnerRequest request;
  final VoidCallback? onTap;
  final VoidCallback? onContact;

  const PartnerRequestCard({
    super.key,
    required this.request,
    this.onTap,
    this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final countdown = DateFormatter.formatExpiryCountdown(request.expiryDate);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Author & Expiry Countdown Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AvatarWidget(
                name: request.authorName,
                radius: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.authorName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.primary,
                      ),
                    ),
                    Text(
                      '${request.authorHandle} • ${request.authorHostel}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              // Countdown Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_outlined, size: 12, color: AppColors.accent),
                    const SizedBox(width: 4),
                    Text(
                      countdown,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Request Type Badge
          BadgeTag(
            text: request.type,
            backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
            textColor: AppColors.accentBlue,
            icon: Icons.lightbulb_outline_rounded,
          ),
          const SizedBox(height: 8),

          // Title
          Text(
            request.title,
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.primary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),

          // Description
          Text(
            request.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.4,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 12),

          // Tags & Safe Connect Button
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: request.tags
                      .map(
                        (tag) => BadgeTag(
                          text: '#$tag',
                          fontSize: 11,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        ),
                      )
                      .toList(),
                ),
              ),
              if (onContact != null)
                TextButton.icon(
                  onPressed: onContact,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.send_rounded, size: 14),
                  label: const Text('Connect', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
