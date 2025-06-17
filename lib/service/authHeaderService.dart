import 'package:dio/dio.dart';
import 'package:project/utils/token_storage.dart';

class AuthHeaderService {
  /// 인증 + JSON 헤더
  static Future<Options> getAuthJsonOptions() async {
    final token = await TokenStorage.getAccessToken();
    return Options(headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });
  }

  /// 인증만 (GET 요청 등)
  static Future<Options> getAuthHeaderOnly() async {
    final token = await TokenStorage.getAccessToken();
    return Options(headers: {
      'Authorization': 'Bearer $token',
    });
  }
}