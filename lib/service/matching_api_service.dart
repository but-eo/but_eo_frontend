import 'package:dio/dio.dart';
import 'package:project/contants/api_contants.dart';
import 'package:project/utils/token_storage.dart';

class MatchingApiService {
  static final Dio _dio = Dio();

  // 예정된 매치 목록 가져오기 (가장 가까운 1개만)
  static Future<Map<String, dynamic>?> getUpcomingMatch() async {
    final token = await TokenStorage.getAccessToken();
    // 이 API는 토큰이 필요 없을 수 있으나, 일관성을 위해 포함 (백엔드 SecurityConfig에 따라)

    try {
      // 백엔드 MatchingController의 getMatchings 참고, WAITING 상태의 매치를 날짜순(오름차순)으로 1개만 가져옴
      final response = await _dio.get(
        "${ApiConstants.baseUrl}/matchings",
        queryParameters: {
          'state': 'WAITING', // 'WAITING' 상태의 매치만
          'page': 0,
          'size': 1,
          'sort': 'matchDate,asc' // 가장 가까운 날짜 순
        },
        options: Options(
          headers: token != null ? {"Authorization": "Bearer $token"} : null,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        // 백엔드 응답이 Page<> 객체로 감싸져 있을 경우, content 리스트를 확인
        final content = response.data['content'];
        if (content is List && content.isNotEmpty) {
          return content.first as Map<String, dynamic>; // 첫 번째 매치 반환
        }
      }
      return null; // 매치가 없는 경우
    } catch (e) {
      print("예정된 매치 로드 실패: $e");
      // 예외를 던지는 대신 null을 반환하여 UI에서 처리하도록 함
      return null;
    }
  }
}