import 'package:equatable/equatable.dart';

class SocialBridgeLink extends Equatable {
  final String id;
  final String userId;
  final String platform; // 'WhatsApp', 'Instagram', 'Discord'
  final String token;
  final String shareUrl;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isRevoked;

  const SocialBridgeLink({
    required this.id,
    required this.userId,
    required this.platform,
    required this.token,
    required this.shareUrl,
    required this.createdAt,
    required this.expiresAt,
    this.isRevoked = false,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt) || isRevoked;

  @override
  List<Object?> get props => [id, userId, platform, token, shareUrl, createdAt, expiresAt, isRevoked];
}
