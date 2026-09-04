import 'package:uuid/uuid.dart';
import '../domain/achievement.dart';
import '../domain/achievement_repository.dart';

class MockAchievementRepository implements AchievementRepository {
  final List<Achievement> _achievements = [];

  MockAchievementRepository() {
    _seedData();
  }

  void _seedData() {
    final now = DateTime.now();
    _achievements.addAll([
      Achievement(
        id: 'ach-01',
        userId: 'usr-freshman-01',
        title: '1st Runner Up - Freshmen Hackathon 2026',
        description: 'Developed CampusHub Flutter MVP in 24 hours focusing on student data privacy.',
        category: 'Hackathon',
        status: 'verified',
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      Achievement(
        id: 'ach-02',
        userId: 'usr-freshman-01',
        title: 'Dean’s Honor Roll - Semester Entrance Rank #4',
        description: 'Admitted in top 0.1% percentile of CS department applicants.',
        category: 'Competition',
        status: 'verified',
        createdAt: now.subtract(const Duration(days: 25)),
      ),
      Achievement(
        id: 'ach-03',
        userId: 'usr-freshman-02',
        title: 'Google Cloud Skills Boost Badge - Generative AI',
        description: 'Completed foundational generative AI and Vertex AI modules.',
        category: 'Certificate',
        status: 'verified',
        createdAt: now.subtract(const Duration(days: 12)),
      ),
    ]);
  }

  @override
  Future<List<Achievement>> getUserAchievements(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _achievements.where((a) => a.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<Achievement> submitAchievement({
    required String userId,
    required String title,
    required String description,
    required String category,
    String? proofUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newAchievement = Achievement(
      id: const Uuid().v4(),
      userId: userId,
      title: title.trim(),
      description: description.trim(),
      category: category,
      proofUrl: proofUrl,
      status: 'pending', // Pending peer/admin verification
      createdAt: DateTime.now(),
    );
    _achievements.insert(0, newAchievement);
    return newAchievement;
  }

  @override
  Future<String> getSignedUploadUrl(String fileName) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Generates a mock time-limited signed S3/Supabase upload URL
    final token = const Uuid().v4();
    return 'https://storage.campushub.internal/signed-upload/$fileName?token=$token&expires=900';
  }
}
