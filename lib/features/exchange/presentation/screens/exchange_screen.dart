import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/badge_tag.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../providers/exchange_providers.dart';

class ExchangeScreen extends ConsumerWidget {
  const ExchangeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(exchangeListingsProvider);
    final currentCategory = ref.watch(exchangeCategoryFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final categories = ['All', ...AppConstants.exchangeCategories];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cross-Hostel Exchange'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: isDark ? Colors.white : AppColors.primary,
        foregroundColor: isDark ? AppColors.primary : Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('List Item', style: TextStyle(fontWeight: FontWeight.w600)),
        onPressed: () => context.push('/create-exchange'),
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (v) => ref.read(exchangeSearchQueryProvider.notifier).state = v,
              decoration: InputDecoration(
                hintText: 'Search textbooks, lab coats, calculators...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ),

          // Categories
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: categories.length,
              itemBuilder: (ctx, i) {
                final cat = categories[i];
                final isSelected = currentCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) => ref.read(exchangeCategoryFilterProvider.notifier).state = cat,
                    selectedColor: isDark ? Colors.white : AppColors.primary,
                    backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? (isDark ? AppColors.primary : Colors.white)
                          : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                    ),
                    checkmarkColor: isDark ? AppColors.primary : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    side: BorderSide.none,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),

          Expanded(
            child: listingsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (listings) {
                if (listings.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.inventory_2_outlined,
                    title: 'No Items Listed',
                    description: 'Have extra lab supplies or finished semester textbooks? Help another freshman out!',
                    actionText: 'List an Item',
                    onAction: () => context.push('/create-exchange'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(exchangeListingsProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: listings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = listings[index];
                      return AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                BadgeTag(
                                  text: item.category,
                                  backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                  textColor: AppColors.accent,
                                ),
                                const SizedBox(width: 8),
                                BadgeTag(
                                  text: item.condition,
                                  backgroundColor: const Color(0xFFDCFCE7),
                                  textColor: const Color(0xFF15803D),
                                  fontSize: 11,
                                ),
                                const Spacer(),
                                Text(
                                  item.priceOrFree,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.accentBlue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item.itemName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.description,
                              style: TextStyle(
                                fontSize: 13.5,
                                height: 1.4,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondaryLight),
                                const SizedBox(width: 4),
                                Text(
                                  '${item.ownerHandle} • ${item.hostel}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                                const Spacer(),
                                TextButton.icon(
                                  icon: const Icon(Icons.handshake_outlined, size: 16),
                                  label: const Text('Claim / Trade'),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Safe campus request sent to ${item.ownerHandle}!'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                ),
                              ],
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
