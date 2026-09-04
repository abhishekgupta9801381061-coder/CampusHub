import 'package:equatable/equatable.dart';
import '../../../core/constants/app_constants.dart';

class PartnerRequest extends Equatable {
  final String id;
  final String authorId;
  final String authorName;
  final String authorHandle;
  final String authorBranch;
  final String authorHostel;
  final String type;
  final String title;
  final String description;
  final List<String> tags;
  final DateTime createdAt;
  final int editCount;
  final DateTime? lastEditedAt;
  final bool isClosed;
  final int reportCount;

  const PartnerRequest({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorHandle,
    required this.authorBranch,
    required this.authorHostel,
    required this.type,
    required this.title,
    required this.description,
    this.tags = const [],
    required this.createdAt,
    this.editCount = 0,
    this.lastEditedAt,
    this.isClosed = false,
    this.reportCount = 0,
  });

  /// 5-day expiration rule
  DateTime get expiryDate => createdAt.add(const Duration(days: AppConstants.partnerRequestExpiryDays));

  bool get isExpired => DateTime.now().isAfter(expiryDate);

  PartnerRequest copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorHandle,
    String? authorBranch,
    String? authorHostel,
    String? type,
    String? title,
    String? description,
    List<String>? tags,
    DateTime? createdAt,
    int? editCount,
    DateTime? lastEditedAt,
    bool? isClosed,
    int? reportCount,
  }) {
    return PartnerRequest(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorHandle: authorHandle ?? this.authorHandle,
      authorBranch: authorBranch ?? this.authorBranch,
      authorHostel: authorHostel ?? this.authorHostel,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      editCount: editCount ?? this.editCount,
      lastEditedAt: lastEditedAt ?? this.lastEditedAt,
      isClosed: isClosed ?? this.isClosed,
      reportCount: reportCount ?? this.reportCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author_id': authorId,
      'author_name': authorName,
      'author_handle': authorHandle,
      'author_branch': authorBranch,
      'author_hostel': authorHostel,
      'type': type,
      'title': title,
      'description': description,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'edit_count': editCount,
      'last_edited_at': lastEditedAt?.toIso8601String(),
      'is_closed': isClosed,
      'report_count': reportCount,
    };
  }

  factory PartnerRequest.fromJson(Map<String, dynamic> json) {
    return PartnerRequest(
      id: json['id'] as String,
      authorId: json['author_id'] as String,
      authorName: json['author_name'] as String,
      authorHandle: json['author_handle'] as String,
      authorBranch: json['author_branch'] as String,
      authorHostel: json['author_hostel'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      createdAt: DateTime.parse(json['created_at'] as String),
      editCount: json['edit_count'] as int? ?? 0,
      lastEditedAt: json['last_edited_at'] != null ? DateTime.parse(json['last_edited_at'] as String) : null,
      isClosed: json['is_closed'] as bool? ?? false,
      reportCount: json['report_count'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        id,
        authorId,
        authorName,
        authorHandle,
        authorBranch,
        authorHostel,
        type,
        title,
        description,
        tags,
        createdAt,
        editCount,
        lastEditedAt,
        isClosed,
        reportCount,
      ];
}
