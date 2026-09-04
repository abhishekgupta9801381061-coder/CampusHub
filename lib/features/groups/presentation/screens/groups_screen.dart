import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/badge_tag.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../providers/group_providers.dart';

class GroupsScreen extends ConsumerWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(allGroupsProvider);
    final countAsync = ref.watch(userCreatedGroupCountProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Groups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_pin_circle_outlined),
            tooltip: 'My Joined Groups',
            onPressed: () => context.push('/my-groups'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: isDark ? Colors.white : AppColors.primary,
        foregroundColor: isDark ? AppColors.primary : Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Create Group', style: TextStyle(fontWeight: FontWeight.w600)),
        onPressed: () => context.push('/create-group'),
      ),
      body: Column(
        children: [
          // Quota status banner (Max 4 active groups)
          countAsync.when(
            data: (count) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, size: 16, color: AppColors.accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your Created Groups: $count / 4 active allowed',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: count >= 4 ? AppColors.error : (isDark ? Colors.white : AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              onChanged: (val) => ref.read(groupSearchQueryProvider.notifier).state = val,
              decoration: InputDecoration(
                hintText: 'Search study teams, AI clubs, robotics...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Groups list
          Expanded(
            child: groupsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error loading groups: $err')),
              data: (groups) {
                if (groups.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.groups_outlined,
                    title: 'No Groups Found',
                    description: 'Start a collaborative squad for an upcoming hackathon or course project.',
                    actionText: 'Create a Group',
                    onAction: () => context.push('/create-group'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(allGroupsProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: groups.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      return AppCard(
                        onTap: () => context.push('/group-detail/${group.id}', extra: group),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.group_work_rounded,
                                    color: AppColors.accent,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        group.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? Colors.white : AppColors.primary,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Created by ${group.creatorHandle} • ${group.memberCount} members',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded, color: AppColors.textMutedLight),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              group.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.4,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: group.tags
                                  .map((t) => BadgeTag(text: '#$t', fontSize: 11))
                                  .toList(),
                            ),
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
