import 'package:shared_preferences/shared_preferences.dart';

class CompanyStorage {
  static const String _key = 'companyNumbers';

  static Future<void> saveCompanyNumbers(Map<String, String> numbers) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_key, numbers.entries.map((e) => '${e.key}|${e.value}').join(','));
  }

  static Future<Map<String, String>> loadCompanyNumbers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key) ?? '';
    if (raw.isEmpty) return {};
    final map = <String, String>{};
    for (final pair in raw.split(',')) {
      final parts = pair.split('|');
      if (parts.length == 2) {
        map[parts[0]] = parts[1];
      }
    }
    return map;
  }
}
