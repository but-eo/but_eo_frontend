import 'package:flutter/material.dart';
import 'package:project/data/mock_posts.dart';
import 'package:project/pages/board/board_detail_page.dart';
import 'package:project/pages/board/board_page.dart';
import 'package:project/widgets/image_slider_widgets.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> bannerUrlItems = [
      "assets/images/banner1.png",
      "assets/images/banner2.png",
    ];

    final latestPosts = mockPosts.take(5).toList(); //최근 5개 글 조회

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 카테고리리 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _categoryButton("축구"),
                    _categoryButton("풋살"),
                    _categoryButton("농구"),
                    _categoryButton("탁구"),
                    _categoryButton("볼링"),
                    _categoryButton("테니스"),
                    _categoryButton("배드민턴"),
                    _categoryButton("야구"),
                  ],
                ),
              ),
            ),
            // 배너 슬라이더
            SizedBox(
                height: 200,
                width: double.infinity,
                child: ImageSliderWidgets(
                    bannerUrlItems: bannerUrlItems
                )
            ),

            // 공지사항
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _noticeItem("공지사항"),
                    _noticeItem("공지사항"),
                  ],
                ),
              ),
            ),

            // 최신글 목록
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => {
                      // Navigator.push(
                      //     context,
                      //     // MaterialPageRoute(builder: (_) => const BoardPage(),
                      // ),
                    },
                    child: const Text("최신글",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: mockPosts.length,
                    itemBuilder: (context, index) {
                      final  post = mockPosts[index];
                      return _postItem(post, context);
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),

    );
  }

  Widget _categoryButton(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ElevatedButton(
        onPressed: () {},
        child: Text(title),
      ),
    );
  }

  Widget _noticeItem(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: EdgeInsets.all(12),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(title, style: TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _postItem(Map<String, dynamic> post, BuildContext context) {
    return GestureDetector(
      onTap: (){
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (_) => BoardDetailPage(
        //             title: post["title"],
        //             content: post["content"],
        //             author: post["writer"],
        //             date: post["date"],
        //             views: post["views"],
        //         )
        //     ),
        // );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(post["title"], style: TextStyle(fontSize: 16))),
              Row(
                  children:[
                    Icon(
                        Icons.comment,
                        size: 18,
                        color: Colors.grey),
                    const SizedBox(width: 4,),
                    Text("${post["comments"]}",
                        style: TextStyle(color: Colors.grey))
                  ]
              ),
            ],
          ),
        ),
      ),
    );
  }
}