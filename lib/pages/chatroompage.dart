import 'package:flutter/material.dart';
import 'package:project/widgets/image_slider_widgets.dart';

class ChatRoomPage extends StatelessWidget {
  final String userName;
  ChatRoomPage({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(userName, textAlign: TextAlign.center), //채팅방
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // 뒤로가기
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)), //채팅 내용 검색
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.menu), //채팅방에 포함된 인원 
          ),
        ],
      ),
      body: Center(child: Text('$userName 님과의 채팅')),
    );
  }
}
