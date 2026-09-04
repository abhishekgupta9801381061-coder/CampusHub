import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/partner_request_providers.dart';

class CreatePartnerRequestScreen extends ConsumerStatefulWidget {
  const CreatePartnerRequestScreen({super.key});

  @override
  ConsumerState<CreatePartnerRequestScreen> createState() => _CreatePartnerRequestScreenState();
}

class _CreatePartnerRequestScreenState extends ConsumerState<CreatePartnerRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();

  String _selectedType = AppConstants.partnerRequestTypes.first;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final tags = _tagsController.text
        .split(',')
        .map((e) => e.trim().replaceAll('#', ''))
        .where((e) => e.isNotEmpty)
        .toList();

    try {
      final repo = ref.read(partnerRequestRepositoryProvider);
      await repo.createRequest(
        authorId: user.id,
        authorName: user.name,
        authorHandle: user.handle,
        authorBranch: user.branch,
        authorHostel: user.hostel,
        type: _selectedType,
        title: _titleController.text,
        description: _descriptionController.text,
        tags: tags,
      );

      ref.invalidate(activePartnerRequestsProvider);
      ref.invalidate(myPartnerRequestsProvider);
      ref.invalidate(canCreatePartnerRequestTodayProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Partner request posted! Visible to classmates for 5 days.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('RateLimitException: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canCreateAsync = ref.watch(canCreatePartnerRequestTodayProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Partner Request'),
      ),
      body: SafeArea(
        child: canCreateAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error checking limits: $err')),
          data: (canCreate) {
            if (!canCreate) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: AppCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.access_time_filled_rounded,
                            size: 40,
                            color: AppColors.warning,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Daily Limit Reached',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          AppStrings.partnerRequestDailyLimitReached,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondaryLight,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        AppButton(
                          text: 'Back to Requests',
                          onPressed: () => context.pop(),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Expiry info badge
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.info_outline_rounded, size: 18, color: AppColors.accentBlue),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Requests automatically expire in 5 days to keep opportunities fresh. Max 1 post & 3 edits per day.',
                              style: TextStyle(fontSize: 12, height: 1.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (_errorMessage != null) ...[
                      ErrorBanner(
                        message: _errorMessage!,
                        onDismiss: () => setState(() => _errorMessage = null),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Request Type
                    Text(
                      'Request Type *',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      isExpanded: true,
                      items: AppConstants.partnerRequestTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedType = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Title
                    AppTextField(
                      label: 'Title',
                      hintText: 'e.g. Flutter developer needed for Hackathon X',
                      controller: _titleController,
                      isRequired: true,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Title is required';
                        if (v.trim().length < 8) return 'Title must be at least 8 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    AppTextField(
                      label: 'Description',
                      hintText: 'Explain the project scope, required skills, and expected time commitment...',
                      controller: _descriptionController,
                      maxLines: 4,
                      isRequired: true,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Description is required';
                        if (v.trim().length < 20) return 'Description must be at least 20 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Tags
                    AppTextField(
                      label: 'Tags (comma separated)',
                      hintText: 'Flutter, AI, SIH2026, Firebase',
                      controller: _tagsController,
                    ),
                    const SizedBox(height: 28),

                    AppButton(
                      text: 'Publish Request',
                      isLoading: _isLoading,
                      onPressed: _handleSubmit,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
