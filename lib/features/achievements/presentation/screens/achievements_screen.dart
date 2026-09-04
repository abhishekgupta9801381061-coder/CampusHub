import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/badge_tag.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/achievement_providers.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  void _showSubmitDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _SubmitAchievementSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(myAchievementsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verified Achievements'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: isDark ? Colors.white : AppColors.primary,
        foregroundColor: isDark ? AppColors.primary : Colors.white,
        icon: const Icon(Icons.upload_file_rounded),
        label: const Text('Submit Achievement', style: TextStyle(fontWeight: FontWeight.w600)),
        onPressed: () => _showSubmitDialog(context, ref),
      ),
      body: achievementsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (list) {
          if (list.isEmpty) {
            return EmptyStateView(
              icon: Icons.military_tech_outlined,
              title: 'No Achievements Yet',
              description: 'Submit your hackathon ranking, certification, or project proof for verified campus badges.',
              actionText: 'Submit Achievement',
              onAction: () => _showSubmitDialog(context, ref),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myAchievementsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final a = list[index];
                final isVerified = a.status == 'verified';

                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          BadgeTag(text: a.category),
                          const Spacer(),
                          BadgeTag(
                            text: a.status.toUpperCase(),
                            backgroundColor: isVerified ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                            textColor: isVerified ? const Color(0xFF15803D) : const Color(0xFF92400E),
                            icon: isVerified ? Icons.verified_rounded : Icons.pending_outlined,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        a.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        a.description,
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.4,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Submitted: ${DateFormatter.formatShortDate(a.createdAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _SubmitAchievementSheet extends ConsumerStatefulWidget {
  const _SubmitAchievementSheet();

  @override
  ConsumerState<_SubmitAchievementSheet> createState() => _SubmitAchievementSheetState();
}

class _SubmitAchievementSheetState extends ConsumerState<_SubmitAchievementSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  String _category = 'Hackathon';
  bool _isLoading = false;

  final _categories = ['Hackathon', 'Certificate', 'Competition', 'Project'];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(achievementRepositoryProvider);
      // Simulate signed URL acquisition
      final signedUrl = await repo.getSignedUploadUrl('cert_${DateTime.now().millisecondsSinceEpoch}.pdf');

      await repo.submitAchievement(
        userId: user.id,
        title: _titleController.text,
        description: _descController.text,
        category: _category,
        proofUrl: signedUrl,
      );

      ref.invalidate(myAchievementsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Achievement submitted for verification review!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Submit Achievement Proof',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),

            DropdownButtonFormField<String>(
              value: _category,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Category'),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _category = val);
              },
            ),
            const SizedBox(height: 14),

            AppTextField(
              label: 'Achievement Title',
              hintText: 'e.g. 1st Place - SIH Internal Round',
              controller: _titleController,
              isRequired: true,
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 14),

            AppTextField(
              label: 'Markdown Description / Team Details',
              hintText: 'Explain team members, track, project GitHub repo...',
              controller: _descController,
              maxLines: 3,
              isRequired: true,
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 20),

            AppButton(
              text: 'Submit for Verification',
              isLoading: _isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
