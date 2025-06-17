import 'package:dio/dio.dart';
import 'package:project/contants/api_contants.dart';
import 'package:project/pages/match/matching_data.dart';
import 'package:project/utils/token_storage.dart';

Future<List<MatchingData>> fetchMatchCardsFromServer() async {
  final dio = Dio();
  final token = await TokenStorage.getAccessToken();

  try {
    final response = await dio.get(
      "${ApiConstants.baseUrl}/matchings",
      options: Options(headers: {"Authorization": "Bearer $token"}),
      queryParameters: {
          'state': 'WAITING',
  //         'page': 0,
  //         'size': 1,
  //         'sort': 'matchDate,asc' // 가장 가까운 날짜 순
        },
    );

    if (response.statusCode == 200) {
      final List<dynamic> contentList = response.data['content'];
      print("매치 정보 $contentList");
      return contentList.map((json) => MatchingData.fromJson(json)).toList();
    } else {
      throw Exception("매칭 카드 데이터 요청 중 오류 발생: ${response.statusCode}");
    }
  } catch (e) {
    print("에러: $e");
    throw Exception("매칭 카드 데이터 요청 중 오류 발생: $e");
  }
}
