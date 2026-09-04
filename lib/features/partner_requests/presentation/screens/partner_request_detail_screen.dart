import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/avatar_widget.dart';
import '../../../../core/widgets/badge_tag.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/partner_request.dart';
import '../providers/partner_request_providers.dart';

class PartnerRequestDetailScreen extends ConsumerWidget {
  final String requestId;
  final PartnerRequest? initialRequest;

  const PartnerRequestDetailScreen({
    super.key,
    required this.requestId,
    this.initialRequest,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final req = initialRequest;

    if (req == null) {
      return const Scaffold(
        body: Center(child: Text('Partner request details')),
      );
    }

    final isOwner = user != null && user.id == req.authorId;
    final countdown = DateFormatter.formatExpiryCountdown(req.expiryDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Overview'),
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
              tooltip: 'Delete Request',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Request?'),
                    content: const Text('You can delete your partner request at any time.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirm == true && user != null) {
                  await ref.read(partnerRequestRepositoryProvider).deleteRequest(
                        requestId: req.id,
                        userId: user.id,
                      );
                  ref.invalidate(activePartnerRequestsProvider);
                  ref.invalidate(myPartnerRequestsProvider);
                  ref.invalidate(canCreatePartnerRequestTodayProvider);
                  if (context.mounted) {
                    context.pop();
                  }
                }
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.flag_outlined),
              tooltip: 'Report Request',
              onPressed: () {
                ref.read(partnerRequestRepositoryProvider).reportRequest(req.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Request reported for moderation review.'), behavior: SnackBarBehavior.floating),
                );
              },
            ),
        ],
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
                  Row(
                    children: [
                      AvatarWidget(name: req.authorName, radius: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              req.authorName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : AppColors.primary,
                              ),
                            ),
                            Text(
                              '${req.authorHandle} • ${req.authorHostel}',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          countdown,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.accent),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  BadgeTag(text: req.type, icon: Icons.lightbulb_outline_rounded),
                  const SizedBox(height: 12),
                  Text(
                    req.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.primary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    req.description,
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.5,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: req.tags.map((t) => BadgeTag(text: '#$t')).toList(),
                  ),
                  const SizedBox(height: 20),
                  if (req.editCount > 0)
                    Text(
                      'Edited ${req.editCount} of 3 times today',
                      style: TextStyle(fontSize: 11.5, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                    ),
                  const SizedBox(height: 12),

                  if (!isOwner)
                    AppButton(
                      text: 'Connect Safely with Author',
                      icon: const Icon(Icons.send_rounded, size: 18),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Safe connection message sent to ${req.authorHandle}!'),
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
}
