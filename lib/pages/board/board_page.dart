import 'package:flutter/material.dart';
import 'package:project/pages/board/board_detail_page.dart';
import 'package:project/pages/board/widgets/board_list_item.dart';
import 'package:project/data/mock_posts.dart';


class BoardPage extends StatelessWidget {
  const BoardPage({super.key});


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
                    builder: (_) => BoardDetailPage(
                      title: post["title"],
                      content: "본문 내용 ~~",
                      author: post["writer"],
                      date: post["date"],
                      views: 123,  // 임의의 조회수, 실제 데이터로 교체해야 함
                    ),
                  ),
                );

              }
            );
          }
      ),
    );
  }
}
