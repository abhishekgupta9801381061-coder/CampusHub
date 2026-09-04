import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock_confession_repository.dart';
import '../../domain/confession.dart';
import '../../domain/confession_repository.dart';

final confessionRepositoryProvider = Provider<ConfessionRepository>((ref) {
  return MockConfessionRepository();
});

final confessionCategoryFilterProvider = StateProvider<String>((ref) => '#All');

final confessionsFeedProvider = FutureProvider<List<Confession>>((ref) async {
  final repo = ref.watch(confessionRepositoryProvider);
  final category = ref.watch(confessionCategoryFilterProvider);
  return repo.getConfessions(category: category == '#All' ? null : category);
});
