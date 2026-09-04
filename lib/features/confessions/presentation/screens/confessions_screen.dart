import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/badge_tag.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../domain/confession.dart';
import '../providers/confession_providers.dart';

class ConfessionsScreen extends ConsumerStatefulWidget {
  const ConfessionsScreen({super.key});

  @override
  ConsumerState<ConfessionsScreen> createState() => _ConfessionsScreenState();
}

class _ConfessionsScreenState extends ConsumerState<ConfessionsScreen> {
  void _showPostDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _CreateConfessionSheet(),
    );
  }

  void _showCommentsSheet(Confession confession) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ConfessionCommentsSheet(confession: confession),
    );
  }

  @override
  Widget build(BuildContext context) {
    final confessionsAsync = ref.watch(confessionsFeedProvider);
    final currentCategory = ref.watch(confessionCategoryFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final categories = ['#All', ...AppConstants.confessionCategories];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Anonymous Confessions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shield_outlined),
            tooltip: '100% Identity Shielded',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Identity Protection: Confessions never track or expose your handle, name, or room.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: isDark ? Colors.white : AppColors.primary,
        foregroundColor: isDark ? AppColors.primary : Colors.white,
        icon: const Icon(Icons.edit_note_rounded),
        label: const Text('Post Anonymously', style: TextStyle(fontWeight: FontWeight.w600)),
        onPressed: _showPostDialog,
      ),
      body: Column(
        children: [
          // Category horizontal selector
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = currentCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) => ref.read(confessionCategoryFilterProvider.notifier).state = cat,
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
              },
            ),
          ),
          const SizedBox(height: 6),

          Expanded(
            child: confessionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (confessions) {
                if (confessions.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.forum_outlined,
                    title: 'No Confessions Yet',
                    description: 'Be the first to share an anonymous campus experience or question.',
                    actionText: 'Post Anonymously',
                    onAction: _showPostDialog,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(confessionsFeedProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: confessions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = confessions[index];
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
                                const Spacer(),
                                Text(
                                  DateFormatter.timeAgo(item.createdAt),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert_rounded, size: 18),
                                  itemBuilder: (ctx) => [
                                    const PopupMenuItem(value: 'report', child: Text('Report Confession')),
                                  ],
                                  onSelected: (val) {
                                    if (val == 'report') {
                                      ref.read(confessionRepositoryProvider).reportConfession(item.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Reported for campus moderation review.'),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item.content,
                              style: TextStyle(
                                fontSize: 14.5,
                                height: 1.5,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Vote & Comment row
                            Row(
                              children: [
                                // Upvote button
                                InkWell(
                                  onTap: () async {
                                    await ref.read(confessionRepositoryProvider).upvoteConfession(item.id);
                                    ref.invalidate(confessionsFeedProvider);
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    child: Row(
                                      children: [
                                        Icon(
                                          item.hasUpvoted ? Icons.thumb_up_alt_rounded : Icons.thumb_up_alt_outlined,
                                          size: 16,
                                          color: item.hasUpvoted ? AppColors.accent : AppColors.textSecondaryLight,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${item.upvotes}',
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                            color: item.hasUpvoted ? AppColors.accent : AppColors.textSecondaryLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Downvote button
                                InkWell(
                                  onTap: () async {
                                    await ref.read(confessionRepositoryProvider).downvoteConfession(item.id);
                                    ref.invalidate(confessionsFeedProvider);
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    child: Row(
                                      children: [
                                        Icon(
                                          item.hasDownvoted ? Icons.thumb_down_alt_rounded : Icons.thumb_down_alt_outlined,
                                          size: 16,
                                          color: item.hasDownvoted ? AppColors.error : AppColors.textSecondaryLight,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${item.downvotes}',
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                            color: item.hasDownvoted ? AppColors.error : AppColors.textSecondaryLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                // Comments button
                                InkWell(
                                  onTap: () => _showCommentsSheet(item),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: AppColors.textSecondaryLight),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${item.commentCount} comments',
                                          style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondaryLight),
                                        ),
                                      ],
                                    ),
                                  ),
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

class _CreateConfessionSheet extends ConsumerStatefulWidget {
  const _CreateConfessionSheet();

  @override
  ConsumerState<_CreateConfessionSheet> createState() => _CreateConfessionSheetState();
}

class _CreateConfessionSheetState extends ConsumerState<_CreateConfessionSheet> {
  final _contentController = TextEditingController();
  String _selectedCategory = AppConstants.confessionCategories.first;
  bool _isLoading = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _contentController.text.trim();
    if (text.length < 5) return;

    setState(() => _isLoading = true);
    try {
      final secret = const Uuid().v4();
      await ref.read(confessionRepositoryProvider).postConfession(
            category: _selectedCategory,
            content: text,
            authorSecret: secret,
          );
      ref.invalidate(confessionsFeedProvider);
      if (mounted) Navigator.pop(context);
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.lock_rounded, size: 18, color: AppColors.accent),
              SizedBox(width: 8),
              Text(
                'Post Anonymous Confession',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Category',
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            items: AppConstants.confessionCategories.map((cat) {
              return DropdownMenuItem(value: cat, child: Text(cat));
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedCategory = val);
            },
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _contentController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Share anonymously. Identity is completely unlinked...',
            ),
          ),
          const SizedBox(height: 18),
          AppButton(
            text: 'Post Confession',
            isLoading: _isLoading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

class _ConfessionCommentsSheet extends ConsumerStatefulWidget {
  final Confession confession;

  const _ConfessionCommentsSheet({required this.confession});

  @override
  ConsumerState<_ConfessionCommentsSheet> createState() => _ConfessionCommentsSheetState();
}

class _ConfessionCommentsSheetState extends ConsumerState<_ConfessionCommentsSheet> {
  final _commentController = TextEditingController();
  List<ConfessionComment> _comments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    final list = await ref.read(confessionRepositoryProvider).getComments(widget.confession.id);
    if (mounted) {
      setState(() {
        _comments = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    _commentController.clear();

    await ref.read(confessionRepositoryProvider).addComment(
          confessionId: widget.confession.id,
          content: text,
        );
    _loadComments();
    ref.invalidate(confessionsFeedProvider);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Anonymous Comments',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _comments.isEmpty
                    ? const Center(child: Text('No comments yet. Start the conversation!'))
                    : ListView.separated(
                        itemCount: _comments.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (ctx, i) {
                          final cm = _comments[i];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.lock_clock_outlined, size: 14, color: AppColors.textMutedLight),
                                    const SizedBox(width: 4),
                                    const Text('Anonymous Peer', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                                    const Spacer(),
                                    Text(DateFormatter.timeAgo(cm.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.textMutedLight)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(cm.content, style: const TextStyle(fontSize: 13.5)),
                              ],
                            ),
                          );
                        },
                      ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'Add an anonymous comment...',
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                icon: const Icon(Icons.send_rounded, size: 18),
                onPressed: _addComment,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
