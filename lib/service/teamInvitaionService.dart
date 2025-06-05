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

  // 팀 가입 요청 취소
  static Future<void> cancelJoinRequest(String teamId) async {
    final token = await TokenStorage.getAccessToken();

    final response = await _dio.delete(
      '${ApiConstants.baseUrl}/teams/$teamId/join',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode != 200) {
      throw Exception("팀 가입 요청 취소 실패: ${response.statusMessage}");
    }
  }

  // 초대 수락
  static Future<void> acceptInvitation(String invitationId, String userId) async {
    final token = await TokenStorage.getAccessToken();

    final response = await _dio.post(
      '${ApiConstants.baseUrl}/invitations/$invitationId/accept',
      queryParameters: {'userId': userId},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode != 200) {
      throw Exception("초대 수락 실패: ${response.statusMessage}");
    }
  }

// 초대 거절
  static Future<void> declineInvitation(String invitationId, String userId) async {
    final token = await TokenStorage.getAccessToken();

    final response = await _dio.post(
      '${ApiConstants.baseUrl}/invitations/$invitationId/decline',
      queryParameters: {'userId': userId},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode != 200) {
      throw Exception("초대 거절 실패: ${response.statusMessage}");
    }
  }

  // 팀 신청 전체 조회
  static Future<List<Map<String, dynamic>>> getJoinRequests(
      String teamId) async {
    final token = await TokenStorage.getAccessToken();

    final response = await _dio.get(
      '${ApiConstants.baseUrl}/teams/team/$teamId/requests',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode == 200) {
      print("👉팀 초대 목록 조회 ${response.data}");
      return List<Map<String, dynamic>>.from(response.data);
    } else {
      throw Exception('가입 요청 목록 조회 실패: ${response.statusMessage}');
    }
  }

}