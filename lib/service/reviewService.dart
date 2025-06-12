import 'package:dio/dio.dart';
import 'package:project/utils/token_storage.dart';
import 'package:project/contants/api_contants.dart';

class ReviewService {
  static final Dio _dio = Dio();

  /// 리뷰 작성
  static Future<String?> writeReview({
    required String matchId,
    required String targetTeamId,
    required int rating,
    required String content,
  }) async {
    try {
      final token = await TokenStorage.getAccessToken();
      if (token == null) throw Exception("토큰이 없습니다.");

      final data = {
        "matchId": matchId,
        "targetTeamId": targetTeamId,
        "rating": rating,
        "content": content,
      };

      final response = await _dio.post(
        '${ApiConstants.baseUrl}/reviews',
        data: data,
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      if (response.statusCode == 200) {
        return null; // 성공
      } else {
        return "리뷰 작성 실패: ${response.data}";
      }
    } on DioException catch (e) {
      print("리뷰 작성 오류: ${e.response?.data}");
      return e.response?.data["message"] ?? "리뷰 작성 중 오류 발생";
    } catch (e) {
      print("알 수 없는 오류: $e");
      return "리뷰 작성 중 알 수 없는 오류 발생";
    }
  }

  /// 특정 팀의 모든 리뷰 가져오기
  static Future<List<dynamic>> getTeamReviews(String teamId) async {
    try {
      final token = await TokenStorage.getAccessToken();

      final response = await _dio.get(
        '${ApiConstants.baseUrl}/reviews/team/$teamId',
        options: Options(
          headers: {
            if (token != null) "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200 && response.data is List) {
        return response.data;
      } else {
        throw Exception("리뷰 목록 불러오기 실패: ${response.statusCode}");
      }
    } on DioException catch (e) {
      print("리뷰 목록 Dio 에러: ${e.response?.data}");
      return [];
    } catch (e) {
      print("리뷰 목록 일반 에러: $e");
      return [];
    }
  }
}
