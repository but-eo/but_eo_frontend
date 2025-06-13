import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:project/utils/token_storage.dart';
import 'package:project/contants/api_contants.dart';
import 'package:project/pages/board/board_detail_page.dart'; // 상세페이지 import

class MyPostsPage extends StatefulWidget {
  const MyPostsPage({Key? key}) : super(key: key);

  @override
  State<MyPostsPage> createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage> {
  List<dynamic> _posts = [];
  bool _isLoading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _fetchMyPosts();
  }

  Future<void> _fetchMyPosts() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    try {
      final token = await TokenStorage.getAccessToken();
      final dio = Dio();
      final res = await dio.get(
        '${ApiConstants.baseUrl}/boards/my',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (res.statusCode == 200 && res.data is Map && res.data['content'] is List) {
        setState(() {
          _posts = res.data['content'] as List<dynamic>;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMsg = "내가 작성한 글을 불러오지 못했습니다.";
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

  // 카드 스타일(마이페이지 느낌)
  Widget _buildPostCard(dynamic post) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          // 상세 페이지 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BoardDetailPage(boardId: post['boardId']),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목 (Bold, max 1줄)
              Text(
                post['title'] ?? '제목 없음',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              // 종목/카테고리 or 요약/내용
              Row(
                children: [
                  _buildTag(post['category'] ?? ''),
                  const SizedBox(width: 6),
                  _buildTag(post['event'] ?? ''),
                ],
              ),
              const SizedBox(height: 12),
              // 날짜, 댓글수, 좋아요
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    post['createdAt']?.toString().substring(0, 10) ?? "",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  Row(
                    children: [
                      Icon(Icons.mode_comment_outlined, size: 17, color: Colors.grey.shade600),
                      const SizedBox(width: 3),
                      Text('${post['commentCount'] ?? 0}',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                      const SizedBox(width: 10),
                      Icon(Icons.thumb_up_off_alt, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 3),
                      Text('${post['likeCount'] ?? 0}',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String tag) {
    if (tag.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 9),
      margin: const EdgeInsets.only(right: 2),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.shade100, width: 1),
      ),
      child: Text(
        tag,
        style: const TextStyle(fontSize: 12, color: Colors.blue),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('내가 작성한 글 보기'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMsg != null
          ? Center(child: Text(_errorMsg!))
          : _posts.isEmpty
          ? const Center(child: Text('작성한 글이 없습니다.'))
          : RefreshIndicator(
        onRefresh: _fetchMyPosts,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _posts.length,
          itemBuilder: (context, idx) {
            final post = _posts[idx];
            return _buildPostCard(post);
          },
        ),
      ),
    );
  }
}
