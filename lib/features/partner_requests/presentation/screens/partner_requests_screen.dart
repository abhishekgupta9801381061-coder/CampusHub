import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../providers/partner_request_providers.dart';
import '../widgets/partner_request_card.dart';

class PartnerRequestsScreen extends ConsumerWidget {
  const PartnerRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(activePartnerRequestsProvider);
    final selectedFilter = ref.watch(selectedRequestTypeFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Partner Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_edu_rounded),
            tooltip: 'My Requests',
            onPressed: () => context.push('/my-partner-requests'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: isDark ? Colors.white : AppColors.primary,
        foregroundColor: isDark ? AppColors.primary : Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Create Request', style: TextStyle(fontWeight: FontWeight.w600)),
        onPressed: () => context.push('/create-partner-request'),
      ),
      body: Column(
        children: [
          // Filter horizontally scrollable pills
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              children: [
                _buildFilterPill(
                  context: context,
                  label: 'All Requests',
                  isSelected: selectedFilter == null,
                  onTap: () => ref.read(selectedRequestTypeFilterProvider.notifier).state = null,
                ),
                ...AppConstants.partnerRequestTypes.map(
                  (type) => _buildFilterPill(
                    context: context,
                    label: type,
                    isSelected: selectedFilter == type,
                    onTap: () => ref.read(selectedRequestTypeFilterProvider.notifier).state = type,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Requests List
          Expanded(
            child: requestsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error loading requests: $err')),
              data: (requests) {
                if (requests.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.group_work_outlined,
                    title: 'No Active Requests',
                    description: 'Be the first freshman to post a hackathon, study, or startup partnership request today.',
                    actionText: 'Post Request',
                    onAction: () => context.push('/create-partner-request'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(activePartnerRequestsProvider);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: requests.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final req = requests[index];
                      return PartnerRequestCard(
                        request: req,
                        onTap: () => context.push('/partner-request-detail/${req.id}', extra: req),
                        onContact: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Safe connection invitation sent to ${req.authorHandle}!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
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

  Widget _buildFilterPill({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: isDark ? Colors.white : AppColors.primary,
        backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        labelStyle: TextStyle(
          fontSize: 12.5,
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
  }
}
