import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock_achievement_repository.dart';
import '../../domain/achievement.dart';
import '../../domain/achievement_repository.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

final achievementRepositoryProvider = Provider<AchievementRepository>((ref) {
  return MockAchievementRepository();
});

final userAchievementsProvider = FutureProvider.family<List<Achievement>, String>((ref, userId) async {
  final repo = ref.watch(achievementRepositoryProvider);
  return repo.getUserAchievements(userId);
});

final myAchievementsProvider = FutureProvider<List<Achievement>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final repo = ref.watch(achievementRepositoryProvider);
  return repo.getUserAchievements(user.id);
});
