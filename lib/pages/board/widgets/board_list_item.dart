import 'package:flutter/material.dart';

class BoardListItem extends StatelessWidget {
  final String title;
  final String category;
  final String writer;
  final String date;
  final int commentCount;
  final VoidCallback? onTap;

  const BoardListItem({
    super.key,
    required this.title,
    required this.category,
    required this.writer,
    required this.date,
    required this.commentCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // 여기서 onTap 실행
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(category, style: const TextStyle(color: Colors.grey)),
                const SizedBox(width: 8),
                Text(writer, style: const TextStyle(color: Colors.grey)),
                const SizedBox(width: 8),
                Text(date, style: const TextStyle(color: Colors.grey)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text("$commentCount 댓글", style: const TextStyle(fontSize: 12)),
                )
              ],
            ),
            const Divider(height: 24, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
