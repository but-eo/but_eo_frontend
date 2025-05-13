import 'dart:io';
import 'package:dio/dio.dart';
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
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) {
        throw Exception("토큰이 없습니다.");
      }

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
        print("실패: ${response.statusCode} / ${response.data}");
      }
    } catch (e) {
      print("에러 발생: $e");
    }
  }

  static String getFullTeamImageUrl(String? path) {
    if (path == null || path.isEmpty) return "";

    // 이미 완전한 URL이면 그대로 사용
    if (path.startsWith("http")) return path;

    // 앞에 '/' 붙어 있으면 제거
    if (path.startsWith("/")) path = path.substring(1);

    // 이미지 전용 서버 URL로 조립 (api 안 붙음)
    return "http://${ApiConstants.serverUrl}:714/$path";
  }




  /// 팀 목록 조회å
  static Future<List<dynamic>> fetchTeams({
    String? region,
    String? event,
  }) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        '${ApiConstants.baseUrl}/teams',
        queryParameters: {
          if (region != null && region != "전체") 'region': region,
          if (event != null && event != "전체") 'event': event,
        },
      );

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        print("불러오기 실패: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("에러 발생: $e");
      return [];
    }
  }
}
