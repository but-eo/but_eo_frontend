import 'dart:convert';
import 'package:http/http.dart' as http;
import '../contants/api_contants.dart';

class InquiryService {
  /// 문의 등록
  static Future<bool> createInquiry(
      String title,
      String content, {
        String? password,
        String visibility = 'PUBLIC',
      }) async {
    try {
      final headers = await ApiConstants.getAuthHeaders();
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/inquiries/create'),
        headers: headers,
        body: jsonEncode({
          'title': title,
          'content': content,
          'password': password,
          'visibility': visibility,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('❌ createInquiry error: $e');
      return false;
    }
  }

  /// 내 문의 목록 가져오기 (최신순 정렬)
  static Future<List<Map<String, dynamic>>> getMyInquiries() async {
    try {
      final headers = await ApiConstants.getAuthHeaders();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/inquiries/my'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        data.sort((a, b) => (b['createdAt'] ?? '').compareTo(a['createdAt'] ?? ''));
        return data;
      } else {
        print('❌ getMyInquiries 실패: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ getMyInquiries error: $e');
      return [];
    }
  }

  /// 문의 상세 정보 가져오기 (비공개 보호 포함)
  static Future<Map<String, dynamic>?> getInquiryDetail(String inquiryId, {String? password}) async {
    try {
      final headers = await ApiConstants.getAuthHeaders();
      final uri = Uri.parse('${ApiConstants.baseUrl}/inquiries/$inquiryId')
          .replace(queryParameters: password != null ? {'password': password} : null);

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('❌ getInquiryDetail 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ getInquiryDetail error: $e');
      return null;
    }
  }

  /// 관리자 답변 등록
  static Future<bool> answerInquiry(String inquiryId, String answerContent) async {
    try {
      final headers = await ApiConstants.getAuthHeaders();
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/inquiries/$inquiryId/answer'),
        headers: headers,
        body: jsonEncode({'content': answerContent}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ answerInquiry error: $e');
      return false;
    }
  }
}
