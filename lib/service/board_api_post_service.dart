import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:project/contants/api_contants.dart';

Future<bool> createBoardPost({
  required String title,
  required String content,
  required String event,
  required String category,
  required String userId,
}) async {
  final uri = Uri.parse('${ApiConstants.baseUrl}/boards/create');

  var request = http.MultipartRequest('POST', uri);

  // ✅ JSON 데이터를 'request'라는 이름의 Part로 넣기
  final Map<String, dynamic> boardJson = {
    'title': title,
    'content': content,
    'event': event,
    'category': category,
    'state': 'PUBLIC', // ⚠️ 서버에서 state도 BoardRequest에 기대할 수 있음
  };

  request.files.add(http.MultipartFile.fromString(
    'request',
    jsonEncode(boardJson),
    contentType: DioMediaType('application', 'json'),
  ));

  // ✅ userId는 @RequestParam이므로 그냥 field로 추가
  request.fields['userId'] = userId;

  // 🔄 파일이 있다면 아래처럼 추가
  // request.files.add(await http.MultipartFile.fromPath('files', filePath));

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 201) {
    return true;
  } else {
    print("게시판 작성 실패: ${response.statusCode} ${response.body}");
    return false;
  }
}
