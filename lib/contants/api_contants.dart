import 'package:project/utils/token_storage.dart';

class ApiConstants {
  static const String baseUrl = 'http://192.168.0.185:714/api';
  static const String serverUrl ='192.168.0.185';
  static const String webSocketUrl = 'http://192.168.0.185';
  static const String webSocketConnectUrl = 'http://192.168.0.185:714';
  static const String imageBaseUrl = 'http://192.168.0.185:714';
  static const String googleApiKey = 'AIzaSyAsOKamrB2H8YIMFLEWMHHQb68HHRwhGfo';
  // 맥북 ip 명령어 ipconfig getifaddr en0
  //192.168.0.150

  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await TokenStorage.getAccessToken();

    if (token == null) {
      throw Exception("Access Token이 없습니다.");
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
