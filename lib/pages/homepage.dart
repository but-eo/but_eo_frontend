import 'package:flutter/material.dart';
import 'package:project/widgets/image_slider_widgets.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> bannerUrlItems = [
      "assets/images/banner1.png",
      "assets/images/banner2.png",
    ];

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 카테고리 버튼
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
                  Text("최신글", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  _postItem("FC MNT 회원 모집 FW, MF (토요일 오전 6시)"),
                  _postItem("[광주] 일요일 오후 | 목요일 저녁 [주 2회]"),
                  _postItem("광명역세권FC 멤버 모집합니다"),
                  _postItem("강동 주말경기 하는 K.FC에서 선수 모집합니다"),
                  _postItem("[광주남구] 멤버 모집합니다~! ***10대~30대"),
                  _postItem("광주광역시 광산구 축구팀 Gw dream FC 팀"),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "홈"),
          BottomNavigationBarItem(icon: Icon(Icons.sports_soccer), label: "매칭찾기"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "채팅방"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "전적보기"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "마이페이지"),
        ],
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

  Widget _postItem(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(title, style: TextStyle(fontSize: 16))),
            Icon(Icons.comment, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}