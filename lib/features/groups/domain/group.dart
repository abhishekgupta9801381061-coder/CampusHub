import 'package:equatable/equatable.dart';

class Group extends Equatable {
  final String id;
  final String name;
  final String description;
  final String category;
  final List<String> tags;
  final String creatorId;
  final String creatorHandle;
  final int memberCount;
  final DateTime createdAt;

  const Group({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.tags = const [],
    required this.creatorId,
    required this.creatorHandle,
    this.memberCount = 1,
    required this.createdAt,
  });

  Group copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    List<String>? tags,
    String? creatorId,
    String? creatorHandle,
    int? memberCount,
    DateTime? createdAt,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      creatorId: creatorId ?? this.creatorId,
      creatorHandle: creatorHandle ?? this.creatorHandle,
      memberCount: memberCount ?? this.memberCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'tags': tags,
      'creator_id': creatorId,
      'creator_handle': creatorHandle,
      'member_count': memberCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      creatorId: json['creator_id'] as String,
      creatorHandle: json['creator_handle'] as String,
      memberCount: json['member_count'] as int? ?? 1,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        tags,
        creatorId,
        creatorHandle,
        memberCount,
        createdAt,
      ];
}

class GroupMember extends Equatable {
  final String id;
  final String groupId;
  final String userId;
  final String userName;
  final String userHandle;
  final String userBranch;
  final String userHostel; // NO room number!
  final String role; // 'admin' or 'member'
  final DateTime joinedAt;

  const GroupMember({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.userName,
    required this.userHandle,
    required this.userBranch,
    required this.userHostel,
    required this.role,
    required this.joinedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'user_id': userId,
      'user_name': userName,
      'user_handle': userHandle,
      'user_branch': userBranch,
      'user_hostel': userHostel,
      'role': role,
      'joined_at': joinedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        groupId,
        userId,
        userName,
        userHandle,
        userBranch,
        userHostel,
        role,
        joinedAt,
      ];
}
