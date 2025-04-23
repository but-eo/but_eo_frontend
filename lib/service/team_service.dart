import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project/contants/api_contants.dart';

class TeamService {
  static Future<void> createTeamBoard({
    required String title,
    required String content,
    required String state,
    required String category,
  }) async {
    try {
      final headers = await ApiConstants.getAuthHeaders();

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/boards/create'),
        headers: headers,
        body: jsonEncode({
          'title': title,
          'content': content,
          'state': state,
          'category': category,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("팀 게시글 생성 성공");
      } else {
        print("실패: ${response.statusCode} / ${response.body}");
      }
    } catch (e) {
      print("에러 발생: $e");
      rethrow;
    }
  }
}
