import 'package:shared_preferences/shared_preferences.dart';

class RentStorage {
  static const String _key = 'recurring_rent';

  static Future<void> saveRent(double rent) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_key, rent);
  }

  static Future<double> loadRent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_key) ?? 0;
  }
}
