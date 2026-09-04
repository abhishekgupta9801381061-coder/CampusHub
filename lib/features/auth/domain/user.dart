import 'package:equatable/equatable.dart';

/// Freshmen User domain model.
/// STRICT PRIVACY GUARANTEE:
/// - Never includes Phone Number
/// - Never includes Email
/// - Never includes Room Number (only university hostel)
/// - Never includes Password or Security Answer
class User extends Equatable {
  final String id;
  final String name;
  final String handle;
  final String rollNo;
  final String branch;
  final String hostel;
  final String? avatarUrl;
  final bool isGhostMode;
  final bool allowPromotionalConsent;
  final List<String> skills;
  final List<String> interests;
  final String? whatsappOptional;
  final String? instagramOptional;
  final String? linkedinOptional;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.handle,
    required this.rollNo,
    required this.branch,
    required this.hostel,
    this.avatarUrl,
    this.isGhostMode = false,
    this.allowPromotionalConsent = false,
    this.skills = const [],
    this.interests = const [],
    this.whatsappOptional,
    this.instagramOptional,
    this.linkedinOptional,
    required this.createdAt,
  });

  User copyWith({
    String? id,
    String? name,
    String? handle,
    String? rollNo,
    String? branch,
    String? hostel,
    String? avatarUrl,
    bool? isGhostMode,
    bool? allowPromotionalConsent,
    List<String>? skills,
    List<String>? interests,
    String? whatsappOptional,
    String? instagramOptional,
    String? linkedinOptional,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      handle: handle ?? this.handle,
      rollNo: rollNo ?? this.rollNo,
      branch: branch ?? this.branch,
      hostel: hostel ?? this.hostel,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isGhostMode: isGhostMode ?? this.isGhostMode,
      allowPromotionalConsent: allowPromotionalConsent ?? this.allowPromotionalConsent,
      skills: skills ?? this.skills,
      interests: interests ?? this.interests,
      whatsappOptional: whatsappOptional ?? this.whatsappOptional,
      instagramOptional: instagramOptional ?? this.instagramOptional,
      linkedinOptional: linkedinOptional ?? this.linkedinOptional,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'handle': handle,
      'roll_no': rollNo,
      'branch': branch,
      'hostel': hostel,
      'avatar_url': avatarUrl,
      'is_ghost_mode': isGhostMode,
      'allow_promotional_consent': allowPromotionalConsent,
      'skills': skills,
      'interests': interests,
      'whatsapp_optional': whatsappOptional,
      'instagram_optional': instagramOptional,
      'linkedin_optional': linkedinOptional,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      handle: json['handle'] as String,
      rollNo: json['roll_no'] as String,
      branch: json['branch'] as String,
      hostel: json['hostel'] as String,
      avatarUrl: json['avatar_url'] as String?,
      isGhostMode: json['is_ghost_mode'] as bool? ?? false,
      allowPromotionalConsent: json['allow_promotional_consent'] as bool? ?? false,
      skills: (json['skills'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      interests: (json['interests'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      whatsappOptional: json['whatsapp_optional'] as String?,
      instagramOptional: json['instagram_optional'] as String?,
      linkedinOptional: json['linkedin_optional'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        handle,
        rollNo,
        branch,
        hostel,
        avatarUrl,
        isGhostMode,
        allowPromotionalConsent,
        skills,
        interests,
        whatsappOptional,
        instagramOptional,
        linkedinOptional,
        createdAt,
      ];
}
