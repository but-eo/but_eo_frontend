import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  CustomBottomNavBar({
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onTap,
      backgroundColor: Colors.white, // ✅ 하단 배경색 흰색으로 지정
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
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
          label: "게시판",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_outlined),
          label: "팀 찾기",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "마이페이지",
        ),
      ],
    );
  }
}
