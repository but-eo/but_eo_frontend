import 'dart:io';
import 'package:dio/dio.dart';
import 'package:project/contants/api_contants.dart';
import 'package:project/utils/token_storage.dart';

class StadiumService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: '${ApiConstants.baseUrl}/stadiums',
  ));

  // POST, PATCH 등 멀티파트 요청용 인증 옵션
  static Future<Options> _getAuthOptions() async {
    final token = await TokenStorage.getAccessToken();
    return Options(
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        'Content-Type': 'multipart/form-data',
      },
    );
  }

  // GET 요청 전용 인증 옵션 (Content-Type 없음)
  static Future<Options> _getAuthHeaderOnly() async {
    final token = await TokenStorage.getAccessToken();
    return Options(
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
  }

  // 경기장 등록
  static Future<String?> createStadium({required FormData formData}) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.post(
        '/create',
        data: formData,
        options: options,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return null; // 성공
      }
    } on DioException catch (e) {
      return e.response?.data.toString() ?? '서버 오류';
    } catch (_) {
      return '알 수 없는 오류';
    }
    return '등록 실패';
  }

  // 경기장 수정
  static Future<String?> updateStadium({
    required String stadiumId,
    required FormData formData,
  }) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.patch(
        '/$stadiumId',
        data: formData,
        options: options,
      );
      if (response.statusCode == 200) return null;
    } on DioException catch (e) {
      return e.response?.data.toString() ?? '서버 오류';
    } catch (_) {
      return '알 수 없는 오류';
    }
    return '수정 실패';
  }

  //  경기장 삭제
  static Future<String?> deleteStadium(String stadiumId) async {
    try {
      final options = await _getAuthHeaderOnly();
      final response = await _dio.delete('/$stadiumId', options: options);
      if (response.statusCode == 200 || response.statusCode == 204) return null;
    } on DioException catch (e) {
      return e.response?.data.toString() ?? '서버 오류';
    } catch (_) {
      return '알 수 없는 오류';
    }
    return '삭제 실패';
  }

  //  전체 경기장 조회
  static Future<List<Map<String, dynamic>>?> getAllStadiums() async {
    try {
      final options = await _getAuthHeaderOnly();
      final response = await _dio.get('', options: options);

      if (response.statusCode == 200) {
        final data = response.data;
        print("❌ 경기장 내용 data: ${data}");
        if (data is List) {
          return data.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      }
    } on DioException catch (e) {
      print("❌ getAllStadiums DioException: ${e.response?.data}");
      //print("📡 요청 URL (예외): ${e.requestOptions.uri}");
    } catch (e) {
      print("❌ getAllStadiums 알 수 없는 오류: $e");
    }
    return null;
  }

  //  단일 경기장 조회
  static Future<Map<String, dynamic>?> getStadium(String stadiumId) async {
    try {
      final options = await _getAuthHeaderOnly();
      final response = await _dio.get('/$stadiumId', options: options);
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      }
    } on DioException catch (e) {
      print("❌ getStadium DioException: ${e.response?.data}");
    } catch (e) {
      print("❌ getStadium 알 수 없는 오류: $e");
    }
    return null;
  }
}
