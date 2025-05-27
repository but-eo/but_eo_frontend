import 'dart:io';
import 'package:dio/dio.dart';
import 'package:project/utils/token_storage.dart';
import 'package:project/contants/api_contants.dart';

class TeamService {
  /// 팀 생성
  static Future<String?> createTeam({
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
          },
        ),
      );

      if (response.statusCode == 200) {
        print("팀 생성 성공");
        return null;
      } else {
        final msg = response.data is Map
            ? response.data["message"] ?? response.data["error"] ?? "팀 생성 실패"
            : "팀 생성 실패: ${response.statusCode}";
        print("팀 생성 실패: $msg");
        return msg;
      }
    } catch (e) {
      if (e is DioError) {
        final msg = e.response?.data is Map
            ? e.response?.data["message"] ?? e.response?.data["error"] ?? "서버 오류 발생"
            : "서버 오류: ${e.response?.statusCode}";
        print("DioError 발생: $msg");
        return msg;
      } else {
        print("예외 발생: $e");
        return "예기치 않은 오류 발생";
      }
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

  //팀 수정
  static Future<String?> updateTeam({
    required String teamId,
    required FormData formData,
  }) async {
    formData.fields.forEach((f) => print('${f.key}: ${f.value}'));
    formData.files.forEach((f) => print('파일: ${f.key} = ${f.value.filename}'));
    try {
      final token = await TokenStorage.getAccessToken();
      if (token == null) throw Exception("토큰이 없습니다.");

      final dio = Dio();
      final response = await dio.patch(
        '${ApiConstants.baseUrl}/teams/$teamId',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {

        return null;
      } else {
        print("❌ 팀 수정 실패: ${response.statusCode} / ${response.data}");
        return response.data.toString();
      }
    } catch (e) {
      print("❗에러 발생: $e");
      return "오류 발생: ${e.toString()}";
    }
  }



  /// 팀 목록 조회
  static Future<List<dynamic>> fetchTeams({
    String? region,
    String? event,
    String? teamType,
    String? teamCase,
    String? teamName,
  }) async {
    try {
      final token = await TokenStorage.getAccessToken();
      print("🟨 현재 토큰: $token");
      print("🟥 토큰 만료 여부: ${token == null ? '없음' : '몰라'}");
      final dio = Dio();

      final query = <String, dynamic>{
        if (region != null) 'region': region,
        if (event != null) 'event': event,
        if (teamType != null) 'teamType': teamType,
        if (teamCase != null) 'teamCase': teamCase,
        if (teamName != null) 'teamName': teamName,
      };

      final res = await dio.get(
        '${ApiConstants.baseUrl}/teams',
        queryParameters: query,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
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

  /// 팀 리더 여부 조회 (응답 본문 문자열: "LEADER")
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
        return res.data.toString().trim() == "LEADER";
      } else {
        print("리더 여부 조회 실패: ${res.statusCode}");
        return false;
      }
    } catch (e) {
      print("에러발생 : $e");
      return false;
    }
  }

//팀 상세조회
  static Future<Map<String, dynamic>> getTeamByName(String teamName) async {
    try {
      final token = await TokenStorage.getAccessToken();
      if (token == null) throw Exception("토큰이 없습니다.");

      final dio = Dio();
      final res = await dio.get(
        '${ApiConstants.baseUrl}/teams',
        queryParameters: {
          'teamName': teamName,
        },
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      if (res.statusCode == 200 && res.data is List && res.data.isNotEmpty) {
        return res.data[0]; // 첫 번째 팀 반환
      } else {
        throw Exception('팀 데이터가 없습니다');
      }
    } catch (e) {
      print("getTeamByName 에러: $e");
      rethrow;
    }
  }

}
