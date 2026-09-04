import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/avatar_widget.dart';
import '../../../../core/widgets/badge_tag.dart';
import '../../../achievements/presentation/providers/achievement_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../ghost_mode/presentation/widgets/ghost_mode_toggle_card.dart';
import '../../../groups/presentation/providers/group_providers.dart';
import '../../../social_bridge/presentation/widgets/social_bridge_dialog.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showSocialBridge(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const SocialBridgeDialog(),
    );
  }

  void _showPromotionalConsentDialog(BuildContext context, WidgetRef ref, bool currentConsent) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Promotional Highlights'),
        content: const Text(
          'Allowing promotional visibility means your verified academic and hackathon achievements may be highlighted on the campus hall-of-fame or freshmen milestone banners. Your private details and room number are never revealed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(authNotifierProvider.notifier).updatePromotionalConsent(!currentConsent);
              Navigator.pop(ctx);
            },
            child: Text(!currentConsent ? 'Enable Consent' : 'Revoke Consent'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: AppButton(
            text: 'Log In',
            width: 140,
            onPressed: () => context.go('/auth'),
          ),
        ),
      );
    }

    final myAchievementsAsync = ref.watch(myAchievementsProvider);
    final myGroupsAsync = ref.watch(myGroupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Freshman Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card (strictly omitting room numbers)
            AppCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      AvatarWidget(
                        name: user.name,
                        radius: 34,
                        isGhost: user.isGhostMode,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : AppColors.primary,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user.handle,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accent,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${user.branch} • ${user.hostel}',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Actions row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push('/edit-profile'),
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('Edit Profile', style: TextStyle(fontSize: 13)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showSocialBridge(context),
                          icon: const Icon(Icons.share_rounded, size: 16),
                          label: const Text('Social Bridge', style: TextStyle(fontSize: 13)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Ghost Mode Switch Card
            const GhostModeToggleCard(),
            const SizedBox(height: 16),

            // Promotional Consent Card
            AppCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accentBlue.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.stars_rounded, color: AppColors.accentBlue, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Promotional Consent',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.allowPromotionalConsent
                              ? 'Enabled — Featured on campus boards.'
                              : 'Disabled — Hidden from promotional banners.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: user.allowPromotionalConsent,
                    onChanged: (_) => _showPromotionalConsentDialog(context, ref, user.allowPromotionalConsent),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Skills & Interests
            Text(
              'Skills & Tech Stack',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: user.skills.isEmpty
                  ? [
                      const BadgeTag(text: 'Flutter'),
                      const BadgeTag(text: 'Python'),
                      const BadgeTag(text: 'Dart'),
                      const BadgeTag(text: 'FastAPI'),
                    ]
                  : user.skills.map((s) => BadgeTag(text: s)).toList(),
            ),
            const SizedBox(height: 20),

            // Verified Achievements
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Verified Achievements',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.primary,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/achievements'),
                  child: const Text('View all / Submit', style: TextStyle(fontSize: 12.5)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            myAchievementsAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
              data: (achs) {
                if (achs.isEmpty) {
                  return const Text('No achievements submitted yet.', style: TextStyle(color: AppColors.textSecondaryLight));
                }
                return Column(
                  children: achs.take(2).map((a) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AppCard(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_rounded, color: AppColors.accentBlue, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(a.title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                                  Text(a.description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                                ],
                              ),
                            ),
                            BadgeTag(
                              text: a.status.toUpperCase(),
                              backgroundColor: a.status == 'verified' ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                              textColor: a.status == 'verified' ? const Color(0xFF15803D) : const Color(0xFF92400E),
                              fontSize: 10,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 20),

            // Groups
            Text(
              'My Collaboration Groups',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            myGroupsAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
              data: (groups) {
                if (groups.isEmpty) {
                  return const Text('Not enrolled in any groups yet.', style: TextStyle(color: AppColors.textSecondaryLight));
                }
                return Column(
                  children: groups.map((g) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AppCard(
                        padding: const EdgeInsets.all(12),
                        onTap: () => context.push('/group-detail/${g.id}', extra: g),
                        child: Row(
                          children: [
                            const Icon(Icons.group_work_rounded, color: AppColors.accent, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(g.name, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                            ),
                            Text('${g.memberCount} members', style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
