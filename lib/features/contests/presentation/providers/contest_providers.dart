import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock_contest_repository.dart';
import '../../domain/contest.dart';
import '../../domain/contest_repository.dart';

final contestRepositoryProvider = Provider<ContestRepository>((ref) {
  return MockContestRepository();
});

final contestSearchQueryProvider = StateProvider<String>((ref) => '');
final contestBookmarkedOnlyProvider = StateProvider<bool>((ref) => false);

final allContestsProvider = FutureProvider<List<Contest>>((ref) async {
  final repo = ref.watch(contestRepositoryProvider);
  final query = ref.watch(contestSearchQueryProvider);
  final bookmarkedOnly = ref.watch(contestBookmarkedOnlyProvider);
  return repo.getContests(query: query, bookmarkedOnly: bookmarkedOnly);
});
