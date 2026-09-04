import 'package:equatable/equatable.dart';

class Contest extends Equatable {
  final String id;
  final String title;
  final String organizer;
  final DateTime eventDate;
  final DateTime deadline;
  final String mode; // 'Online', 'On-Campus', 'Hybrid'
  final List<String> tags;
  final String description;
  final String prizePool;
  final String registrationUrl;
  final bool isBookmarked;

  const Contest({
    required this.id,
    required this.title,
    required this.organizer,
    required this.eventDate,
    required this.deadline,
    required this.mode,
    this.tags = const [],
    required this.description,
    required this.prizePool,
    required this.registrationUrl,
    this.isBookmarked = false,
  });

  Contest copyWith({
    String? id,
    String? title,
    String? organizer,
    DateTime? eventDate,
    DateTime? deadline,
    String? mode,
    List<String>? tags,
    String? description,
    String? prizePool,
    String? registrationUrl,
    bool? isBookmarked,
  }) {
    return Contest(
      id: id ?? this.id,
      title: title ?? this.title,
      organizer: organizer ?? this.organizer,
      eventDate: eventDate ?? this.eventDate,
      deadline: deadline ?? this.deadline,
      mode: mode ?? this.mode,
      tags: tags ?? this.tags,
      description: description ?? this.description,
      prizePool: prizePool ?? this.prizePool,
      registrationUrl: registrationUrl ?? this.registrationUrl,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'organizer': organizer,
      'event_date': eventDate.toIso8601String(),
      'deadline': deadline.toIso8601String(),
      'mode': mode,
      'tags': tags,
      'description': description,
      'prize_pool': prizePool,
      'registration_url': registrationUrl,
      'is_bookmarked': isBookmarked,
    };
  }

  factory Contest.fromJson(Map<String, dynamic> json) {
    return Contest(
      id: json['id'] as String,
      title: json['title'] as String,
      organizer: json['organizer'] as String,
      eventDate: DateTime.parse(json['event_date'] as String),
      deadline: DateTime.parse(json['deadline'] as String),
      mode: json['mode'] as String,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      description: json['description'] as String,
      prizePool: json['prize_pool'] as String,
      registrationUrl: json['registration_url'] as String,
      isBookmarked: json['is_bookmarked'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        organizer,
        eventDate,
        deadline,
        mode,
        tags,
        description,
        prizePool,
        registrationUrl,
        isBookmarked,
      ];
}
