import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/avatar_widget.dart';
import '../../../../core/widgets/badge_tag.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../auth/data/mock_auth_repository.dart';
import '../../../auth/domain/user.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../social_bridge/presentation/widgets/social_bridge_dialog.dart';

final discoverSearchQueryProvider = StateProvider<String>((ref) => '');
final discoverBranchFilterProvider = StateProvider<String?>((ref) => null);
final discoverHostelFilterProvider = StateProvider<String?>((ref) => null);

final discoverStudentsProvider = FutureProvider<List<User>>((ref) async {
  final authRepo = ref.watch(authRepositoryProvider);
  final query = ref.watch(discoverSearchQueryProvider).toLowerCase();
  final branchFilter = ref.watch(discoverBranchFilterProvider);
  final hostelFilter = ref.watch(discoverHostelFilterProvider);

  if (authRepo is MockAuthRepository) {
    final all = authRepo.getAllUsers();
    return all.where((u) {
      // STRICT RULE: If Ghost Mode is enabled, omit from search/discovery
      if (u.isGhostMode) return false;

      if (branchFilter != null && u.branch != branchFilter) return false;
      if (hostelFilter != null && u.hostel != hostelFilter) return false;

      if (query.isNotEmpty) {
        final nameMatch = u.name.toLowerCase().contains(query);
        final handleMatch = u.handle.toLowerCase().contains(query);
        final skillMatch = u.skills.any((s) => s.toLowerCase().contains(query));
        if (!nameMatch && !handleMatch && !skillMatch) return false;
      }
      return true;
    }).toList();
  }
  return [];
});

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  void _showStudentProfileModal(BuildContext context, User student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _StudentDetailModal(student: student),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(discoverStudentsProvider);
    final selectedBranch = ref.watch(discoverBranchFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Classmates'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (v) => ref.read(discoverSearchQueryProvider.notifier).state = v,
              decoration: InputDecoration(
                hintText: 'Search by name, @handle, or skill (e.g. Flutter)...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ),

          // Branch Filter Chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('All Branches'),
                    selected: selectedBranch == null,
                    onSelected: (_) => ref.read(discoverBranchFilterProvider.notifier).state = null,
                    selectedColor: isDark ? Colors.white : AppColors.primary,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: selectedBranch == null ? FontWeight.w700 : FontWeight.w500,
                      color: selectedBranch == null
                          ? (isDark ? AppColors.primary : Colors.white)
                          : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                    ),
                    checkmarkColor: isDark ? AppColors.primary : Colors.white,
                  ),
                ),
                ...AppConstants.branches.map((branch) {
                  final isSelected = selectedBranch == branch;
                  final shortName = branch.replaceAll('Engineering', 'Engg');
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(shortName),
                      selected: isSelected,
                      onSelected: (_) => ref.read(discoverBranchFilterProvider.notifier).state = branch,
                      selectedColor: isDark ? Colors.white : AppColors.primary,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? (isDark ? AppColors.primary : Colors.white)
                            : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                      ),
                      checkmarkColor: isDark ? AppColors.primary : Colors.white,
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Student Grid / List
          Expanded(
            child: studentsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (students) {
                if (students.isEmpty) {
                  return const EmptyStateView(
                    icon: Icons.person_search_outlined,
                    title: 'No Classmates Found',
                    description: 'Try adjusting your filters or search terms. Students with Ghost Mode enabled are automatically hidden.',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(discoverStudentsProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: students.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final s = students[index];
                      return AppCard(
                        onTap: () => _showStudentProfileModal(context, s),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AvatarWidget(name: s.name, radius: 24),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        s.name,
                                        style: TextStyle(
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? Colors.white : AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        s.handle,
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          color: AppColors.accent,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  // Shows hostel but strictly zero room number!
                                  Text(
                                    '${s.branch} • ${s.hostel}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: s.skills
                                        .take(3)
                                        .map((sk) => BadgeTag(text: sk, fontSize: 10.5))
                                        .toList(),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: AppColors.textMutedLight),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentDetailModal extends StatelessWidget {
  final User student;

  const _StudentDetailModal({required this.student});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarWidget(name: student.name, radius: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.primary,
                      ),
                    ),
                    Text(
                      student.handle,
                      style: const TextStyle(fontSize: 13, color: AppColors.accent, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${student.branch} • ${student.hostel}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          const Text('Skills & Competencies', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: student.skills.map((s) => BadgeTag(text: s)).toList(),
          ),
          const SizedBox(height: 16),

          const Text('Interests', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: student.interests.map((i) => BadgeTag(text: i)).toList(),
          ),
          const SizedBox(height: 24),

          // Safe Connection Action
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (ctx) => const SocialBridgeDialog(),
                    );
                  },
                  icon: const Icon(Icons.link_rounded, size: 18),
                  label: const Text('Share Ephemeral Link'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
