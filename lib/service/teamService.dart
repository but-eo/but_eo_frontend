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
        throw Exception("팀 삭제 실패 (${res.statusCode})");
      }
    } catch (e) {
      print("팀 삭제 중 오류: $e");
      throw Exception("팀 삭제 중 오류 발생");
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
            'Content
