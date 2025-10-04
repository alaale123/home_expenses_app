import 'package:shared_preferences/shared_preferences.dart';

class WalletStorage {
  static const String _key = 'recurring_wallet';

  static Future<void> saveWallet(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_key, amount);
  }

  static Future<double> loadWallet() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_key) ?? 0;
  }
}
