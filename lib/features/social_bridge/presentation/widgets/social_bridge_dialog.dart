import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/social_bridge_providers.dart';

class SocialBridgeDialog extends ConsumerStatefulWidget {
  const SocialBridgeDialog({super.key});

  @override
  ConsumerState<SocialBridgeDialog> createState() => _SocialBridgeDialogState();
}

class _SocialBridgeDialogState extends ConsumerState<SocialBridgeDialog> {
  String _selectedPlatform = 'WhatsApp';
  Duration _selectedDuration = const Duration(hours: 24);
  bool _isGenerating = false;

  final _platforms = ['WhatsApp', 'Instagram', 'Discord'];
  final _durations = [
    const Duration(hours: 1),
    const Duration(hours: 24),
    const Duration(days: 7),
  ];

  String _formatDuration(Duration d) {
    if (d.inDays >= 7) return '7 Days';
    if (d.inHours >= 24) return '24 Hours';
    return '1 Hour';
  }

  Future<void> _generateLink() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isGenerating = true);
    try {
      await ref.read(socialBridgeRepositoryProvider).generateTemporaryLink(
            userId: user.id,
            platform: _selectedPlatform,
            duration: _selectedDuration,
          );
      ref.invalidate(activeSocialBridgeLinksProvider);
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final linksAsync = ref.watch(activeSocialBridgeLinksProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.share_rounded, color: AppColors.accent, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Encrypted Social Bridge',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.socialBridgeNotice,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              // Platform selection
              const Text('Target Platform', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedPlatform,
                isExpanded: true,
                items: _platforms.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedPlatform = val);
                },
              ),
              const SizedBox(height: 14),

              // Expiry selection
              const Text('Link Expiration', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Row(
                children: _durations.map((d) {
                  final isSelected = _selectedDuration == d;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: OutlinedButton(
                        onPressed: () => setState(() => _selectedDuration = d),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: isSelected
                              ? (isDark ? Colors.white : AppColors.primary)
                              : Colors.transparent,
                          foregroundColor: isSelected
                              ? (isDark ? AppColors.primary : Colors.white)
                              : (isDark ? Colors.white : AppColors.primary),
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 38),
                        ),
                        child: Text(_formatDuration(d), style: const TextStyle(fontSize: 12)),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              AppButton(
                text: 'Generate Ephemeral Link',
                isLoading: _isGenerating,
                onPressed: _generateLink,
              ),
              const SizedBox(height: 20),

              const Divider(),
              const SizedBox(height: 10),
              const Text(
                'Active Ephemeral Links',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),

              linksAsync.when(
                loading: () => const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator())),
                error: (e, _) => Text('Error: $e'),
                data: (links) {
                  if (links.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No active temporary links. Generate one when sharing contacts with classmates.',
                        style: TextStyle(fontSize: 12.5, color: AppColors.textSecondaryLight),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: links.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final l = links[index];
                      return AppCard(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            Icon(
                              l.platform == 'WhatsApp'
                                  ? Icons.phone_android_rounded
                                  : Icons.alternate_email_rounded,
                              size: 16,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${l.platform} Link', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                  Text(
                                    l.shareUrl,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy_rounded, size: 16),
                              tooltip: 'Copy',
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: l.shareUrl));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Temporary link copied!'), behavior: SnackBarBehavior.floating),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.link_off_rounded, size: 16, color: AppColors.error),
                              tooltip: 'Revoke Now',
                              onPressed: () async {
                                await ref.read(socialBridgeRepositoryProvider).revokeLink(l.id);
                                ref.invalidate(activeSocialBridgeLinksProvider);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
