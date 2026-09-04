import 'social_bridge_link.dart';

abstract class SocialBridgeRepository {
  Future<List<SocialBridgeLink>> getActiveLinks(String userId);
  Future<SocialBridgeLink> generateTemporaryLink({
    required String userId,
    required String platform,
    required Duration duration,
  });
  Future<void> revokeLink(String linkId);
}
