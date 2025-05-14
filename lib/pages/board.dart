import 'package:flutter/material.dart';
import 'package:project/pages/board/board_page.dart';

class Board extends StatefulWidget {
  const Board({super.key});

  @override
  _BoardState createState() => _BoardState();
}

class _BoardState extends State<Board> {
  String selectedSport = '축구'; // 처음 선택된 스포츠



  // 스포츠별 게시판 리스트
  final Map<String, List<String>> boardCategories = {
    '축구': ['자유게시판', '팀찾기게시판', '팀원찾기게시판', '후기게시판', '경기장게시판'],
    '풋살': ['자유게시판', '팀찾기게시판', '팀원찾기게시판', '후기게시판', '경기장게시판'],
    '농구': ['자유게시판', '팀찾기게시판', '팀원찾기게시판', '후기게시판', '경기장게시판'],
    '탁구': ['자유게시판', '팀찾기게시판', '팀원찾기게시판', '후기게시판', '경기장게시판'],
    '볼링': ['자유게시판', '팀찾기게시판', '팀원찾기게시판', '후기게시판', '경기장게시판'],
    '테니스': ['자유게시판', '팀찾기게시판', '팀원찾기게시판', '후기게시판', '경기장게시판'],
    '배드민턴': ['자유게시판', '팀찾기게시판', '팀원찾기게시판', '후기게시판', '경기장게시판'],
    '야구': ['자유게시판', '팀찾기게시판', '팀원찾기게시판', '후기게시판', '경기장게시판'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 스포츠 카테고리 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _sportButton("축구"),
                    _sportButton("풋살"),
                    _sportButton("농구"),
                    _sportButton("탁구"),
                    _sportButton("볼링"),
                    _sportButton("테니스"),
                    _sportButton("배드민턴"),
                    _sportButton("야구"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // 선택된 스포츠 이름 보여주기
            Center(child: Text("$selectedSport 게시판", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),

            const SizedBox(height: 20),

            // 선택된 스포츠에 맞는 게시판 버튼 보여주기
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: boardCategories[selectedSport]!.map((category) {
                  return _boardButton(category);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 스포츠 버튼
  Widget _sportButton(String sport) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedSport = sport; // 누른 스포츠로 변경
          });
        },
        child: Text(sport),
      ),
    );
  }

  // 게시판 버튼
  Widget _boardButton(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(500, 45),
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BoardPage(
                event: selectedSport,
                category: title,
              ),
            ),
          );
        },
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

