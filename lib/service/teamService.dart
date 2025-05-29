import 'dart:io';
import 'package:dio/dio.dart';
import 'package:project/utils/token_storage.dart';
import 'package:project/contants/api_contants.dart';

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

      // 백엔드 API (@RequestParam)가 기대하는 필드명 (snake_case)으로 정확히 맞춘거
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
        data: formData, // MultipartForm-Data로 전송
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data', // 명시적으로 Content-Type 설정
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
      if (e is DioException) {
        final msg = e.response?.data is Map
            ? e.response?.data["message"] ?? e.response?.data["error"] ?? "서버 오류 발생"
            : "서버 오류: ${e.response?.statusCode}";
        print("DioException 발생: $msg");
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

    final res = await _dio.delete(
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

  // 팀 수정
  static Future<String?> updateTeam({
    required String teamId,
    required FormData formData,
  }) async {
    // 디버깅을 위한 출력문 (실제 배포 시에는 제거하거나 로그 레벨 조절)
    formData.fields.forEach((f) => print('formData field: ${f.key}: ${f.value}'));
    formData.files.forEach((f) => print('formData file: ${f.key} = ${f.value.filename}'));

    try {
      final token = await TokenStorage.getAccessToken();
      if (token == null) throw Exception("토큰이 없습니다.");

      final response = await _dio.patch(
        '${ApiConstants.baseUrl}/teams/$teamId',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data', // 명시적으로 Content-Type 설정
          },
        ),
      );

      if (response.statusCode == 200) {
        print("팀 수정 성공");
        return null;
      } else {
        print("❌ 팀 수정 실패: ${response.statusCode} / ${response.data}");
        return response.data.toString();
      }
    } catch (e) {
      if (e is DioException) {
        final msg = e.response?.data is Map
            ? e.response?.data["message"] ?? e.response?.data["error"] ?? "서버 오류 발생"
            : "서버 오류: ${e.response?.statusCode}";
        print("DioException 발생: $msg");
        return msg;
      } else {
        print("오류 발생: ${e.toString()}");
        return "예기치 않은 오류 발생";
      }
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
      final query = <String, dynamic>{
        if (region != null) 'region': region,
        if (event != null) 'event': event,
        if (teamType != null) 'teamType': teamType,
        if (teamCase != null) 'teamCase': teamCase,
        if (teamName != null) 'teamName': teamName,
      };

      final res = await _dio.get(
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
    // ApiConstants.serverUrl이 `http://` 또는 `https://`를 포함하지 않는 경우를 가정
    return "http://${ApiConstants.serverUrl}:714$path";
  }

  /// 팀 리더 여부 조회 (응답 본문 문자열: "LEADER")
  static Future<bool> isTeamLeader(String teamId) async {
    try {
      final token = await TokenStorage.getAccessToken();
      if (token == null) throw Exception("토큰이 없습니다.");

      final res = await _dio.get(
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

  /// 팀 상세조회 (팀 이름으로 조회)
  /// **주의: 팀 이름이 고유하다는 전제하에 작동하며, 고유하지 않을 경우 첫 번째 검색된 팀을 반환합니다.**
  /// 가능한 경우, 백엔드에서 팀 ID로 조회하는 API를 제공하는 것이 더 좋습니다.
  static Future<Map<String, dynamic>> getTeamByName(String teamName) async {
    try {
      final token = await TokenStorage.getAccessToken();
      if (token == null) throw Exception("토큰이 없습니다.");

      final res = await _dio.get(
        '${ApiConstants.baseUrl}/teams',
        queryParameters: {
          'teamName': teamName, // 팀 이름으로 조회 시 teamName으로 쿼리 파라미터 보냄
        },
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      if (res.statusCode == 200 && res.data is List && res.data.isNotEmpty) {
        return res.data[0]; // 첫 번째 팀 반환
      } else {
        throw Exception('해당 팀 이름으로 조회된 팀 데이터가 없습니다.');
      }
    } catch (e) {
      print("getTeamByName 에러: $e");
      rethrow;
    }
  }

  /// 유저 초대
  static Future<String?> inviteUserToTeam({
    required String teamId,
    required String userId,
  }) async {
    try {
      final token = await TokenStorage.getAccessToken();
      if (token == null) throw Exception("토큰이 없습니다.");

      final response = await _dio.post(
        '${ApiConstants.baseUrl}/teams/$teamId/invite',
        data: {
          'userId': userId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        print("초대 성공");
        return null;
      } else {
        final msg = response.data is Map
            ? response.data["message"] ?? response.data["error"] ?? "초대 실패"
            : "초대 실패: ${response.statusCode}";
        return msg;
      }
    } catch (e) {
      print("초대 요청 에러: $e");
      return "초대 요청 중 오류 발생";
    }
  }

  /// 초대 취소
  static Future<String?> cancelInvite({
    required String teamId,
    required String userId,
  }) async {
    try {
      final token = await TokenStorage.getAccessToken();
      if (token == null) throw Exception("토큰이 없습니다.");

      final response = await _dio.delete(
        '${ApiConstants.baseUrl}/teams/$teamId/invitecancel/$userId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        print("초대 취소 완료");
        return null;
      } else {
        final msg = response.data is Map
            ? response.data["message"] ?? response.data["error"] ?? "초대 취소 실패"
            : "초대 취소 실패: ${response.statusCode}";
        return msg;
      }
    } catch (e) {
      print("초대 취소 에러: $e");
      return "초대 취소 중 오류 발생";
    }
  }
}