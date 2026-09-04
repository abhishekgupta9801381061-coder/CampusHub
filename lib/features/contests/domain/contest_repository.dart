import 'contest.dart';

abstract class ContestRepository {
  Future<List<Contest>> getContests({String? query, bool? bookmarkedOnly});
  Future<Contest> getContestById(String id);
  Future<void> toggleBookmark(String contestId);
}
