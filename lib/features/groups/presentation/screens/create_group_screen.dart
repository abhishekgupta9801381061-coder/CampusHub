import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/group_providers.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _tagsController = TextEditingController();

  String _category = 'Hackathon Team';
  bool _isLoading = false;
  String? _errorMessage;

  static const _categories = [
    'Hackathon Team',
    'AI & Machine Learning',
    'Web Development',
    'Robotics',
    'Startup Team',
    'Course Study Group',
    'Competitive Programming',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
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
      final repo = ref.read(groupRepositoryProvider);
      await repo.createGroup(
        name: _nameController.text,
        description: _descController.text,
        category: _category,
        tags: tags,
        creatorId: user.id,
        creatorHandle: user.handle,
        creatorName: user.name,
        creatorBranch: user.branch,
        creatorHostel: user.hostel,
      );

      ref.invalidate(allGroupsProvider);
      ref.invalidate(myGroupsProvider);
      ref.invalidate(userCreatedGroupCountProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Collaboration group successfully formed!'),
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
    final countAsync = ref.watch(userCreatedGroupCountProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Collaboration Group'),
      ),
      body: SafeArea(
        child: countAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
          data: (count) {
            if (count >= 4) {
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
                            color: AppColors.error.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.groups_rounded,
                            size: 44,
                            color: AppColors.error,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Group Limit Reached',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          AppStrings.groupsMaxLimitReached,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondaryLight,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        AppButton(
                          text: 'Back to Groups',
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
                    if (_errorMessage != null) ...[
                      ErrorBanner(
                        message: _errorMessage!,
                        onDismiss: () => setState(() => _errorMessage = null),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Category
                    Text(
                      'Category *',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _category,
                      isExpanded: true,
                      items: _categories.map((c) {
                        return DropdownMenuItem(value: c, child: Text(c));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _category = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    AppTextField(
                      label: 'Group Name',
                      hintText: 'e.g. Robotics & Quadcopter Team',
                      controller: _nameController,
                      isRequired: true,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Group name is required';
                        if (v.trim().length < 4) return 'Must be at least 4 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    AppTextField(
                      label: 'Description',
                      hintText: 'Describe group purpose, goals, and who should join...',
                      controller: _descController,
                      maxLines: 4,
                      isRequired: true,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Description is required';
                        if (v.trim().length < 15) return 'Must be at least 15 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    AppTextField(
                      label: 'Tags (comma separated)',
                      hintText: 'ROS2, Python, Hardware, CAD',
                      controller: _tagsController,
                    ),
                    const SizedBox(height: 28),

                    AppButton(
                      text: 'Create Group',
                      isLoading: _isLoading,
                      onPressed: _handleCreate,
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
