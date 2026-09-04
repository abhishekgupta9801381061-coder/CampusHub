import 'package:equatable/equatable.dart';

class Confession extends Equatable {
  final String id;
  final String category; // #General, #CSE, #ECE, #ME, #Civil, #Hostel
  final String content;
  final int upvotes;
  final int downvotes;
  final int commentCount;
  final DateTime createdAt;
  final bool hasUpvoted;
  final bool hasDownvoted;
  final String? privateAuthorToken; // Stored securely on client to allow deleting own post anonymously

  const Confession({
    required this.id,
    required this.category,
    required this.content,
    this.upvotes = 0,
    this.downvotes = 0,
    this.commentCount = 0,
    required this.createdAt,
    this.hasUpvoted = false,
    this.hasDownvoted = false,
    this.privateAuthorToken,
  });

  Confession copyWith({
    String? id,
    String? category,
    String? content,
    int? upvotes,
    int? downvotes,
    int? commentCount,
    DateTime? createdAt,
    bool? hasUpvoted,
    bool? hasDownvoted,
    String? privateAuthorToken,
  }) {
    return Confession(
      id: id ?? this.id,
      category: category ?? this.category,
      content: content ?? this.content,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt ?? this.createdAt,
      hasUpvoted: hasUpvoted ?? this.hasUpvoted,
      hasDownvoted: hasDownvoted ?? this.hasDownvoted,
      privateAuthorToken: privateAuthorToken ?? this.privateAuthorToken,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'content': content,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'comment_count': commentCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Confession.fromJson(Map<String, dynamic> json) {
    return Confession(
      id: json['id'] as String,
      category: json['category'] as String,
      content: json['content'] as String,
      upvotes: json['upvotes'] as int? ?? 0,
      downvotes: json['downvotes'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        category,
        content,
        upvotes,
        downvotes,
        commentCount,
        createdAt,
        hasUpvoted,
        hasDownvoted,
      ];
}

class ConfessionComment extends Equatable {
  final String id;
  final String confessionId;
  final String content;
  final DateTime createdAt;

  const ConfessionComment({
    required this.id,
    required this.confessionId,
    required this.content,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, confessionId, content, createdAt];
}
