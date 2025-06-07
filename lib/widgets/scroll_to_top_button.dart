import 'package:flutter/material.dart';

class ScrollToTopButton extends StatelessWidget {
  final ScrollController scrollController;

  const ScrollToTopButton({Key? key, required this.scrollController})
    : super(key: key);

  void _scrollToTop() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _scrollToTop,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5), // 반투명 흰색 배경
          border: Border.all(color: Colors.grey), // 회색 테두리
          shape: BoxShape.circle, // 완전한 원형
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text("▲", style: TextStyle(fontSize: 14, color: Colors.black)),
            Text("맨위로", style: TextStyle(fontSize: 10, color: Colors.black)),
          ],
        ),
      ),
    );
  }
}
