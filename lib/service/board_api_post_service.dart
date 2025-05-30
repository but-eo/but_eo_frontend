import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:project/contants/api_contants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

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
    contentType: MediaType('application', 'json'),
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


Future<bool> updateBoardPost({
  required String boardId,
  required String title,
  required String content,
  required String event,
  required String category,
  required String state,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('accessToken');

  if (accessToken == null) {
    print('Access token is null');
    return false;
  }

  final dio = Dio();

  final boardJson = {
    'title': title,
    'content': content,
    'event': event,
    'category': category,
    'state': state,
  };

  final formData = FormData.fromMap({
    'request': MultipartFile.fromString(
      jsonEncode(boardJson),
      contentType: MediaType('application', 'json'),
    ),
    // 'files': await MultipartFile.fromFile(filePath)  // 파일이 있다면 주석 해제
  });

  try {
    final response = await dio.patch(
      '${ApiConstants.baseUrl}/boards/$boardId/update',
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'multipart/form-data',
        },
      ),
    );

    if (response.statusCode == 200) {
      print("게시글 수정 성공");
      return true;
    } else {
      print("게시글 수정 실패: ${response.statusCode} ${response.data}");
      return false;
    }
  } catch (e) {
    print("게시글 수정 예외: $e");
    return false;
  }
}



