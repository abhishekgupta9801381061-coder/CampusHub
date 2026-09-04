import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock_group_repository.dart';
import '../../domain/group.dart';
import '../../domain/group_repository.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  return MockGroupRepository();
});

final groupCategoryFilterProvider = StateProvider<String?>((ref) => null);
final groupSearchQueryProvider = StateProvider<String>((ref) => '');

final allGroupsProvider = FutureProvider<List<Group>>((ref) async {
  final repo = ref.watch(groupRepositoryProvider);
  final category = ref.watch(groupCategoryFilterProvider);
  final query = ref.watch(groupSearchQueryProvider);
  return repo.getGroups(category: category, query: query);
});

final myGroupsProvider = FutureProvider<List<Group>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final repo = ref.watch(groupRepositoryProvider);
  return repo.getMyGroups(user.id);
});

final userCreatedGroupCountProvider = FutureProvider<int>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return 0;
  final repo = ref.watch(groupRepositoryProvider);
  return repo.getUserCreatedGroupCount(user.id);
});
