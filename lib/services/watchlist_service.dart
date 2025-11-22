import 'package:shared_preferences/shared_preferences.dart';

class WatchlistService {
  static const _key = 'watchlist_keys';

  Future<Set<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? const [];
    return list.toSet();
  }

  Future<void> save(Set<String> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, items.toList());
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
