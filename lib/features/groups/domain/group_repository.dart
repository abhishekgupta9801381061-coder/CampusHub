import 'group.dart';

abstract class GroupRepository {
  Future<List<Group>> getGroups({String? category, String? query});
  Future<List<Group>> getMyGroups(String userId);
  Future<Group> getGroupById(String id);
  Future<List<GroupMember>> getGroupMembers(String groupId);
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
  });
  Future<void> joinGroup({
    required String groupId,
    required String userId,
    required String userName,
    required String userHandle,
    required String userBranch,
    required String userHostel,
  });
  Future<void> leaveGroup({required String groupId, required String userId});
  Future<bool> isUserMember({required String groupId, required String userId});
  Future<int> getUserCreatedGroupCount(String userId);
}
