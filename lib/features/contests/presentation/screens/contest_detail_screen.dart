import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/badge_tag.dart';
import '../../domain/contest.dart';

class ContestDetailScreen extends StatelessWidget {
  final Contest contest;

  const ContestDetailScreen({super.key, required this.contest});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contest Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BadgeTag(
                    text: contest.mode.toUpperCase(),
                    backgroundColor: AppColors.accent.withOpacity(0.12),
                    textColor: AppColors.accent,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    contest.title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Organized by ${contest.organizer}',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Dates & Prize Info Grid
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          icon: Icons.access_time_rounded,
                          label: 'Registration Deadline',
                          value: DateFormatter.formatShortDate(contest.deadline),
                        ),
                        const Divider(height: 16),
                        _buildInfoRow(
                          icon: Icons.event_rounded,
                          label: 'Event Hack Date',
                          value: DateFormatter.formatShortDate(contest.eventDate),
                        ),
                        const Divider(height: 16),
                        _buildInfoRow(
                          icon: Icons.emoji_events_rounded,
                          label: 'Prize Pool / Rewards',
                          value: contest.prizePool,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    'About this Challenge',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    contest.description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: contest.tags.map((t) => BadgeTag(text: '#$t')).toList(),
                  ),
                  const SizedBox(height: 24),

                  AppButton(
                    text: 'Register / Visit Portal',
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Opening ${contest.registrationUrl} in secure campus web view...'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.accentBlue),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondaryLight),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
