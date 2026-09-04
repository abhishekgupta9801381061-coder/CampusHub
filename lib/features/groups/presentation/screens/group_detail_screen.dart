import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/avatar_widget.dart';
import '../../../../core/widgets/badge_tag.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/group.dart';
import '../providers/group_providers.dart';

class GroupDetailScreen extends ConsumerStatefulWidget {
  final String groupId;
  final Group? initialGroup;

  const GroupDetailScreen({
    super.key,
    required this.groupId,
    this.initialGroup,
  });

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen> {
  Group? _group;
  List<GroupMember> _members = [];
  bool _isMember = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _group = widget.initialGroup;
    _loadGroupData();
  }

  Future<void> _loadGroupData() async {
    final repo = ref.read(groupRepositoryProvider);
    final user = ref.read(currentUserProvider);

    try {
      final grp = _group ?? await repo.getGroupById(widget.groupId);
      final members = await repo.getGroupMembers(widget.groupId);
      final isMem = user != null ? await repo.isUserMember(groupId: widget.groupId, userId: user.id) : false;

      if (mounted) {
        setState(() {
          _group = grp;
          _members = members;
          _isMember = isMem;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleJoin() async {
    final user = ref.read(currentUserProvider);
    if (user == null || _group == null) return;
    final repo = ref.read(groupRepositoryProvider);

    if (_isMember) {
      await repo.leaveGroup(groupId: _group!.id, userId: user.id);
      setState(() => _isMember = false);
    } else {
      await repo.joinGroup(
        groupId: _group!.id,
        userId: user.id,
        userName: user.name,
        userHandle: user.handle,
        userBranch: user.branch,
        userHostel: user.hostel,
      );
      setState(() => _isMember = true);
    }

    _loadGroupData();
    ref.invalidate(allGroupsProvider);
    ref.invalidate(myGroupsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_group == null) {
      return const Scaffold(
        body: Center(child: Text('Group not found')),
      );
    }

    final grp = _group!;

    return Scaffold(
      appBar: AppBar(
        title: Text(grp.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BadgeTag(
                    text: grp.category,
                    backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    textColor: AppColors.accent,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    grp.name,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Created by ${grp.creatorHandle}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    grp.description,
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.5,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: grp.tags.map((t) => BadgeTag(text: '#$t')).toList(),
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    text: _isMember ? 'Leave Group' : 'Join Collaboration Group',
                    variant: _isMember ? AppButtonVariant.outline : AppButtonVariant.primary,
                    icon: Icon(_isMember ? Icons.exit_to_app_rounded : Icons.person_add_rounded, size: 18),
                    onPressed: _toggleJoin,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Members section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Group Roster (${_members.length})',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.primary,
                  ),
                ),
                Text(
                  'Privacy Shield Active',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.accentBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_members.isEmpty)
              const Text('No members listed.')
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _members.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final member = _members[index];
                  return AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        AvatarWidget(name: member.userName, radius: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                member.userName,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : AppColors.primary,
                                ),
                              ),
                              Text(
                                '${member.userHandle} • ${member.userHostel}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (member.role == 'admin')
                          const BadgeTag(
                            text: 'ADMIN',
                            backgroundColor: Color(0xFFFEF3C7),
                            textColor: Color(0xFF92400E),
                            fontSize: 10,
                          ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
