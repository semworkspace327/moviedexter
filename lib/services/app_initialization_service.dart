import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import '../models/reminder.dart';
import 'notification_service.dart';
import 'reminder_service.dart';

/// Service responsible for initializing all app services and dependencies
/// Handles Hive, notifications, timezone, and other core services
class AppInitializationService {
  static final AppInitializationService _instance = AppInitializationService._internal();
  factory AppInitializationService() => _instance;
  AppInitializationService._internal();

  bool _isInitialized = false;
  
  final NotificationService _notificationService = NotificationService();
  final ReminderService _reminderService = ReminderService();

  /// Initialize all app services
  /// Call this in main() before runApp()
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      debugPrint('AppInitializationService: Starting initialization...');

      // Initialize Hive
      await _initializeHive();
      
      // Initialize timezone data
      tz.initializeTimeZones();
      
      // Initialize notification service
      final notificationInitialized = await _notificationService.initialize();
      if (!notificationInitialized) {
        debugPrint('AppInitializationService: Failed to initialize notifications');
        return false;
      }

      // Request notification permissions
      await _notificationService.requestPermissions();

      // Initialize reminder service
      final reminderInitialized = await _reminderService.initialize();
      if (!reminderInitialized) {
        debugPrint('AppInitializationService: Failed to initialize reminder service');
        return false;
      }

      // Set up notification tap handler
      NotificationService.onNotificationTapped = _handleNotificationTap;

      // Restore existing reminders (reschedule notifications if needed)
      await _restoreExistingReminders();

      _isInitialized = true;
      debugPrint('AppInitializationService: Successfully initialized all services');
      return true;
    } catch (e) {
      debugPrint('AppInitializationService: Error during initialization: $e');
      return false;
    }
  }

  /// Initialize Hive database
  Future<void> _initializeHive() async {
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ReminderAdapter());
    }
    
    debugPrint('AppInitializationService: Hive initialized');
  }

  /// Restore existing reminders and reschedule notifications if needed
  Future<void> _restoreExistingReminders() async {
    try {
      final reminders = _reminderService.getAllReminders();
      final now = DateTime.now();
      int restoredCount = 0;

      for (final reminder in reminders) {
        // Only reschedule future reminders
        if (reminder.scheduledDateTime.isAfter(now) && !reminder.isCompleted) {
          final success = await _notificationService.scheduleReminder(reminder);
          if (success) {
            restoredCount++;
          }
        }
      }

      debugPrint('AppInitializationService: Restored $restoredCount reminders');
    } catch (e) {
      debugPrint('AppInitializationService: Error restoring reminders: $e');
    }
  }

  /// Handle notification tap - navigate to movie details
  void _handleNotificationTap(String? payload) {
    if (payload != null) {
      debugPrint('AppInitializationService: Notification tapped for movie: $payload');
      // TODO: Implement deep linking to movie details page
      // This would typically use GoRouter or Navigator to navigate to the movie
      // For now, we'll just log it
    }
  }

  /// Get initialization status
  bool get isInitialized => _isInitialized;

  /// Get service instances (for dependency injection)
  NotificationService get notificationService => _notificationService;
  ReminderService get reminderService => _reminderService;

  /// Cleanup resources when app is disposed
  Future<void> dispose() async {
    await _reminderService.dispose();
    await Hive.close();
    _isInitialized = false;
    debugPrint('AppInitializationService: Disposed all services');
  }
}
