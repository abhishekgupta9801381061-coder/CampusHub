import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock_social_bridge_repository.dart';
import '../../domain/social_bridge_link.dart';
import '../../domain/social_bridge_repository.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

final socialBridgeRepositoryProvider = Provider<SocialBridgeRepository>((ref) {
  return MockSocialBridgeRepository();
});

final activeSocialBridgeLinksProvider = FutureProvider<List<SocialBridgeLink>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final repo = ref.watch(socialBridgeRepositoryProvider);
  return repo.getActiveLinks(user.id);
});
