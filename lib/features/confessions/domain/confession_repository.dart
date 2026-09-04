import 'confession.dart';

abstract class ConfessionRepository {
  Future<List<Confession>> getConfessions({String? category});
  Future<Confession> postConfession({required String category, required String content, required String authorSecret});
  Future<void> upvoteConfession(String id);
  Future<void> downvoteConfession(String id);
  Future<List<ConfessionComment>> getComments(String confessionId);
  Future<void> addComment({required String confessionId, required String content});
  Future<void> deleteConfession({required String id, required String authorSecret});
  Future<void> reportConfession(String id);
}
