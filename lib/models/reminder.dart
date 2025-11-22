import 'package:hive/hive.dart';

part 'reminder.g.dart';

/// Data model for movie watch reminders
/// Stores information about scheduled notifications for movies
@HiveType(typeId: 1)
class Reminder extends HiveObject {
  /// Unique identifier for the reminder
  @HiveField(0)
  final String id;

  /// ID of the watchlist item this reminder is for
  @HiveField(1)
  final String watchlistItemId;

  /// Movie title for display purposes
  @HiveField(2)
  final String movieTitle;

  /// Movie poster URL for notification
  @HiveField(3)
  final String? moviePosterUrl;

  /// Scheduled date and time for the reminder
  @HiveField(4)
  final DateTime scheduledDateTime;

  /// Timezone identifier (e.g., 'America/New_York')
  @HiveField(5)
  final String timezone;

  /// Whether the notification has been sent
  @HiveField(6)
  final bool isCompleted;

  /// When this reminder was created
  @HiveField(7)
  final DateTime createdAt;

  /// Local notification ID for cancellation
  @HiveField(8)
  final int notificationId;

  Reminder({
    required this.id,
    required this.watchlistItemId,
    required this.movieTitle,
    this.moviePosterUrl,
    required this.scheduledDateTime,
    required this.timezone,
    this.isCompleted = false,
    required this.createdAt,
    required this.notificationId,
  });

  /// Create a copy of this reminder with updated fields
  Reminder copyWith({
    String? id,
    String? watchlistItemId,
    String? movieTitle,
    String? moviePosterUrl,
    DateTime? scheduledDateTime,
    String? timezone,
    bool? isCompleted,
    DateTime? createdAt,
    int? notificationId,
  }) {
    return Reminder(
      id: id ?? this.id,
      watchlistItemId: watchlistItemId ?? this.watchlistItemId,
      movieTitle: movieTitle ?? this.movieTitle,
      moviePosterUrl: moviePosterUrl ?? this.moviePosterUrl,
      scheduledDateTime: scheduledDateTime ?? this.scheduledDateTime,
      timezone: timezone ?? this.timezone,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      notificationId: notificationId ?? this.notificationId,
    );
  }

  /// Convert to JSON for debugging/logging
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'watchlistItemId': watchlistItemId,
      'movieTitle': movieTitle,
      'moviePosterUrl': moviePosterUrl,
      'scheduledDateTime': scheduledDateTime.toIso8601String(),
      'timezone': timezone,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'notificationId': notificationId,
    };
  }

  /// Create from JSON
  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      watchlistItemId: json['watchlistItemId'] as String,
      movieTitle: json['movieTitle'] as String,
      moviePosterUrl: json['moviePosterUrl'] as String?,
      scheduledDateTime: DateTime.parse(json['scheduledDateTime'] as String),
      timezone: json['timezone'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      notificationId: json['notificationId'] as int,
    );
  }

  @override
  String toString() {
    return 'Reminder(id: $id, movieTitle: $movieTitle, scheduledDateTime: $scheduledDateTime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Reminder && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
