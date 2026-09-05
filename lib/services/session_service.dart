import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';

  static Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_userIdKey, user['id']);
    await prefs.setString(_userNameKey, user['name']);
    await prefs.setString(_userEmailKey, user['email']);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.containsKey(_userIdKey);
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();

    final id = prefs.getInt(_userIdKey);
    final name = prefs.getString(_userNameKey);
    final email = prefs.getString(_userEmailKey);

    if (id == null || name == null || email == null) {
      return null;
    }

    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
  }
}