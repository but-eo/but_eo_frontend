import 'package:flutter/material.dart';
import 'package:project/pages/board/board_detail_page.dart';
import 'package:project/http/http.dart';

class BoardPage extends StatelessWidget {
  final String sport;
  final String category;

  const BoardPage({required this.sport, required this.category, super.key});


  // 더미 게시글 리스트
  final List<Map<String, String>> dummyPosts = const [
    {
      'title': '축구 같이 하실 분 구해요!',
      'content': '내일 오후 3시에 경기할 사람 구합니다.',
    },
    {
      'title': '경기 후기 남겨요',
      'content': '어제 경기 정말 재미있었어요!',
    },
    {
      'title': '모집합니다!',
      'content': '팀원 2명 더 필요해요!',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$sport - $category')),
      body: ListView.builder(
        itemCount: dummyPosts.length,
        itemBuilder: (context, index) {
          final post = dummyPosts[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              title: Text(
                post['title'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(post['content'] ?? ''),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BoardDetailPage(post: post),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
