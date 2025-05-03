import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:project/contants/api_contants.dart';

class ChatDetailpage extends StatefulWidget {
  final Map<String, dynamic> chatRoom;

  const ChatDetailpage({super.key, required this.chatRoom});

  @override
  State<ChatDetailpage> createState() => _ChatDetailpageState();
}

class _ChatDetailpageState extends State<ChatDetailpage> {
  List<Map<String, dynamic>> messages = []; // 메시지 리스트
  TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadMessages();
  }

  Future<void> loadMessages() async {
    // 채팅방의 메시지 불러오기 API
    final dio = Dio();
    try {
      final response = await dio.get(
        "${ApiConstants.baseUrl}/chatrooms/${widget.chatRoom['id']}/messages",
      );
      if (response.statusCode == 200) {
        setState(() {
          messages = List<Map<String, dynamic>>.from(response.data);
        });
      }
    } catch (e) {
      print('메시지 불러오기 실패: $e');
    }
  }

  Future<void> sendMessage(String text) async {
    final dio = Dio();
    try {
      final response = await dio.post(
        "${ApiConstants.baseUrl}/chatrooms/${widget.chatRoom['id']}/messages",
        data: {"message": text},
      );
      if (response.statusCode == 200) {
        messageController.clear();
        loadMessages(); // 새 메시지 포함해 다시 불러오기
      }
    } catch (e) {
      print('메시지 전송 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("채팅방")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return ListTile(
                  title: Text(message['senderName'] ?? "알 수 없음"),
                  subtitle: Text(message['content']),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(hintText: "메시지 입력"),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (messageController.text.isNotEmpty) {
                      sendMessage(messageController.text);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
