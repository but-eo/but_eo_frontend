import 'package:flutter/material.dart';

class FAQDetailPage extends StatelessWidget {
  final Map<String, String> inquiry;

  const FAQDetailPage({super.key, required this.inquiry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('질문 상세')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              inquiry['title'] ?? '',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(inquiry['content'] ?? ''),
            const Divider(height: 32),
            Text(
              inquiry['answer'] != null ? '📬 답변:\n${inquiry['answer']}' : '⏳ 답변 준비 중',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
