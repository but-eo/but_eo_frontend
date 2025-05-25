import 'package:dio/dio.dart';
import 'package:project/contants/api_contants.dart';
import 'package:project/utils/token_storage.dart';
// Inquiry 모델이 정의된 파일의 실제 경로로 수정해주세요.
// 예: import 'package:project/models/inquiry_model.dart';
// 또는 InquiryMainPage.dart 에 있다면
import 'package:project/pages/InquiryMainPage.dart';


class InquiryApiService {
  final Dio _dio = Dio();

  // --- 여기가 핵심 수정 부분입니다 ---
  // ApiConstants.baseUrl ('http://172.18.5.99:714/api')을 사용하고,
  // InquiryController의 @RequestMapping("/api/inquiries")에서
  // "/inquiries" 부분만 여기에 추가합니다.
  // 결과적으로 ApiConstants.baseUrl 뒤에 "/inquiries"가 붙게 됩니다.
  final String _inquiryServicePath = "/inquiries"; // 컨트롤러의 RequestMapping 경로 중 뒷부분

  // --- 수정 끝 ---

  // 문의 생성 API
  Future<bool> createInquiry({
    required String title,
    required String content,
    String? password,
  }) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) {
      print("❌ InquiryService: 토큰 없음, 문의 생성 불가");
      return false;
    }

    // 최종 API URL 구성
    String apiUrl = "${ApiConstants.baseUrl}$_inquiryServicePath/create";
    print("📞 문의 생성 API 호출 URL: $apiUrl");

    try {
      final response = await _dio.post(
        apiUrl,
        data: {
          'title': title,
          'content': content,
          'password': password,
        },
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      print("✅ 문의 생성 응답: ${response.statusCode} ${response.data}");
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      print("❗ 문의 등록 API DioException: ${e.response?.statusCode} ${e.response?.data ?? e.message}");
      return false;
    } catch (e) {
      print("❗ 문의 등록 API 일반 오류: $e");
      return false;
    }
  }

  // 내 문의 목록 조회 API
  Future<List<Inquiry>> fetchMyInquiries() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) {
      print("❌ InquiryService: 토큰 없음, 내 문의 목록 조회 불가");
      return [];
    }

    String apiUrl = "${ApiConstants.baseUrl}$_inquiryServicePath/my";
    print("📞 내 문의 목록 API 호출 URL: $apiUrl");

    try {
      final response = await _dio.get(
        apiUrl,
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      print("✅ 내 문의 목록 응답: ${response.statusCode}");
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List).map((itemJson) {
          return Inquiry(
            id: itemJson['inquiryId']?.toString() ?? 'N/A',
            title: itemJson['title'] ?? '제목 없음',
            contentPreview: itemJson['content']?.substring(0, (itemJson['content'] as String).length > 50 ? 50 : (itemJson['content'] as String).length) ?? '내용 미리보기 없음',
            fullContent: itemJson['content'],
            date: itemJson['createdAt'] != null
                ? DateTime.parse(itemJson['createdAt']).toLocal().toString().substring(0, 16)
                : '날짜 정보 없음',
            status: itemJson['answerContent'] != null && itemJson['answerContent'].isNotEmpty ? '답변 완료' : '답변 대기 중',
            answer: itemJson['answerContent'],
            isPrivate: itemJson['visibility'] == 'PRIVATE',
            writerName: itemJson['writerName'],
          );
        }).toList();
      }
      print("❗ 내 문의 목록 조회 실패: Status ${response.statusCode}, Data: ${response.data}");
      return [];
    } on DioException catch (e) {
      print("❗ 내 문의 목록 API DioException: ${e.response?.statusCode} ${e.response?.data ?? e.message}");
      return [];
    } catch (e) {
      print("❗ 내 문의 목록 API 일반 오류: $e");
      return [];
    }
  }

  // 문의 상세 조회 API
  Future<Inquiry?> getInquiryDetail(String inquiryId, {String? password}) async {
    final token = await TokenStorage.getAccessToken();

    String apiUrl = "${ApiConstants.baseUrl}$_inquiryServicePath/$inquiryId";
    print("📞 문의 상세 API 호출 URL: $apiUrl (password: $password)");

    try {
      final Map<String, dynamic> queryParams = {};
      if (password != null && password.isNotEmpty) {
        queryParams['password'] = password;
      }

      final response = await _dio.get(
        apiUrl,
        queryParameters: queryParams,
        options: Options(headers: token != null ? {"Authorization": "Bearer $token"} : null),
      );
      print("✅ 문의 상세 응답: ${response.statusCode}");
      if (response.statusCode == 200 && response.data != null) {
        final itemJson = response.data;
        return Inquiry(
          id: itemJson['inquiryId']?.toString() ?? 'N/A',
          title: itemJson['title'] ?? '제목 없음',
          contentPreview: itemJson['content']?.substring(0, (itemJson['content'] as String).length > 50 ? 50 : (itemJson['content'] as String).length) ?? '내용 미리보기 없음',
          fullContent: itemJson['content'],
          date: itemJson['createdAt'] != null
              ? DateTime.parse(itemJson['createdAt']).toLocal().toString().substring(0, 16)
              : '날짜 정보 없음',
          status: itemJson['answerContent'] != null && itemJson['answerContent'].isNotEmpty ? '답변 완료' : '답변 대기 중',
          answer: itemJson['answerContent'],
          isPrivate: itemJson['visibility'] == 'PRIVATE',
          writerName: itemJson['writerName'],
        );
      }
      print("❗ 문의 상세 조회 실패: Status ${response.statusCode}, Data: ${response.data}");
      return null;
    } on DioException catch (e) {
      print("❗ 문의 상세 API DioException: ${e.response?.statusCode} ${e.response?.data ?? e.message}");
      rethrow;
    } catch (e) {
      print("❗ 문의 상세 API 일반 오류: $e");
      rethrow;
    }
  }
}