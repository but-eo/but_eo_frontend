import 'package:dio/dio.dart';
import 'package:project/contants/api_contants.dart';
import 'package:project/pages/match/matching_data.dart';

Future<List<MatchingData>> fetchMatchCardsFromServer() async {
  try {
    final dio = Dio();

    // 서버 주소 및 포트는 프로젝트에 맞게 수정
    final response = await dio.get(
      'http://${ApiConstants.serverUrl}:714/api/matches',
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;

      // JSON 배열을 MatchCardModel 리스트로 변환
      return data.map((json) => MatchingData.fromJson(json)).toList();
    } else {
      throw Exception(
        '매칭 카드 데이터를 불러오는 데 실패했습니다. 상태 코드: ${response.statusCode}',
      );
    }
  } catch (e) {
    throw Exception('매칭 카드 데이터 요청 중 오류 발생: $e');
  }
}
