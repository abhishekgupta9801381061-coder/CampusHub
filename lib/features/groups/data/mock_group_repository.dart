import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/errors/exceptions.dart';
import '../domain/group.dart';
import '../domain/group_repository.dart';

class MockGroupRepository implements GroupRepository {
  final List<Group> _groups = [];
  final List<GroupMember> _members = [];

  MockGroupRepository() {
    _seedData();
  }

  void _seedData() {
    final g1 = Group(
      id: 'grp-001',
      name: 'AI Hackathon Builders',
      description: 'Hub for freshmen working with LLMs, Computer Vision, and full-stack generative AI applications.',
      category: 'AI & Machine Learning',
      tags: const ['AI', 'Python', 'Hackathon'],
      creatorId: 'usr-freshman-01',
      creatorHandle: '@Abhishek07',
      memberCount: 4,
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
    );

    final g2 = Group(
      id: 'grp-002',
      name: 'Robotics & Hardware Lab',
      description: 'Freshmen working on microcontrollers, ROS2, autonomous bots, and 3D printing in the campus makerspace.',
      category: 'Robotics',
      tags: const ['Arduino', 'ROS', 'IoT'],
      creatorId: 'usr-freshman-04',
      creatorHandle: '@Sneha_Robo',
      memberCount: 6,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    );

    final g3 = Group(
      id: 'grp-003',
      name: 'Campus Startup Founders Club',
      description: 'Building student ventures, solving campus friction, peer pitch reviews, and investor readiness.',
      category: 'Startup',
      tags: const ['Startup', 'Fintech', 'SaaS'],
      creatorId: 'usr-freshman-03',
      creatorHandle: '@Arjun_Mech',
      memberCount: 8,
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
    );

    _groups.addAll([g1, g2, g3]);

    // Seed members
    _members.addAll([
      GroupMember(
        id: 'gm-01',
        groupId: 'grp-001',
        userId: 'usr-freshman-01',
        userName: 'Abhishek Kumar',
        userHandle: '@Abhishek07',
        userBranch: 'Computer Science & Engineering',
        userHostel: 'Hostel H-1 (Raman)',
        role: 'admin',
        joinedAt: DateTime.now().subtract(const Duration(days: 14)),
      ),
      GroupMember(
        id: 'gm-02',
        groupId: 'grp-001',
        userId: 'usr-freshman-02',
        userName: 'Priya Sharma',
        userHandle: '@PriyaCS',
        userBranch: 'Computer Science & Engineering',
        userHostel: 'Hostel G-1 (Kalpana)',
        role: 'member',
        joinedAt: DateTime.now().subtract(const Duration(days: 12)),
      ),
    ]);
  }

  @override
  Future<int> getUserCreatedGroupCount(String userId) async {
    return _groups.where((g) => g.creatorId == userId).length;
  }

  @override
  Future<List<Group>> getGroups({String? category, String? query}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _groups.where((g) {
      if (category != null && category.isNotEmpty && g.category != category) return false;
      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        final matchName = g.name.toLowerCase().contains(q);
        final matchDesc = g.description.toLowerCase().contains(q);
        final matchTag = g.tags.any((t) => t.toLowerCase().contains(q));
        if (!matchName && !matchDesc && !matchTag) return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<List<Group>> getMyGroups(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final memberGroupIds = _members.where((m) => m.userId == userId).map((m) => m.groupId).toSet();
    return _groups.where((g) => g.creatorId == userId || memberGroupIds.contains(g.id)).toList();
  }

  @override
  Future<Group> getGroupById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _groups.firstWhere(
      (g) => g.id == id,
      orElse: () => throw const ServerException('Group not found', 404),
    );
  }

  @override
  Future<List<GroupMember>> getGroupMembers(String groupId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _members.where((m) => m.groupId == groupId).toList();
  }

  @override
  Future<Group> createGroup({
    required String name,
    required String description,
    required String category,
    required List<String> tags,
    required String creatorId,
    required String creatorHandle,
    required String creatorName,
    required String creatorBranch,
    required String creatorHostel,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    // Enforce 4 active groups limit
    final userGroupCount = await getUserCreatedGroupCount(creatorId);
    if (userGroupCount >= AppConstants.maxActiveGroupsPerUser) {
      throw const RateLimitException(AppStrings.groupsMaxLimitReached);
    }

    final newGroupId = const Uuid().v4();
    final newGroup = Group(
      id: newGroupId,
      name: name.trim(),
      description: description.trim(),
      category: category,
      tags: tags,
      creatorId: creatorId,
      creatorHandle: creatorHandle,
      memberCount: 1,
      createdAt: DateTime.now(),
    );

    _groups.insert(0, newGroup);

    // Add creator as admin member
    _members.add(
      GroupMember(
        id: const Uuid().v4(),
        groupId: newGroupId,
        userId: creatorId,
        userName: creatorName,
        userHandle: creatorHandle,
        userBranch: creatorBranch,
        userHostel: creatorHostel,
        role: 'admin',
        joinedAt: DateTime.now(),
      ),
    );

    return newGroup;
  }

  @override
  Future<void> joinGroup({
    required String groupId,
    required String userId,
    required String userName,
    required String userHandle,
    required String userBranch,
    required String userHostel,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final alreadyMember = _members.any((m) => m.groupId == groupId && m.userId == userId);
    if (!alreadyMember) {
      _members.add(
        GroupMember(
          id: const Uuid().v4(),
          groupId: groupId,
          userId: userId,
          userName: userName,
          userHandle: userHandle,
          userBranch: userBranch,
          userHostel: userHostel,
          role: 'member',
          joinedAt: DateTime.now(),
        ),
      );

      final index = _groups.indexWhere((g) => g.id == groupId);
      if (index != -1) {
        final g = _groups[index];
        _groups[index] = g.copyWith(memberCount: g.memberCount + 1);
      }
    }
  }

  @override
  Future<void> leaveGroup({required String groupId, required String userId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _members.indexWhere((m) => m.groupId == groupId && m.userId == userId);
    if (index != -1) {
      _members.removeAt(index);
      final gIndex = _groups.indexWhere((g) => g.id == groupId);
      if (gIndex != -1) {
        final g = _groups[gIndex];
        _groups[gIndex] = g.copyWith(memberCount: (g.memberCount - 1).clamp(0, 99999));
      }
    }
  }

  @override
  Future<bool> isUserMember({required String groupId, required String userId}) async {
    return _members.any((m) => m.groupId == groupId && m.userId == userId);
  }
}
