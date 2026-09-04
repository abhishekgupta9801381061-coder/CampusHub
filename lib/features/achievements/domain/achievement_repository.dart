import 'achievement.dart';

abstract class AchievementRepository {
  Future<List<Achievement>> getUserAchievements(String userId);
  Future<Achievement> submitAchievement({
    required String userId,
    required String title,
    required String description,
    required String category,
    String? proofUrl,
  });
  Future<String> getSignedUploadUrl(String fileName);
}
