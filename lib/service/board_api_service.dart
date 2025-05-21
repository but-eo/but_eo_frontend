import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project/model/board_model.dart';
import 'package:project/model/board_detail_model.dart';
import 'package:project/model/board_comment_model.dart';
import 'package:project/contants/api_contants.dart';

Future<List<Board>> fetchBoards(String event, String category, {int page = 0, int size = 10}) async { // 게시판 리스트 조회
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

Future<BoardDetail> fetchBoardDetail(String boardId) async { // 게시판 클릭시 상세 게시판 조회
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

Future<List<Comment>> fetchComments(String boardId) async {
  final uri = Uri.parse('${ApiConstants.baseUrl}/comments/board/$boardId');

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
    print("댓글 데이터 :");
    print(data);
    return data.map((item) => Comment.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load comments');
  }
}

