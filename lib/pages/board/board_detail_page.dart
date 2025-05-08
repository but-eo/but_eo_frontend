import 'package:flutter/material.dart';

class BoardDetailPage extends StatelessWidget {
  final Map<String, dynamic> post;

  const BoardDetailPage({required this.post, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(post['title'] ?? '제목 없음'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post['title'] ?? '제목 없음',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              post['author'] ?? '작성자 없음',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const Divider(height: 30, thickness: 1),
            Text(
              post['content'] ?? '내용이 없습니다.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
