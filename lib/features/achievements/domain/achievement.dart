import 'package:equatable/equatable.dart';

class Achievement extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String category; // 'Hackathon', 'Certificate', 'Competition', 'Project'
  final String? proofUrl;
  final String status; // 'pending', 'verified', 'rejected'
  final DateTime createdAt;

  const Achievement({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    this.proofUrl,
    this.status = 'pending',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'category': category,
      'proof_url': proofUrl,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      proofUrl: json['proof_url'] as String?,
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  List<Object?> get props => [id, userId, title, description, category, proofUrl, status, createdAt];
}
