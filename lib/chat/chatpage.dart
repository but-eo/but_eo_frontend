import 'package:flutter/material.dart';
import 'package:project/chat/chat_main.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Map<String, dynamic>> chatRooms = []; // 채팅방 리스트

  // 채팅방 추가 함수
  void _createChatRoom(String friendName) {
    setState(() {
      chatRooms.add({
        'roomName': friendName, // 채팅방 이름
        'lastMessage': '채팅을 시작하세요!', // 마지막 메시지 초기화
        'unreadCount': 0, // 안 읽은 메시지 개수
        'timestamp': DateTime.now(), // 최근 메시지 시간
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: chatRooms.length,
        itemBuilder: (context, index) {
          final chatRoom = chatRooms[index];

          return ListTile(
            leading: CircleAvatar(
              child: Text(chatRoom['roomName'][0]), // 첫 글자로 아이콘 표시
            ),
            title: Text(
              chatRoom['roomName'],
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              chatRoom['lastMessage'],
              style: TextStyle(color: Colors.grey),
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "오후 2:30", // 더미 시간 (나중에 수정 가능)
                  style: TextStyle(color: Colors.grey),
                ),
                if (chatRoom['unreadCount'] > 0)
                  Container(
                    padding: EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      chatRoom['unreadCount'].toString(),
                      style: TextStyle(color: Colors.white, fontSize: 12.0),
                    ),
                  ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ChatMainPage(username: chatRoom['roomName']),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateChatDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  // 채팅방 생성 다이얼로그
  void _showCreateChatDialog(BuildContext context) {
    TextEditingController _controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("새 채팅방 만들기"),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: "친구 이름 입력"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  _createChatRoom(_controller.text);
                  Navigator.pop(context);
                }
              },
              child: Text("생성"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("취소"),
            ),
          ],
        );
      },
    );
  }
}
