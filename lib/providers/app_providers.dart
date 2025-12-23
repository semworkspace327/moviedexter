import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../services/watchlist_service.dart';
import '../services/tab_visibility_service.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

final watchlistProvider = StateNotifierProvider<WatchlistNotifier, Set<String>>(
  (ref) => WatchlistNotifier(),
);

// Tab visibility provider - streams visibility settings from Firebase
final tabVisibilityProvider = StreamProvider<Map<String, bool>>((ref) {
  final service = TabVisibilityService();
  return service.getTabVisibilityStream();
});

// Button visibility provider - streams button visibility settings from Firebase
final buttonVisibilityProvider = StreamProvider<Map<String, bool>>((ref) {
  final service = TabVisibilityService();
  return service.getButtonVisibilityStream();
});

// Tab visibility service provider
final tabVisibilityServiceProvider = Provider<TabVisibilityService>((ref) {
  return TabVisibilityService();
});

class WatchlistNotifier extends StateNotifier<Set<String>> {
  WatchlistNotifier() : super({}) {
    _init();
  }
  final _service = WatchlistService();

  Future<void> _init() async {
    final loaded = await _service.load();
    state = loaded;
  }

  bool contains(String key) => state.contains(key);
  void toggle(String key) {
    if (state.contains(key)) {
      state = {...state}..remove(key);
    } else {
      state = {...state, key};
    }
    _service.save(state);
  }

  Future<void> clear() async {
    state = {};
    await _service.clear();
  }
}
