import 'dart:io';
import 'package:dio/dio.dart';
import 'package:project/utils/token_storage.dart';
import 'package:project/contants/api_contants.dart';
import 'package:project/data/teamEnum.dart'; // ✅ teamEnum.dart 파일 import 추가 (Event, Region enum 및 map 사용 위함)

class TeamService {
  static final Dio _dio = Dio(); // Dio 인스턴스를 한 번만 생성하여 재사용

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
          filename: teamImage.path.split('/').last, // 파일 이름 명시
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
        // 201도 성공으로 간주
        return null;
      } else {
        final msg =
            response.data is Map
                ? response.data["message"] ??
                    response.data["error"] ??
                    "팀 생성 실패"
                : "팀 생성 실패: ${response.statusCode}";
        print("팀 생성 실패: $msg");
        return msg;
      }
    } catch (e) {
      if (e is DioException) {
        final msg =
            e.response?.data is Map
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

  /// 팀 삭제
  static Future<void> deleteTeam(String teamId) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception("토큰이 없습니다.");

    try {
      final res = await _dio.delete(
        '${ApiConstants.baseUrl}/teams/$teamId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (res.statusCode == 200) {
        print("팀 삭제 완료");
      } else {
        print("삭제 실패: ${res.statusCode} / ${res.data}");
        throw Exception("팀 삭제 실패 (${res.statusCode})"); // 에러 발생시 throw 추가
      }
    } catch (e) {
      print("팀 삭제 중 오류: $e");
      throw Exception("팀 삭제 중 오류 발생"); // 에러 발생시 throw 추가
    }
  }

  // 팀 수정
  static Future<String?> updateTeam({
    required String teamId,
    required FormData formData,
  }) async {
    formData.fields.forEach(
      (f) => print('formData field: ${f.key}: ${f.value}'),
    );
    formData.files.forEach(
      (f) => print('formData file: ${f.key} = ${f.value.filename}'),
    );

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
        final msg =
            e.response?.data is Map
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

  /// 팀 목록 조회 (필터 적용 가능)
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

      print(res.data.toString());
      if (res.statusCode == 200 && res.data is List) {
        print("✅요것이 상세조회여 ~~~${res.data}");
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

  /// 팀 이미지 URL 조립
  static String getFullTeamImageUrl(String? path) {
    if (path == null || path.isEmpty) return "";
    if (path.startsWith("http")) return path;
    return "${ApiConstants.imageBaseUrl}$path";
  }

  /// 팀 리더 여부 조회
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

  // 팀 상세조회
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

  // ✅ 사용자가 리더로 있는 팀 목록 조회
  static Future<List<dynamic>> getMyTeams() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) {
      throw Exception('토큰이 없습니다. 로그인이 필요합니다.');
    }

    try {
      // TeamController.java 에 정의된 @GetMapping("/my-leader-teams") 사용
      final response = await _dio.get(
        "${ApiConstants.baseUrl}/teams/my-teams", // API 경로
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        if (response.data is List) {
          print("✅ 내 팀 목록 조회 성공 (TeamService): ${response.data}");
          return response.data as List<dynamic>;
        } else {
          print(
            "❗ getMyTeams (my-leader-teams) 응답 데이터가 List 형식이 아닙니다: ${response.data}",
          );
          throw Exception('서버 응답 형식이 올바르지 않습니다.');
        }
      } else {
        print(
          "❌ 내 리더 팀 목록 가져오기 실패 (TeamService): ${response.statusCode} - ${response.statusMessage}",
        );
        throw Exception('내 리더 팀 목록을 불러오는데 실패했습니다. (${response.statusCode})');
      }
    } on DioException catch (e) {
      print(
        "❗ 내 리더 팀 목록 요청 중 DioException (TeamService): ${e.response?.statusCode} - ${e.message}",
      );
      String errorMessage = '팀 목록 요청 중 서버 오류가 발생했습니다.';
      if (e.response?.data != null) {
        if (e.response!.data is Map && e.response!.data['message'] != null) {
          errorMessage = e.response!.data['message'];
        } else if (e.response!.data.toString().isNotEmpty) {
          errorMessage =
              "서버 오류: ${e.response!.data.toString().substring(0, (e.response!.data.toString().length > 100 ? 100 : e.response!.data.toString().length))}";
        }
      }
      throw Exception(errorMessage);
    } catch (e) {
      print("❗ 내 리더 팀 목록 요청 중 알 수 없는 오류 (TeamService): $e");
      throw Exception('팀 목록을 불러오는 중 알 수 없는 오류가 발생했습니다.');
    }
  }

  // ✅ Event enum 키를 한글 라벨로 변환하는 메소드
  static String? getEventLabel(String? eventKey) {
    if (eventKey == null) return "종목 미지정"; // 또는 null 반환 후 호출부에서 처리
    try {
      // teamEnum.dart의 eventEnumMap 사용 (해당 파일이 TeamService.dart에 import 되어 있어야 함)
      return eventEnumMap[Event.values.firstWhere(
            (e) => e.name.toUpperCase() == eventKey.toUpperCase(),
          )] ??
          eventKey;
    } catch (e) {
      print("알 수 없는 Event 키 (TeamService): $eventKey");
      return eventKey; // 맵에 없는 경우 원본 키 반환
    }
  }

  // ✅ Region enum 키를 한글 라벨로 변환하는 메소드
  static String? getRegionLabel(String? regionKey) {
    if (regionKey == null) return "지역 미지정"; // 또는 null 반환 후 호출부에서 처리
    try {
      // teamEnum.dart의 regionEnumMap 사용 (해당 파일이 TeamService.dart에 import 되어 있어야 함)
      return regionEnumMap[Region.values.firstWhere(
            (e) => e.name.toUpperCase() == regionKey.toUpperCase(),
          )] ??
          regionKey;
    } catch (e) {
      print("알 수 없는 Region 키 (TeamService): $regionKey");
      return regionKey; // 맵에 없는 경우 원본 키 반환
    }
  }
}
