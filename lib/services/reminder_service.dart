import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/reminder.dart';
import 'notification_service.dart';

/// Service for managing movie watch reminders
/// Handles CRUD operations and integrates with notification service
class ReminderService {
  static final ReminderService _instance = ReminderService._internal();
  factory ReminderService() => _instance;
  ReminderService._internal();

  static const String _boxName = 'reminders';
  Box<Reminder>? _box;
  final NotificationService _notificationService = NotificationService();

  /// Initialize the reminder service
  /// Must be called before using any other methods
  Future<bool> initialize() async {
    try {
      // Initialize Hive if not already done
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(ReminderAdapter());
      }

      // Open the reminders box
      _box = await Hive.openBox<Reminder>(_boxName);
      
      // Clean up expired reminders on startup
      await _cleanupExpiredReminders();
      
      debugPrint('ReminderService: Successfully initialized');
      return true;
    } catch (e) {
      debugPrint('ReminderService: Error during initialization: $e');
      return false;
    }
  }

  /// Create a new reminder
  Future<bool> createReminder({
    required String watchlistItemId,
    required String movieTitle,
    String? moviePosterUrl,
    required DateTime scheduledDateTime,
    required String timezone,
  }) async {
    if (_box == null) {
      debugPrint('ReminderService: Not initialized');
      return false;
    }

    try {
      // Generate unique IDs
      final reminderId = _generateReminderId();
      final notificationId = NotificationService.generateNotificationId();

      // Create reminder object
      final reminder = Reminder(
        id: reminderId,
        watchlistItemId: watchlistItemId,
        movieTitle: movieTitle,
        moviePosterUrl: moviePosterUrl,
        scheduledDateTime: scheduledDateTime,
        timezone: timezone,
        createdAt: DateTime.now(),
        notificationId: notificationId,
      );

      // Schedule notification
      final notificationScheduled = await _notificationService.scheduleReminder(reminder);
      if (!notificationScheduled) {
        debugPrint('ReminderService: Failed to schedule notification');
        return false;
      }

      // Save to local storage
      await _box!.put(reminderId, reminder);
      
      debugPrint('ReminderService: Created reminder for $movieTitle');
      return true;
    } catch (e) {
      debugPrint('ReminderService: Error creating reminder: $e');
      return false;
    }
  }

  /// Get all reminders
  List<Reminder> getAllReminders() {
    if (_box == null) return [];
    return _box!.values.toList()..sort((a, b) => a.scheduledDateTime.compareTo(b.scheduledDateTime));
  }

  /// Get reminders for a specific movie
  List<Reminder> getRemindersForMovie(String watchlistItemId) {
    if (_box == null) return [];
    return _box!.values
        .where((reminder) => reminder.watchlistItemId == watchlistItemId)
        .toList()
      ..sort((a, b) => a.scheduledDateTime.compareTo(b.scheduledDateTime));
  }

  /// Get reminders for a specific date
  List<Reminder> getRemindersForDate(DateTime date) {
    if (_box == null) return [];
    
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return _box!.values
        .where((reminder) => 
            reminder.scheduledDateTime.isAfter(startOfDay) &&
            reminder.scheduledDateTime.isBefore(endOfDay))
        .toList()
      ..sort((a, b) => a.scheduledDateTime.compareTo(b.scheduledDateTime));
  }

  /// Update an existing reminder
  Future<bool> updateReminder(String reminderId, {
    DateTime? scheduledDateTime,
    String? timezone,
  }) async {
    if (_box == null) return false;

    try {
      final reminder = _box!.get(reminderId);
      if (reminder == null) {
        debugPrint('ReminderService: Reminder not found: $reminderId');
        return false;
      }

      // Cancel old notification
      await _notificationService.cancelReminder(reminder.notificationId);

      // Create updated reminder
      final updatedReminder = reminder.copyWith(
        scheduledDateTime: scheduledDateTime ?? reminder.scheduledDateTime,
        timezone: timezone ?? reminder.timezone,
      );

      // Schedule new notification
      final notificationScheduled = await _notificationService.scheduleReminder(updatedReminder);
      if (!notificationScheduled) {
        debugPrint('ReminderService: Failed to reschedule notification');
        return false;
      }

      // Update in storage
      await _box!.put(reminderId, updatedReminder);
      
      debugPrint('ReminderService: Updated reminder $reminderId');
      return true;
    } catch (e) {
      debugPrint('ReminderService: Error updating reminder: $e');
      return false;
    }
  }

  /// Delete a reminder
  Future<bool> deleteReminder(String reminderId) async {
    if (_box == null) return false;

    try {
      final reminder = _box!.get(reminderId);
      if (reminder == null) {
        debugPrint('ReminderService: Reminder not found: $reminderId');
        return false;
      }

      // Cancel notification
      await _notificationService.cancelReminder(reminder.notificationId);

      // Remove from storage
      await _box!.delete(reminderId);
      
      debugPrint('ReminderService: Deleted reminder $reminderId');
      return true;
    } catch (e) {
      debugPrint('ReminderService: Error deleting reminder: $e');
      return false;
    }
  }

  /// Delete all reminders for a specific movie
  Future<bool> deleteRemindersForMovie(String watchlistItemId) async {
    if (_box == null) return false;

    try {
      final reminders = getRemindersForMovie(watchlistItemId);
      
      for (final reminder in reminders) {
        await _notificationService.cancelReminder(reminder.notificationId);
        await _box!.delete(reminder.id);
      }
      
      debugPrint('ReminderService: Deleted ${reminders.length} reminders for movie $watchlistItemId');
      return true;
    } catch (e) {
      debugPrint('ReminderService: Error deleting reminders for movie: $e');
      return false;
    }
  }

  /// Check if a movie has any reminders
  bool hasRemindersForMovie(String watchlistItemId) {
    return getRemindersForMovie(watchlistItemId).isNotEmpty;
  }

  /// Get the next upcoming reminder for a movie
  Reminder? getNextReminderForMovie(String watchlistItemId) {
    final reminders = getRemindersForMovie(watchlistItemId);
    final now = DateTime.now();
    
    final upcomingReminders = reminders
        .where((reminder) => reminder.scheduledDateTime.isAfter(now))
        .toList();
    
    return upcomingReminders.isNotEmpty ? upcomingReminders.first : null;
  }

  /// Clean up expired reminders
  Future<void> _cleanupExpiredReminders() async {
    if (_box == null) return;

    try {
      final now = DateTime.now();
      final expiredReminders = _box!.values
          .where((reminder) => reminder.scheduledDateTime.isBefore(now))
          .toList();

      for (final reminder in expiredReminders) {
        await _box!.delete(reminder.id);
      }

      if (expiredReminders.isNotEmpty) {
        debugPrint('ReminderService: Cleaned up ${expiredReminders.length} expired reminders');
      }
    } catch (e) {
      debugPrint('ReminderService: Error cleaning up expired reminders: $e');
    }
  }

  /// Generate a unique reminder ID
  String _generateReminderId() {
    return 'reminder_${DateTime.now().millisecondsSinceEpoch}_${_box!.length}';
  }

  /// Get statistics about reminders
  Map<String, int> getStatistics() {
    if (_box == null) return {};

    final reminders = getAllReminders();
    final now = DateTime.now();
    
    return {
      'total': reminders.length,
      'upcoming': reminders.where((r) => r.scheduledDateTime.isAfter(now)).length,
      'completed': reminders.where((r) => r.isCompleted).length,
      'thisWeek': reminders.where((r) => 
          r.scheduledDateTime.isAfter(now) && 
          r.scheduledDateTime.isBefore(now.add(const Duration(days: 7)))).length,
    };
  }

  /// Export reminders for backup (JSON format)
  List<Map<String, dynamic>> exportReminders() {
    if (_box == null) return [];
    return getAllReminders().map((reminder) => reminder.toJson()).toList();
  }

  /// Validate reminder scheduling constraints
  bool canScheduleReminder(DateTime scheduledDateTime, String timezone) {
    try {
      final location = tz.getLocation(timezone);
      final scheduledDate = tz.TZDateTime.from(scheduledDateTime, location);
      final now = tz.TZDateTime.now(location);
      
      return scheduledDate.isAfter(now);
    } catch (e) {
      debugPrint('ReminderService: Error validating reminder: $e');
      return false;
    }
  }

  /// Close the service and cleanup resources
  Future<void> dispose() async {
    await _box?.close();
    _box = null;
  }
}
