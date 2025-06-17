import 'package:dio/dio.dart';
import 'package:project/contants/api_contants.dart';
import 'package:project/service/authHeaderService.dart';

class ReviewService {
  static final Dio _dio = Dio(BaseOptions(baseUrl: '${ApiConstants.baseUrl}/reviews'));

  /// 팀별 리뷰 목록 조회
  static Future<List<Map<String, dynamic>>> getTeamReviews(String teamId) async {
    try {
      final options = await AuthHeaderService.getAuthHeaderOnly();
      final url = '/team/$teamId';
      final response = await _dio.get(url, options: options);

      if (response.statusCode == 200 && response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('리뷰 데이터를 불러오지 못했습니다 (상태 코드: ${response.statusCode})');
      }
    } on DioException catch (e) {

      rethrow;
    } catch (e) {
      rethrow;
    }
  }


  /// 리뷰 작성
  static Future<String?> writeReview({
    required String matchId,
    required String targetTeamId,
    required int rating,
    required String content,
  }) async {
    try {
      final options = await AuthHeaderService.getAuthJsonOptions();
      final body = {
        'matchId': matchId,
        'targetTeamId': targetTeamId,
        'rating': rating,
        'content': content,
      };

      final response = await _dio.post('', data: body, options: options);

      if (response.statusCode == 200) {
        return null; // 성공
      } else {
        return '리뷰 작성 실패: ${response.statusCode} - ${response.data ?? "응답 본문 없음"}';
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print("🔍 ReviewService POST Dio 오류 응답 상태 코드: ${e.response?.statusCode}"); // Debug
        print("🔍 ReviewService POST Dio 오류 응답 데이터: ${e.response?.data}"); // Debug
        print("🔍 ReviewService POST Dio 오류 응답 헤더: ${e.response?.headers}"); // Debug
      } else {
        print("🔍 ReviewService POST Dio 오류 요청 옵션: ${e.requestOptions}"); // Debug (네트워크 연결 불가 등)
      }
      return e.response?.data.toString() ?? '리뷰 작성 중 네트워크 오류';
    } catch (e) {
      print("❌ ReviewService POST 알 수 없는 오류: $e"); // Debug
      return '알 수 없는 오류: $e';
    }
  }
}