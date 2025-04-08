import 'package:flutter/material.dart';
import 'package:project/pages/board/board_detail_page.dart';
import 'package:project/pages/board/widgets/board_list_item.dart';

class BoardPage extends StatelessWidget {
  const BoardPage({super.key});

  final List<Map<String, dynamic>> mockPosts = const [
    {
      "title": "배드민턴 라켓",
      "category": "자유",
      "writer": "작성자",
      "date": "15.03.28",
      "comments": 3,
    },
    {
      "title": "맨유 요즘 왜이럼?",
      "category": "자유",
      "writer": "작성자",
      "date": "15.03.28",
      "comments": 7,
    },
    {
      "title": "계대에서 농구할사람",
      "category": "자유",
      "writer": "작성자",
      "date": "15.03.28",
      "comments": 3,
    },
    {
      "title": "손흥민 폼 미쳤다",
      "category": "자유",
      "writer": "작성자",
      "date": "15.03.28",
      "comments": 3,
    },
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("자유게시판"),
      ),
      body: ListView.builder(
          itemCount: mockPosts.length,
          itemBuilder: (context, index) {
            final post = mockPosts[index];
            return BoardListItem(
                title: post["title"],
                category: post["category"],
                writer: post["writer"],
                date: post["date"],
                commentCount: post["comments"],
              onTap :() {
                  Navigator.push(
                      context, 
                      MaterialPageRoute(
                          builder: (_) => BoardDetailPage(title: post["title"]))
                  );
              }
            );
          }
      ),
    );
  }
}
