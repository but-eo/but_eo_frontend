import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap; //int 타입의 매개변수를 받는 함수를 저장할 수 있는 변수

  CustomBottomNavBar(
    {required this.selectedIndex, 
    required this.onTap}
  );

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onTap,
      selectedItemColor: Colors.black, // 선택된 아이템 색상 (검은색)
      unselectedItemColor: Colors.grey, // 선택되지 않은 아이템 색상 (회색)
      showUnselectedLabels: true, // 선택되지 않은 아이템의 레이블을 표시
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "홈",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.stadium),
          label: "매칭찾기",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: "채팅방",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.scoreboard),
          label: "전적보기",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "마이페이지",
        ),
      ],
    );
  }
}
