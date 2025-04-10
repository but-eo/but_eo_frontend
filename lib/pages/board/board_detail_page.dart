import 'package:flutter/material.dart';

class BoardDetailPage extends StatelessWidget {
  final String title;
  final String content;
  final String author;
  final String date;
  final int views;

  const BoardDetailPage({
    super.key,
    required this.title,
    required this.content,
    required this.author,
    required this.date,
    required this.views,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("게시글 상세")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  author,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  date,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.remove_red_eye, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '조회수 $views',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              content,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
