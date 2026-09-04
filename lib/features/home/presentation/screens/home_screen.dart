import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/avatar_widget.dart';
import '../../../../core/widgets/badge_tag.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../confessions/presentation/providers/confession_providers.dart';
import '../../../contests/presentation/providers/contest_providers.dart';
import '../../../exchange/presentation/providers/exchange_providers.dart';
import '../../../groups/presentation/providers/group_providers.dart';
import '../../../partner_requests/presentation/providers/partner_request_providers.dart';
import '../../../partner_requests/presentation/widgets/partner_request_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final partnerRequestsAsync = ref.watch(activePartnerRequestsProvider);
    final groupsAsync = ref.watch(allGroupsProvider);
    final contestsAsync = ref.watch(allContestsProvider);
    final confessionsAsync = ref.watch(confessionsFeedProvider);
    final exchangeAsync = ref.watch(exchangeListingsProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.shield_outlined, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text('CampusHub'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            tooltip: 'Campus Activity',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications: No pending actions. Everything is up to date!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () => context.go('/profile'),
                child: AvatarWidget(name: user.name, radius: 16, isGhost: user.isGhostMode),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(activePartnerRequestsProvider);
          ref.invalidate(allGroupsProvider);
          ref.invalidate(allContestsProvider);
          ref.invalidate(confessionsFeedProvider);
          ref.invalidate(exchangeListingsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Welcome & Freshmen Privacy Banner
            if (user != null) ...[
              Text(
                'Welcome, ${user.name.split(' ').first} 👋',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '1st Year • ${user.branch} • ${user.hostel}',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 16),

              // Profile Completion Meter
              AppCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Profile Setup (Safe & Private)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        Text('85%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accent)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: 0.85,
                        backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // SECTION 1: Find Your Team (Active Partner Requests)
            _buildSectionHeader(
              context: context,
              title: 'Find Your Team',
              actionLabel: 'See all',
              onAction: () => context.push('/partner-requests'),
            ),
            const SizedBox(height: 10),
            partnerRequestsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
              data: (requests) {
                if (requests.isEmpty) {
                  return AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.group_add_outlined, color: AppColors.accent),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text('No active partner requests today. Post one!'),
                        ),
                        TextButton(
                          onPressed: () => context.push('/create-partner-request'),
                          child: const Text('Post'),
                        ),
                      ],
                    ),
                  );
                }
                return Column(
                  children: requests.take(2).map((r) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PartnerRequestCard(
                        request: r,
                        onTap: () => context.push('/partner-request-detail/${r.id}', extra: r),
                        onContact: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Safe connection invite dispatched to ${r.authorHandle}!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 20),

            // SECTION 2: Upcoming Hackathons & Contests
            _buildSectionHeader(
              context: context,
              title: 'Upcoming Hackathons',
              actionLabel: 'Explore',
              onAction: () => context.go('/contests'),
            ),
            const SizedBox(height: 10),
            contestsAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
              data: (contests) {
                return SizedBox(
                  height: 140,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: contests.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (ctx, i) {
                      final c = contests[i];
                      return SizedBox(
                        width: 260,
                        child: AppCard(
                          onTap: () => context.push('/contest-detail/${c.id}', extra: c),
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  BadgeTag(text: c.mode, fontSize: 10),
                                  const Spacer(),
                                  Text(
                                    DateFormatter.formatShortDate(c.deadline),
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.accent),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                c.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                c.prizePool,
                                style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondaryLight),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // SECTION 3: Your Collaboration Groups
            _buildSectionHeader(
              context: context,
              title: 'Collaboration Groups',
              actionLabel: 'All groups',
              onAction: () => context.go('/groups'),
            ),
            const SizedBox(height: 10),
            groupsAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
              data: (groups) {
                return Column(
                  children: groups.take(2).map((g) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AppCard(
                        padding: const EdgeInsets.all(12),
                        onTap: () => context.push('/group-detail/${g.id}', extra: g),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.group_work_rounded, color: AppColors.accent, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(g.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                                  Text('${g.category} • ${g.memberCount} members', style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: AppColors.textMutedLight),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 24),

            // SECTION 4: Campus Discussions & Anonymous Confessions
            _buildSectionHeader(
              context: context,
              title: 'Campus Discussions',
              actionLabel: 'Open board',
              onAction: () => context.push('/confessions'),
            ),
            const SizedBox(height: 10),
            confessionsAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
              data: (confessions) {
                if (confessions.isEmpty) return const SizedBox.shrink();
                final latest = confessions.first;
                return AppCard(
                  onTap: () => context.push('/confessions'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          BadgeTag(text: latest.category),
                          const Spacer(),
                          const Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.textMutedLight),
                          const SizedBox(width: 4),
                          const Text('Anonymous Peer', style: TextStyle(fontSize: 11, color: AppColors.textMutedLight)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        latest.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13.5, height: 1.4),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.thumb_up_alt_outlined, size: 14, color: AppColors.accent),
                          const SizedBox(width: 4),
                          Text('${latest.upvotes}', style: const TextStyle(fontSize: 12, color: AppColors.accent)),
                          const SizedBox(width: 14),
                          const Icon(Icons.chat_bubble_outline_rounded, size: 14, color: AppColors.textSecondaryLight),
                          const SizedBox(width: 4),
                          Text('${latest.commentCount}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // SECTION 5: Exchange Board
            _buildSectionHeader(
              context: context,
              title: 'Exchange Board',
              actionLabel: 'View items',
              onAction: () => context.push('/exchange'),
            ),
            const SizedBox(height: 10),
            exchangeAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
              data: (items) {
                if (items.isEmpty) return const SizedBox.shrink();
                final item = items.first;
                return AppCard(
                  onTap: () => context.push('/exchange'),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.menu_book_rounded, color: Color(0xFF15803D), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.itemName, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                            Text('${item.hostel} • ${item.priceOrFree}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.textMutedLight),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required BuildContext context,
    required String title,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.primary,
            letterSpacing: -0.3,
          ),
        ),
        GestureDetector(
          onTap: onAction,
          child: Text(
            actionLabel,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ),
        ),
      ],
    );
  }
}
