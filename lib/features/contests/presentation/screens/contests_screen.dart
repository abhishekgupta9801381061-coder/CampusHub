import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/badge_tag.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../providers/contest_providers.dart';

class ContestsScreen extends ConsumerWidget {
  const ContestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contestsAsync = ref.watch(allContestsProvider);
    final bookmarkedOnly = ref.watch(contestBookmarkedOnlyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hackathons & Contests'),
        actions: [
          IconButton(
            icon: Icon(
              bookmarkedOnly ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: bookmarkedOnly ? AppColors.accent : null,
            ),
            tooltip: 'Saved Contests',
            onPressed: () {
              ref.read(contestBookmarkedOnlyProvider.notifier).state = !bookmarkedOnly;
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (v) => ref.read(contestSearchQueryProvider.notifier).state = v,
              decoration: InputDecoration(
                hintText: 'Search hackathons, AI challenges, contests...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ),

          Expanded(
            child: contestsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (contests) {
                if (contests.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.emoji_events_outlined,
                    title: bookmarkedOnly ? 'No Saved Contests' : 'No Contests Found',
                    description: bookmarkedOnly
                        ? 'Bookmark contests to keep track of their deadlines and prize pools.'
                        : 'No upcoming competitions matched your search.',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(allContestsProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: contests.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final contest = contests[index];
                      return AppCard(
                        onTap: () => context.push('/contest-detail/${contest.id}', extra: contest),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                BadgeTag(
                                  text: contest.mode.toUpperCase(),
                                  backgroundColor: contest.mode == 'Online'
                                      ? const Color(0xFFE0F2FE)
                                      : const Color(0xFFDCFCE7),
                                  textColor: contest.mode == 'Online'
                                      ? const Color(0xFF0369A1)
                                      : const Color(0xFF15803D),
                                  fontSize: 10.5,
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: Icon(
                                    contest.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                    color: contest.isBookmarked ? AppColors.accent : AppColors.textMutedLight,
                                    size: 22,
                                  ),
                                  onPressed: () async {
                                    await ref.read(contestRepositoryProvider).toggleBookmark(contest.id);
                                    ref.invalidate(allContestsProvider);
                                  },
                                ),
                              ],
                            ),
                            Text(
                              contest.title,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : AppColors.primary,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              contest.organizer,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.accentBlue),
                                const SizedBox(width: 6),
                                Text(
                                  'Deadline: ${DateFormatter.formatShortDate(contest.deadline)}',
                                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 16),
                                const Icon(Icons.military_tech_rounded, size: 16, color: AppColors.warning),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    contest.prizePool,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: contest.tags.map((t) => BadgeTag(text: '#$t', fontSize: 11)).toList(),
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
