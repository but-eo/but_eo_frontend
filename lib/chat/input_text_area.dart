import 'dart:io';
import 'package:flutter/material.dart';
import 'package:project/chat/socket.dart';

 
class InputTextArea extends StatefulWidget {
  final String username;
  final List messageList;
  final Function updateMessage;
  const InputTextArea(
      {super.key,
      required this.username,
      required this.messageList,
      required this.updateMessage});
 
  @override
  State<InputTextArea> createState() => _InputTextAreaState();
}
 
class _InputTextAreaState extends State<InputTextArea> {
  final TextEditingController _controller = TextEditingController();
 
  // 웹소켓 할당을 위한 변수
  final FlutterWebSocket flutterWebSocket = FlutterWebSocket();
  WebSocket? socket;
 
  @override
  void initState() {
    super.initState();
 
    createSocket(); // 웹소켓 서버 연결하기
  }
 
  // 서버 연결
  void createSocket() async {
    try {
      socket = await flutterWebSocket.getSocket();
 
      // 클라이언트 초기 설정 (서버측 클라이언트 정보 알림용 메시지 전송)
      flutterWebSocket.addMessage(socket, widget.username, "", "init");
 
      socket?.listen((data) {
        print("[input_text_area.dart] (createSocket) 서버로부터 받은 값 : $data");
        setState(() {
          widget.updateMessage(data);
        });
      });
    } catch (e) {
      print("[input_text_area.dart] (createSocket) 소켓 서버 접속 오류");
    }
  }
 
  // 메시지 보내기
  void sendMessage() {
    if (_controller.text.trim().isNotEmpty) {
      String message = _controller.text; // 메시지 내용
      String messageType = ""; // 메시지 타입
 
      // 귓속말 명령어 확인
      //    예) /w 사용자 내용
      //        - /w : 귓속말 명령어
      //        - 사용자 : 귓속말 보낼 사용자
      //        - 내용 : 귓속말 내용
      if (_controller.text.split(" ")[0] == "/w") {
        messageType = "whisper|${_controller.text.split(" ")[1]}";
        String excludeString =
            "${_controller.text.split(" ")[0]} ${_controller.text.split(" ")[1]}";
 
        message = "(귓속말)${_controller.text.replaceFirst(excludeString, "")}";
      }
      // 귓속말 명령어가 없으면 모두에게 메시지 보내기
      else {
        messageType = "all";
      }
 
      // 웹소켓 서버에 메시지 내용 전송
      flutterWebSocket.addMessage(
          socket, widget.username, message, messageType);
 
      _controller.clear();
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          // 메시지 입력란
          Expanded(
            child: TextField(
              controller: _controller,
              decoration:
                  const InputDecoration(labelText: 'Enter your message'),
            ),
          ),
          // 전송버튼
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => sendMessage(), // 메시지 보내기
          ),
        ],
      ),
    );
  }
}