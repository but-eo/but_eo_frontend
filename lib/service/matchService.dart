import 'package:dio/dio.dart';
import 'package:flutter/material.dart'; // SnackBar 등을 위해 필요할 수 있습니다.
import 'package:project/contants/api_contants.dart';
import 'package:project/pages/match/matching_data.dart'; // 이 클래스에서는 직접 사용되지 않지만, import 목록에 있었으므로 유지합니다.
import 'package:project/utils/token_storage.dart'; // 토큰 접근을 위해 필요합니다.

class Matchservice {
  // Dio 인스턴스를 static final로 선언하여 한 번만 생성되도록 합니다.
  static final Dio dio = Dio();

  // challengerTeamId를 인자로 추가하고, 이를 요청 본문에 포함시킵니다.
  Future<bool> challengeMatch(String matchId, String challengerTeamId) async {
    // 1. 액세스 토큰 가져오기
    final token = await TokenStorage.getAccessToken();
    if (token == null) {
      print(
        "[Challenge Match] Access token is null. User might not be logged in.",
      );
      throw Exception("도전 신청 실패: 로그인이 필요합니다.");
    }

    try {
      final url = "${ApiConstants.baseUrl}/matchings/$matchId/challenge";

      // 요청 본문 생성 (서버에서 challengerTeamId를 기대할 것으로 예상)
      final requestBody = {"challenger": challengerTeamId};
      print("challenger : ${challengerTeamId}");

      final response = await dio.post(
        url,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json", // JSON 본문을 보낼 때 중요
          },
        ),
        data: requestBody, // 요청 본문 추가
      );
      print("Status Code: ${response.statusCode}");
      print("Response Data: ${response.data}");

      if (response.statusCode == 200) {
        print("도전 신청이 완료되었습니다. ${response.data}");
        return true;
      } else {
        print("도전 신청이 실패했습니다. Status Code: ${response.statusCode}");
        return false;
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print("Status Code: ${e.response?.statusCode}");
        print("Response Data: ${e.response?.data}");
      } else {
        
        print("Error Message: ${e.message}");
      }
      throw Exception("도전 신청 실패: ${e.message}"); // 오류 메시지를 더 자세히 전달
    } catch (e) {
      throw Exception("도전 신청 실패: $e");
    }
  }

  Future<Map<String, dynamic>> fetchMatching(String matchId) async {
    try {
      final url = "${ApiConstants.baseUrl}/matchings/$matchId";
      final token = await TokenStorage.getAccessToken();
      final response = await dio.get(
        url,
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      print("Status Code: ${response.statusCode}");
      print("Response Data: ${response.data}");

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      } else {
        print("매칭 정보 불러오기 실패. Status Code: ${response.statusCode}");
        throw Exception("매칭 정보 불러오기 실패: 서버 응답 오류 ${response.statusCode}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print("Status Code: ${e.response?.statusCode}");
        print("Response Data: ${e.response?.data}");
      } else {
        print("Error Message: ${e.message}");
      }
      print("--- End DioException Logging ---");
      throw Exception("매칭 정보 불러오기 실패: ${e.message}");
    } catch (e) {
      throw Exception("매칭 정보 불러오기 실패: $e");
    }
  }
}
