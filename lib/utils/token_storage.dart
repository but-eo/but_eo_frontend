
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static Future<void> saveTokens(String accessToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);


    if (_isJwtFormat(accessToken)) {
      try{
        //JWT 디코딩해서 userId 추출
        Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);
        String userId = decodedToken['sub'];
        String? nickname = decodedToken['nickname'];

        //userId로 저장
        await prefs.setString('userId', userId);
      } catch(e) {
        print("jwt 디코딩 실패 $e");
      }
    }else {
      print("accessToken JWT 형식 아님 userId 저장 생략");
    }

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

  static Future<String?> getUserNickname() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userNickname');
  }

  static bool _isJwtFormat(String token) {
    return token.split('.').length == 3;
  }

}