import 'package:flutter/material.dart';

import 'chat_area.dart';
import 'input_text_area.dart';

class ChatMainPage extends StatefulWidget {
  final String username;
  const ChatMainPage({super.key, required this.username});

  @override
  State<ChatMainPage> createState() => _ChatMainPageState();
}

class _ChatMainPageState extends State<ChatMainPage> {
  // 메시지 내용을 저장하는 변수
  List messageList = [];

  // 메시지 내용을 setState 함수를 통해 상태를 업데이트하는 함수
  void setStateMessage(data) {
    print("[chat_main.dart] (setStateMessage) 업데이트 할 값 : $data");
    setState(() => messageList.add(data));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("채팅방", textAlign: TextAlign.center), //채팅방
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context), // 뒤로가기
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search),
            ), //채팅 내용 검색
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.menu), //채팅방에 포함된 인원
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            // 메시지 내용 표시 영역
            ChatArea(messageList: messageList),
            // 메시지 입력 영역
            InputTextArea(
              username: widget.username,
              messageList: messageList,
              updateMessage: setStateMessage,
            ),
          ],
        ),
      ),
    );
  }
}
