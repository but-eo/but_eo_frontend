
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static Future<void> saveTokens(String accessToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
    //await prefs.setString('userId', userId);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  // static Future<String?> getUserId() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getString('userId');
  // }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    //await prefs.remove('userId');
  }

}