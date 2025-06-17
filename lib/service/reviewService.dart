import 'package:dio/dio.dart';
import 'package:project/contants/api_contants.dart';
import 'package:project/utils/token_storage.dart';

class ReviewService {
  static final Dio _dio = Dio(BaseOptions(baseUrl: '${ApiConstants.baseUrl}/reviews'));

  static Future<Options> _getAuthOptions() async {
    final token = await TokenStorage.getAccessToken();
    return Options(headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });
  }

  /// 팀별 리뷰 목록 조회
  static Future<List<Map<String, dynamic>>> getTeamReviews(String teamId) async {
    try {
      final options = await _getAuthOptions();
      final url = '/team/$teamId';
      print("📡 GET 요청: ${_dio.options.baseUrl}$url"); // ✅ 요청 URL 확인
      final response = await _dio.get(url, options: options);
      print("✅ 응답 수신: ${response.statusCode} / 데이터: ${response.data}");

      if (response.statusCode == 200 && response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('리뷰 데이터를 불러오지 못했습니다');
      }
    } on DioException catch (e) {
      print("❌ DioException 발생: ${e.message}");
      print("🔍 Dio 오류 응답: ${e.response?.data}");
      rethrow;
    } catch (e) {
      print("❌ 알 수 없는 오류: $e");
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
      final options = await _getAuthOptions();
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
        return '리뷰 작성 실패: ${response.statusCode}';
      }
    } on DioException catch (e) {
      return e.response?.data.toString() ?? '리뷰 작성 중 네트워크 오류';
    } catch (e) {
      return '알 수 없는 오류: $e';
    }
  }
}
