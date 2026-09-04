import 'package:uuid/uuid.dart';
import '../domain/social_bridge_link.dart';
import '../domain/social_bridge_repository.dart';

class MockSocialBridgeRepository implements SocialBridgeRepository {
  final List<SocialBridgeLink> _links = [];

  @override
  Future<List<SocialBridgeLink>> getActiveLinks(String userId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final now = DateTime.now();
    return _links.where((l) => l.userId == userId && !l.isRevoked && l.expiresAt.isAfter(now)).toList();
  }

  @override
  Future<SocialBridgeLink> generateTemporaryLink({
    required String userId,
    required String platform,
    required Duration duration,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final token = const Uuid().v4().substring(0, 8);
    final now = DateTime.now();
    final link = SocialBridgeLink(
      id: const Uuid().v4(),
      userId: userId,
      platform: platform,
      token: token,
      shareUrl: 'https://campushub.me/bridge/$platform/$token',
      createdAt: now,
      expiresAt: now.add(duration),
    );
    _links.add(link);
    return link;
  }

  @override
  Future<void> revokeLink(String linkId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _links.indexWhere((l) => l.id == linkId);
    if (index != -1) {
      final existing = _links[index];
      _links[index] = SocialBridgeLink(
        id: existing.id,
        userId: existing.userId,
        platform: existing.platform,
        token: existing.token,
        shareUrl: existing.shareUrl,
        createdAt: existing.createdAt,
        expiresAt: existing.expiresAt,
        isRevoked: true,
      );
    }
  }
}
