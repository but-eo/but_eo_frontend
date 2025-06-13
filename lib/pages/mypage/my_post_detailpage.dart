import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:project/contants/api_contants.dart';
import 'package:project/utils/token_storage.dart';

class MyPostDetailPage extends StatefulWidget {
  final String boardId;
  const MyPostDetailPage({Key? key, required this.boardId}) : super(key: key);

  @override
  State<MyPostDetailPage> createState() => _MyPostDetailPageState();
}

class _MyPostDetailPageState extends State<MyPostDetailPage> {
  Map<String, dynamic>? _post;
  bool _isLoading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _fetchPostDetail();
  }

  Future<void> _fetchPostDetail() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      final token = await TokenStorage.getAccessToken();
      final dio = Dio();
      final res = await dio.get(
        // boardId로 상세 조회 (API 경로 맞춰서 수정)
        '${ApiConstants.baseUrl}/boards/${widget.boardId}',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (res.statusCode == 200 && res.data is Map) {
        setState(() {
          _post = res.data as Map<String, dynamic>;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMsg = "게시글을 불러오지 못했습니다.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMsg = "서버 오류가 발생했습니다.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('게시글 상세'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMsg != null
          ? Center(child: Text(_errorMsg!))
          : _post == null
          ? const Center(child: Text('데이터 없음'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              _post!['title'] ?? '제목 없음',
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  _post!['userName'] ?? '',
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(width: 16),
                Text(
                  _post!['createdAt']
                      ?.toString()
                      .substring(0, 10) ??
                      '',
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(),
            const SizedBox(height: 16),
            Text(
              _post!['content'] ?? '내용 없음',
              style: const TextStyle(fontSize: 16),
            ),
            // 필요시 이미지 등 추가
          ],
        ),
      ),
    );
  }
}
