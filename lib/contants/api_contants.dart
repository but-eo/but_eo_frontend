import 'package:project/utils/token_storage.dart';

class ApiConstants {
  static const String baseUrl = 'http://localhost:0714/api';

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
