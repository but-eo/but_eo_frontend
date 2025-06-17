import 'package:dio/dio.dart';
import 'package:project/contants/api_contants.dart';
import 'package:project/service/authHeaderService.dart';

class Matchservice {
  static final Dio dio = Dio();

  Future<bool> challengeMatch(String matchId, String challengerTeamId) async {
    try {
      final options = await AuthHeaderService.getAuthJsonOptions(); // AuthHeaderService 사용
      final url = "${ApiConstants.baseUrl}/matchings/$matchId/challenge";
      final requestBody = {"challenger": challengerTeamId};
      print("challenger : $challengerTeamId");

      final response = await dio.post(
        url,
        options: options,
        data: requestBody,
      );

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
      throw Exception("도전 신청 실패: ${e.message}");
    } catch (e) {
      throw Exception("도전 신청 실패: $e");
    }
  }

  Future<Map<String, dynamic>> fetchMatching(String matchId) async {
    try {
      final options = await AuthHeaderService.getAuthHeaderOnly(); // AuthHeaderService 사용
      final url = "${ApiConstants.baseUrl}/matchings/$matchId";
      final response = await dio.get(
        url,
        options: options,
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

  // 백엔드 컨트롤러에 따라 "진행 중 경기"로 간주되는 /team/{teamId}/success 엔드포인트를 호출합니다.
  Future<List<Map<String, dynamic>>> fetchOngoingMatchesByTeam(
      String teamId) async {
    try {
      final options = await AuthHeaderService.getAuthHeaderOnly(); // AuthHeaderService 사용
      final url = "${ApiConstants.baseUrl}/matchings/team/$teamId/success";
      final response = await dio.get(
        url,
        options: options,
      );

      if (response.statusCode == 200) {
        print("팀 진행 중 경기 조회 성공: ${response.data}");
        if (response.data is List) {
          return List<Map<String, dynamic>>.from(response.data);
        } else {
          throw Exception("API 응답 형식이 예상과 다릅니다 (List가 아님).");
        }
      } else {
        throw Exception(
            "팀 진행 중 경기 조회 실패: 서버 응답 오류 ${response.statusCode}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print("DioError - 응답 데이터: ${e.response?.data}");
        print("DioError - 응답 상태: ${e.response?.statusCode}");
        throw Exception(
            "팀 진행 중 경기 조회 서버 오류: ${e.response?.statusCode ?? '알 수 없음'}");
      } else {
        print("DioError - 요청 오류: ${e.message}");
        throw Exception("팀 진행 중 경기 조회 네트워크 오류: ${e.message}");
      }
    } catch (e) {
      throw Exception("팀 진행 중 경기 조회 중 예상치 못한 오류: $e");
    }
  }

  // 백엔드 컨트롤러에 따라 "완료된 경기"로 간주되는 /team/{teamId}/complete 엔드포인트를 호출합니다.
  Future<List<Map<String, dynamic>>> fetchCompletedMatchesByTeam(
      String teamId) async {
    try {
      final options = await AuthHeaderService.getAuthHeaderOnly(); // AuthHeaderService 사용
      final url = "${ApiConstants.baseUrl}/matchings/team/$teamId/complete";
      final response = await dio.get(
        url,
        options: options,
      );

      if (response.statusCode == 200) {
        print("팀 완료된 경기 조회 성공: ${response.data}");
        if (response.data is List) {
          return List<Map<String, dynamic>>.from(response.data);
        } else {
          throw Exception("API 응답 형식이 예상과 다릅니다 (List가 아님).");
        }
      } else {
        throw Exception(
            "팀 완료된 경기 조회 실패: 서버 응답 오류 ${response.statusCode}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print("DioError - 응답 데이터: ${e.response?.data}");
        print("DioError - 응답 상태: ${e.response?.statusCode}");
        throw Exception(
            "팀 완료된 경기 조회 서버 오류: ${e.response?.statusCode ?? '알 수 없음'}");
      } else {
        print("DioError - 요청 오류: ${e.message}");
        throw Exception("팀 완료된 경기 조회 네트워크 오류: ${e.message}");
      }
    } catch (e) {
      throw Exception("팀 완료된 경기 조회 중 예상치 못한 오류: $e");
    }
  }
}