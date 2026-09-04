import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../ghost_mode/presentation/widgets/ghost_mode_toggle_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Privacy'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const GhostModeToggleCard(),
          const SizedBox(height: 20),

          // Privacy & Security Section
          Text(
            'Privacy & Safety',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 8),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.shield_outlined, color: AppColors.accentBlue),
                  title: const Text('Campus Privacy Policy', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Zero phone, zero email, zero room number', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('CampusHub Privacy Core'),
                        content: const Text(
                          '1. Phone numbers and emails are never mandatory.\n'
                          '2. Exact room numbers are strictly forbidden and never collected.\n'
                          '3. Account recovery relies exclusively on secret security questions.\n'
                          '4. Ephemeral Social Bridges ensure contacts are only shared with temporary, revocable tokens.\n'
                          '5. Ghost Mode instantly removes you from all student directories.',
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Understood')),
                        ],
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.vpn_key_outlined, color: AppColors.accent),
                  title: const Text('Security Question Recovery', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Self-sovereign account restoration', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                  onTap: () => context.push('/forgot-password'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.block_flipped, color: Colors.orange),
                  title: const Text('Blocked Users', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text('0 blocked classmates', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.flag_outlined, color: AppColors.error),
                  title: const Text('Reported Content & Moderation', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Review submissions you reported', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Preferences
          Text(
            'Preferences',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 8),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications_none_rounded),
                  title: const Text('Push Notifications', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Contest reminders & partner requests', style: TextStyle(fontSize: 12)),
                  trailing: Switch.adaptive(value: true, onChanged: (_) {}),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.star_outline_rounded, color: AppColors.accentBlue),
                  title: const Text('Promotional Featuring Consent', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  trailing: Switch.adaptive(
                    value: user?.allowPromotionalConsent ?? false,
                    onChanged: (val) {
                      ref.read(authNotifierProvider.notifier).updatePromotionalConsent(val);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Logout
          AppCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: const Text('Log Out', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.error)),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Log Out?'),
                    content: const Text('Are you sure you want to log out of CampusHub on this device?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Log Out'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await ref.read(authNotifierProvider.notifier).logout();
                  if (context.mounted) {
                    context.go('/auth');
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
