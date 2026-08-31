import 'package:shared_preferences/shared_preferences.dart';

class AddressService {
  static const String _key = 'delivery_address';

  static String _address =
      'Av. Primero de Mayo 1234, La Calera';

  static String get address => _address;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    _address = prefs.getString(_key) ??
        'Av. Primero de Mayo 1234, La Calera';
  }

  static Future<void> save(String address) async {
    _address = address;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_key, address);
  }
}