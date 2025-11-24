import 'package:firebase_database/firebase_database.dart';

/// Service to manage tab visibility and button visibility from Firebase Realtime Database
class TabVisibilityService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  /// Get the visibility status for all tabs
  /// Returns a Map with keys: 'aiHub', 'movies', 'tv', 'watchlist', 'settings'
  /// Each value is a boolean indicating if the tab should be visible
  Stream<Map<String, bool>> getTabVisibilityStream() {
    return _database.child('tabVisibility').onValue.map((event) {
      if (event.snapshot.value == null) {
        // Default: TV tab hidden, others visible
        return {
          'aiHub': true,
          'movies': true,
          'tv': false,
          'watchlist': true,
          'settings': true,
        };
      }

      final data = event.snapshot.value as Map<dynamic, dynamic>;
      return {
        'aiHub': data['aiHub'] ?? true,
        'movies': data['movies'] ?? true,
        'tv': data['tv'] ?? false,
        'watchlist': data['watchlist'] ?? true,
        'settings': data['settings'] ?? true,
      };
    });
  }

  /// Get the visibility status for buttons in details screen
  /// Returns a Map with keys: 'watchTrailer', 'watchMovie', 'watchSeries'
  /// Each value is a boolean indicating if the button should be visible
  Stream<Map<String, bool>> getButtonVisibilityStream() {
    return _database.child('buttonVisibility').onValue.map((event) {
      if (event.snapshot.value == null) {
        // Default: all buttons visible
        return {
          'watchTrailer': true,
          'watchMovie': true,
          'watchSeries': true,
          'setReminder': true,
          'addToWatchlist': true,
        };
      }

      final data = event.snapshot.value as Map<dynamic, dynamic>;
      return {
        'watchTrailer': data['watchTrailer'] ?? true,
        'watchMovie': data['watchMovie'] ?? true,
        'watchSeries': data['watchSeries'] ?? true,
        'setReminder': data['setReminder'] ?? true,
        'addToWatchlist': data['addToWatchlist'] ?? true,
      };
    });
  }

  /// Get the current visibility status (one-time read)
  Future<Map<String, bool>> getTabVisibility() async {
    try {
      final snapshot = await _database.child('tabVisibility').get();

      if (!snapshot.exists) {
        // Default: TV tab hidden, others visible
        return {
          'aiHub': true,
          'movies': true,
          'tv': false,
          'watchlist': true,
          'settings': true,
        };
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      return {
        'aiHub': data['aiHub'] ?? true,
        'movies': data['movies'] ?? true,
        'tv': data['tv'] ?? false,
        'watchlist': data['watchlist'] ?? true,
        'settings': data['settings'] ?? true,
      };
    } catch (e) {
      // On error, return TV hidden, others visible
      return {
        'aiHub': true,
        'movies': true,
        'tv': false,
        'watchlist': true,
        'settings': true,
      };
    }
  }

  /// Get the current button visibility status (one-time read)
  Future<Map<String, bool>> getButtonVisibility() async {
    try {
      final snapshot = await _database.child('buttonVisibility').get();

      if (!snapshot.exists) {
        // Default: all buttons visible
        return {
          'watchTrailer': true,
          'watchMovie': true,
          'watchSeries': true,
          'setReminder': true,
          'addToWatchlist': true,
        };
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      return {
        'watchTrailer': data['watchTrailer'] ?? true,
        'watchMovie': data['watchMovie'] ?? true,
        'watchSeries': data['watchSeries'] ?? true,
        'setReminder': data['setReminder'] ?? true,
        'addToWatchlist': data['addToWatchlist'] ?? true,
      };
    } catch (e) {
      // On error, return all visible
      return {
        'watchTrailer': true,
        'watchMovie': true,
        'watchSeries': true,
        'setReminder': true,
        'addToWatchlist': true,
      };
    }
  }

  /// Update visibility for a specific tab (useful for admin panel)
  Future<void> updateTabVisibility(String tabName, bool isVisible) async {
    try {
      await _database.child('tabVisibility/$tabName').set(isVisible);
    } catch (e) {
      throw Exception('Failed to update tab visibility: $e');
    }
  }

  /// Update visibility for a specific button (useful for admin panel)
  Future<void> updateButtonVisibility(String buttonName, bool isVisible) async {
    try {
      await _database.child('buttonVisibility/$buttonName').set(isVisible);
    } catch (e) {
      throw Exception('Failed to update button visibility: $e');
    }
  }
}
