import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/reminder.dart';

/// Service for managing local notifications and reminders
/// Handles scheduling, cancelling, and deep linking for movie reminders
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Callback for when notification is tapped
  static void Function(String?)? onNotificationTapped;

  /// Initialize the notification service
  /// Must be called before using any other methods
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Initialize timezone data
      tz.initializeTimeZones();

      // Android initialization settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize with callback for notification taps
      final initialized = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      if (initialized == true) {
        await _createNotificationChannel();
        _isInitialized = true;
        debugPrint('NotificationService: Successfully initialized');
        return true;
      }

      debugPrint('NotificationService: Failed to initialize');
      return false;
    } catch (e) {
      debugPrint('NotificationService: Error during initialization: $e');
      return false;
    }
  }

  /// Create Android notification channel
  Future<void> _createNotificationChannel() async {
    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        'movie_reminders',
        'Movie Reminders',
        description: 'Notifications for scheduled movie watch reminders',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      );

      await _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  /// Request notification permissions (iOS)
  Future<bool> requestPermissions() async {
    if (Platform.isIOS) {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    }
    return true; // Android permissions are handled in manifest
  }

  /// Schedule a notification for a movie reminder
  Future<bool> scheduleReminder(Reminder reminder) async {
    if (!_isInitialized) {
      debugPrint('NotificationService: Not initialized, cannot schedule reminder');
      return false;
    }

    try {
      // Convert to timezone-aware datetime
      final location = tz.getLocation(reminder.timezone);
      final scheduledDate = tz.TZDateTime.from(reminder.scheduledDateTime, location);

      // Check if the scheduled time is in the future
      if (scheduledDate.isBefore(tz.TZDateTime.now(location))) {
        debugPrint('NotificationService: Cannot schedule reminder in the past');
        return false;
      }

      // Create notification details
      final androidDetails = AndroidNotificationDetails(
        'movie_reminders',
        'Movie Reminders',
        channelDescription: 'Notifications for scheduled movie watch reminders',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        styleInformation: BigTextStyleInformation(
          'Time to watch "${reminder.movieTitle}"! Your scheduled movie time has arrived. Enjoy the show! 🍿',
          htmlFormatBigText: true,
          contentTitle: '🎬 Movie Reminder',
          htmlFormatContentTitle: true,
        ),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Schedule the notification
      await _notifications.zonedSchedule(
        reminder.notificationId,
        '🎬 Movie Reminder',
        'Time to watch "${reminder.movieTitle}"! Your scheduled movie time has arrived. Enjoy the show! 🍿',
        scheduledDate,
        notificationDetails,
        payload: reminder.watchlistItemId,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      debugPrint('NotificationService: Scheduled reminder for ${reminder.movieTitle} at $scheduledDate');
      return true;
    } catch (e) {
      debugPrint('NotificationService: Error scheduling reminder: $e');
      return false;
    }
  }

  /// Cancel a scheduled notification
  Future<bool> cancelReminder(int notificationId) async {
    if (!_isInitialized) return false;

    try {
      await _notifications.cancel(notificationId);
      debugPrint('NotificationService: Cancelled notification $notificationId');
      return true;
    } catch (e) {
      debugPrint('NotificationService: Error cancelling notification: $e');
      return false;
    }
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllReminders() async {
    if (!_isInitialized) return;

    try {
      await _notifications.cancelAll();
      debugPrint('NotificationService: Cancelled all notifications');
    } catch (e) {
      debugPrint('NotificationService: Error cancelling all notifications: $e');
    }
  }

  /// Get list of pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_isInitialized) return [];

    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      debugPrint('NotificationService: Error getting pending notifications: $e');
      return [];
    }
  }

  /// Generate a unique notification ID
  static int generateNotificationId() {
    return Random().nextInt(2147483647); // Max int32 value
  }

  /// Handle notification tap (static method for callback)
  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('NotificationService: Notification tapped with payload: ${response.payload}');
    onNotificationTapped?.call(response.payload);
  }

  /// Handle iOS foreground notifications (legacy)
  static void _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) {
    debugPrint('NotificationService: iOS foreground notification received');
    onNotificationTapped?.call(payload);
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    if (!_isInitialized) return false;

    if (Platform.isAndroid) {
      final androidImplementation = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      return await androidImplementation?.areNotificationsEnabled() ?? false;
    } else if (Platform.isIOS) {
      final iosImplementation = _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      final settings = await iosImplementation?.checkPermissions();
      return settings?.isEnabled ?? false;
    }

    return false;
  }

  /// Show immediate notification (for testing)
  Future<void> showTestNotification() async {
    if (!_isInitialized) return;

    const androidDetails = AndroidNotificationDetails(
      'movie_reminders',
      'Movie Reminders',
      channelDescription: 'Test notification',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      999999,
      '🎬 Movie Reminder',
      'Time to watch "The Matrix"! Your scheduled movie time has arrived. Enjoy the show! 🍿',
      notificationDetails,
    );
  }
}
