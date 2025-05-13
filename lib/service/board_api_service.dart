import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project/model/board_model.dart';

Future<List<Board>> fetchBoards(String event, String category, {int page = 0, int size = 10}) async {
  final uri = Uri.parse(
    'http://192.168.0.70:714/api/boards?event=$event&category=$category&page=$page&size=$size',
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

