import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  static const String _key = 'favorite_restaurants';

  static final Set<int> _restaurantIds = {};

  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  static bool isFavorite(int restaurantId) {
    return _restaurantIds.contains(restaurantId);
  }

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final savedIds = prefs.getStringList(_key) ?? [];

    _restaurantIds
      ..clear()
      ..addAll(
        savedIds.map((id) => int.parse(id)),
      );
  }

  static Future<void> toggle(int restaurantId) async {
    if (_restaurantIds.contains(restaurantId)) {
      _restaurantIds.remove(restaurantId);
    } else {
      _restaurantIds.add(restaurantId);
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(
      _key,
      _restaurantIds.map((id) => id.toString()).toList(),
    );

    changes.value++;
  }

  static List<int> get restaurantIds {
    return _restaurantIds.toList();
  }

  static Future<void> clear() async {
    _restaurantIds.clear();

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_key);

    changes.value++;
  }
}