// lib/service/board_api_post_service.dart

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

  final Map<String, dynamic> boardJson = {
    'title': title,
    'content': content,
    'event': event,
    'category': category,
    'state': 'PUBLIC',
  };

  request.files.add(http.MultipartFile.fromString(
    'request',
    jsonEncode(boardJson),
    contentType: MediaType('application', 'json'),
  ));

  request.fields['userId'] = userId;

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


// 서버 API에 맞게 수정한 댓글 작성 함수
Future<bool> createComment({
  required String boardId,
  required String content,
}) async {
  // 1. URL 경로에 boardId를 포함합니다.
  final uri = Uri.parse('${ApiConstants.baseUrl}/comments/$boardId');
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');

  // 2. Body에는 content만 포함합니다. (CommentRequest DTO에 맞춤)
  final Map<String, dynamic> commentData = {
    'content': content,
  };

  final response = await http.post(
    uri,
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(commentData),
  );

  // 200 OK 또는 201 Created 등 성공 응답 처리
  if (response.statusCode == 200 || response.statusCode == 201) {
    print("댓글 작성 성공");
    return true;
  } else {
    print("댓글 작성 실패: ${response.statusCode} ${response.body}");
    return false;
  }
}

Future<bool> updateComment({
  required String commentId,
  required String content,
}) async {
  final uri = Uri.parse('${ApiConstants.baseUrl}/comments/$commentId');
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');

  final Map<String, dynamic> body = {
    'content': content,
  };

  final response = await http.patch(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(body),
  );

  if (response.statusCode == 200) {
    print('댓글 수정 성공');
    return true;
  } else {
    print('댓글 수정 실패: ${response.statusCode} ${response.body}');
    return false;
  }
}