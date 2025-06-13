import 'dart:io';
import 'package:dio/dio.dart';
import 'package:project/utils/token_storage.dart';
import 'package:project/contants/api_contants.dart';
import 'package:project/data/teamEnum.dart';

class TeamService {
  static final Dio _dio = Dio();

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

      final Map<String, dynamic> data = {
        'team_name': teamName,
        'event': event,
        'region': region,
        'member_age': memberAge,
        'team_description': teamDescription,
      };

      if (teamCase != null) data['team_case'] = teamCase;
      if (teamImage != null) {
        data['team_img'] = await MultipartFile.fromFile(
          teamImage.path,
          filename: teamImage.path.split('/').last,
        );
      }

      final formData = FormData.fromMap(data);

      final response = await _dio.post(
        '${ApiConstants.baseUrl}/teams/create',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return null;
      } else {
        final msg = response.data is Map
            ? response.data["message"] ?? response.data["error"] ?? "팀 생성 실패"
            : "팀 생성 실패: ${response.statusCode}";
        print("팀 생성 실패: $msg");
        return msg;
      }
    } catch (e) {
      if (e is DioException) {
        final msg = e.response?.data is Map
            ? e.response?.data["message"] ??
                e.response?.data["error"] ??
                "서버 오류 발생 (${e.response?.statusCode})"
            : "서버 오류: ${e.response?.statusCode}";
        print("DioException 발생 (팀 생성): $msg");
        return msg;
      } else {
        return "예기치 않은 오류 발생";
      }
    }
  }

  static Future<void> deleteTeam(String teamId) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception("토큰이 없습니다.");

    try {
      final res = await _dio.delete(
        '${ApiConstants.baseUrl}/teams/$teamId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (res.statusCode != 200) {
        print("삭제 실패: ${res.statusCode} / ${res.data}");
        throw Exception("팀 삭제 실패 (${res.statusCode})");
      }
       print("팀 삭제 완료");
    } catch (e) {
      print("팀 삭제 중 오류: $e");
      throw Exception("팀 삭제 중 오류 발생");
    }
  }

  static Future<String?> updateTeam({
    required String teamId,
    required FormData formData,
  }) async {
    try {
      final token = await TokenStorage.getAccessToken();
      if (token == null) throw Exception("토큰이 없습니다.");

      final response = await _dio.patch(
        '${ApiConstants.baseUrl}/teams/$teamId',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        print("팀 수정 성공");
        return null;
      } else {
        return response.data?.toString() ?? "팀 수정 중 알 수 없는 오류";
      }
    } catch (e) {
      if (e is DioException) {
        final msg = e.response?.data is Map
            ? e.response?.data["message"] ??
                e.response?.data["error"] ??
                "서버 오류 발생 (${e.response?.statusCode})"
            : "서버 오류: ${e.response?.statusCode}";
        return msg;
      } else {
        print("오류 발생 (팀 수정): ${e.toString()}");
        return "예기치 않은 오류 발생";
      }
    }
  }

  static Future<List<dynamic>> fetchTeams({
    String? region,
    String? event,
    String? teamType,
    String? teamCase,
    String? teamName,
  }) async {
    try {
      final token = await TokenStorage.getAccessToken();
      final query = <String, dynamic>{
        if (region != null && region != "전체") 'region': region,
        if (event != null && event != "전체") 'event': event,
        if (teamType != null) 'teamType': teamType,
        if (teamCase != null) 'teamCase': teamCase,
        if (teamName != null && teamName.isNotEmpty) 'teamName': teamName,
      };
      final res = await _dio.get(
        '${ApiConstants.baseUrl}/teams',
        queryParameters: query.isNotEmpty ? query : null,
        options: Options(
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
        ),
      );

      if (res.statusCode == 200 && res.data is List) {
        return res.data as List<dynamic>;
      } else {
        print("팀 목록 불러오기 실패: ${res.statusCode}");
        return [];
      }
    } catch (e) {
      print("팀 목록 조회 중 에러 발생: $e");
      return [];
    }
  }

  static String getFullTeamImageUrl(String? path) {
    if (path == null || path.isEmpty) return "";
    if (path.startsWith("http")) return path;
    return "${ApiConstants.imageBaseUrl}$path";
  }

  static Future<bool> isTeamLeader(String teamId) async {
    try {
      final token = await TokenStorage.getAccessToken();
      if (token == null) throw Exception("토큰이 없습니다.");

      final res = await _dio.get(
        '${ApiConstants.baseUrl}/teams/$teamId/role',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (res.statusCode == 200) {
        return res.data.toString().trim().toUpperCase() == "LEADER";
      } else {
        print("리더 여부 조회 실패: ${res.statusCode}");
        return false;
      }
    } catch (e) {
      print("리더 여부 조회 중 에러발생 : $e");
      return false;
    }
  }

  static Future<Map<String, dynamic>> getTeamById(String teamId) async {
    try {
      final token = await TokenStorage.getAccessToken();
      final res = await _dio.get(
        '${ApiConstants.baseUrl}/teams/team/$teamId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        return res.data as Map<String, dynamic>;
      } else {
        throw Exception(
          '해당 팀 ID로 조회된 팀 데이터가 없거나 형식이 올바르지 않습니다: ${res.statusCode} - ${res.data}',
        );
      }
    } catch (e) {
      print("getTeamById 에러: $e");
      rethrow;
    }
  }

  static Future<List<dynamic>> getMyAllTeams() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception('토큰이 없습니다. 로그인이 필요합니다.');

    try {
      final response = await _dio.get(
        "${ApiConstants.baseUrl}/teams/my-teams",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      if (response.statusCode == 200) {
        if (response.data is List) {
          print("✅ 내가 속한 팀 전체 목록 조회 성공 (TeamService): ${response.data}");
          return response.data as List<dynamic>;
        } else {
          print("❗ getMyAllTeams 응답이 List가 아님: ${response.data}");
          throw Exception('서버 응답 형식이 올바르지 않습니다.');
        }
      } else {
        print(
            "❌ 내 팀 전체 목록 가져오기 실패: ${response.statusCode} - ${response.statusMessage}");
        throw Exception(
            '내가 속한 팀 목록을 불러오는데 실패했습니다. (${response.statusCode})');
      }
    } on DioException catch (e) {
      print(
          "❗ 내가 속한 팀 목록 DioException: ${e.response?.statusCode} - ${e.message}");
      String errorMessage = '내가 속한 팀 목록 서버 오류 발생';
      if (e.response?.data != null) {
        if (e.response!.data is Map && e.response!.data['message'] != null) {
          errorMessage = e.response!.data['message'];
        } else if (e.response!.data.toString().isNotEmpty) {
          errorMessage = "서버 오류: ${e.response!.data.toString().substring(0, (e.response!.data.toString().length > 100 ? 100 : e.response!.data.toString().length))}";
        }
      }
      throw Exception(errorMessage);
    } catch (e) {
      print("❗ 내가 속한 팀 전체 목록 알 수 없는 오류: $e");
      throw Exception('내가 속한 팀 전체 목록을 불러오는 중 알 수 없는 오류가 발생했습니다.');
    }
  }

  static String? getEventLabel(String? eventKey) {
    if (eventKey == null) return "종목 미지정";
    try {
      return eventEnumMap[Event.values.firstWhere(
            (e) => e.name.toUpperCase() == eventKey.toUpperCase(),
          )] ??
          eventKey;
    } catch (e) {
      print("알 수 없는 Event 키 (TeamService): $eventKey");
      return eventKey;
    }
  }

  static String? getRegionLabel(String? regionKey) {
    if (regionKey == null) return "지역 미지정";
    try {
      return regionEnumMap[Region.values.firstWhere(
            (e) => e.name.toUpperCase() == regionKey.toUpperCase(),
          )] ??
          regionKey;
    } catch (e) {
      print("알 수 없는 Region 키 (TeamService): $regionKey");
      return regionKey;
    }
  }
}