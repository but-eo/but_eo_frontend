// lib/service/board_api_get_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project/model/board_model.dart';
import 'package:project/model/board_detail_model.dart';
import 'package:project/contants/api_contants.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 게시판 리스트 조회
Future<List<Board>> fetchBoards(String event, String category, {int page = 0, int size = 10}) async {
  final uri = Uri.parse(
    '${ApiConstants.baseUrl}/boards?event=$event&category=$category&page=$page&size=$size',
  );

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final decoded = utf8.decode(response.bodyBytes);
    final List<dynamic> data = json.decode(decoded);
    print(data);
    return data.map((item) => Board.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load boards');
  }
}

// 게시판 클릭시 상세 게시판 조회
Future<BoardDetail> fetchBoardDetail(String boardId) async {
  final uri = Uri.parse('${ApiConstants.baseUrl}/boards/$boardId');
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final data = json.decode(utf8.decode(response.bodyBytes));
    print(data);
    return BoardDetail.fromJson(data);
  } else {
    throw Exception('Failed to fetch board detail');
  }
}

// 게시글 삭제
Future<bool> deleteBoard(String boardId) async {
  final uri = Uri.parse('${ApiConstants.baseUrl}/boards/$boardId');

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken'); // JWT 토큰

  final response = await http.delete(
    uri,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    return true;
  } else {
    print('게시글 삭제 실패: ${response.statusCode} ${response.body}');
    return false;
  }
}