import 'package:dio/dio.dart';
import 'package:project/contants/api_contants.dart';
import 'package:project/utils/token_storage.dart';

class TeamInvitaionService {
  static final Dio _dio = Dio();

  //팀 가입 요청
  static Future<void> requestJoinTeam(String teamId) async {
    final token = await TokenStorage.getAccessToken();

    final response = await _dio.post(
      '${ApiConstants.baseUrl}/teams/$teamId/join',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    if (response.statusCode != 200) {
      throw Exception("팀 가입 요청 실패: ${response.statusMessage}");
    }
  }

  //팀 가입 요청 취소
  static Future<void> cancelJoinRequest(String teamId) async {
    final token = await TokenStorage.getAccessToken();

    final response = await _dio.post(
      '${ApiConstants.baseUrl}/teams/$teamId/join',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    if (response.statusCode != 200) {
      throw Exception("팀 가입 요청 취소 실패: ${response.statusMessage}");
    }
  }
}