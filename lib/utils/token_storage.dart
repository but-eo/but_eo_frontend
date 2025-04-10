
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static Future<void> saveTokens(String accessToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);

    //JWT 디코딩해서 userId 추출
    Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);
    String userId = decodedToken['sub'];

    //userId로 저장
    await prefs.setString('userId', userId);
    print("userId 저장 : $userId");
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('userId');
  }

}