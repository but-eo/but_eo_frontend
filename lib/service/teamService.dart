import 'dart:io';
import 'package:dio/dio.dart';
import 'package:project/utils/token_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project/contants/api_contants.dart';

class TeamService {
  /// 팀 생성
  static Future<void> createTeam({
    required String teamName,
    required String event,
    required String region,
    required int memberAge,
    String? teamCase,
    required String teamDescription,
    File? teamImage,
  }) async {
    try {
      final token = await TokenStorage.getAccessToken();
      if (token == null) throw Exception("토큰이 없습니다.");

      final dio = Dio();
      final Map<String, dynamic> data = {
        'team_name': teamName,
        'event': event,
        'region': region,
        'member_age': memberAge,
        'team_description': teamDescription,
      };

      if (teamCase != null) data['team_case'] = teamCase;
      if (teamImage != null) {
        data['team_img'] = await MultipartFile.fromFile(teamImage.path);
      }

      final formData = FormData.fromMap(data);

      final response = await dio.post(
        '${ApiConstants.baseUrl}/teams/create',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        print("팀 생성 성공");
      } else {
        print("팀 생성 실패: \${response.statusCode} / \${response.data}");
      }
    } catch (e) {
      print("에러 발생: $e");
    }
  }

  /// 팀 삭제
  static Future<void> deleteTeam(String teamId) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception("토큰이 없습니다.");

    final dio = Dio();
    final res = await dio.delete(
      '${ApiConstants.baseUrl}/teams/$teamId',
      options: Options(headers: {
        'Authorization': 'Bearer $token',
      }),
    );

    if (res.statusCode == 200) {
      print("팀 삭제 완료");
    } else {
      print("삭제 실패: ${res.statusCode} / ${res.data}");
    }
  }

  /// 팀 목록 조회
  static Future<List<dynamic>> fetchTeams({
    String? region,
    String? event,
  }) async {
    try {
      final dio = Dio();
      final res = await dio.get(
        '${ApiConstants.baseUrl}/teams',
        queryParameters: {
          if (region != null && region != "전체") 'region': region,
          if (event != null && event != "전체") 'event': event,
        },
      );

      if (res.statusCode == 200) {
        return res.data as List<dynamic>;
      } else {
        print("불러오기 실패: ${res.statusCode}");
        return [];
      }
    } catch (e) {
      print("에러 발생: $e");
      return [];
    }
  }

  /// 팀 이미지 URL 조립
  static String getFullTeamImageUrl(String? path) {
    if (path == null || path.isEmpty) return "";
    if (path.startsWith("http")) return path;
    return "http://${ApiConstants.serverUrl}:714$path";
  }

  /// 팀 리더 여부 조회
  static Future<bool> isTeamLeader(String teamId) async {
    try {
      final token = await TokenStorage.getAccessToken();
      if (token == null) throw Exception("토큰이 없습니다.");

      final dio = Dio();
      final res = await dio.get(
        '${ApiConstants.baseUrl}/teams/$teamId/role',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      if (res.statusCode == 200) {
        return res.data['isLeader'] == true;
      } else {
        print("리더 여부 조회 실패: ${res.statusCode}");
        return false;
      }
    } catch(e) {
      print("에러발생 : $e");
      return false;
    }
  }

}