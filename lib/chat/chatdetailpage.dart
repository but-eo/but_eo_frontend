import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:project/contants/api_contants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'dart:convert';

class ChatDetailpage extends StatefulWidget {
  final Map<String, dynamic> chatRoom;

  const ChatDetailpage({super.key, required this.chatRoom});

  @override
  State<ChatDetailpage> createState() => _ChatDetailpageState();
}

class _ChatDetailpageState extends State<ChatDetailpage> {
  List<Map<String, dynamic>> messages = []; // 메시지 리스트
  TextEditingController messageController = TextEditingController();
  StompClient? stompClient;
  String userName = "사용자";
  String profileImageUrl = ""; //프로필 이미지
  String userHashId = "";

  @override
  void initState() {
    super.initState();
    //stompConfig 설정
    fetchUserInfo().then((_) {
      stompClient = StompClient(
        config: StompConfig.sockJS(
          url: '${ApiConstants.webSocketUrl}/ws', // 서버의 WebSocket URL
          onConnect: onStompConnected,
          onWebSocketError: (dynamic error) => print('WebSocket Error: $error'),
        ),
      );
      stompClient!.activate();
      loadMessages();
    });
  }

  //웹소켓 연결후 메세지 구독
  void onStompConnected(StompFrame frame) {
    stompClient!.subscribe(
      destination: '/api/chatroom/${widget.chatRoom['id']}',
      callback: (frame) {
        if (frame.body != null) {
          final msg = jsonDecode(frame.body!);
          setState(() {
            messages.add(msg); // 새 메시지만 추가
          });
        }
      },
    );
  }

  Future<void> fetchUserInfo() async {
    final dio = Dio();
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('accessToken');

    if (token == null) {
      print("로그인이 필요합니다.");
      return;
    }

    try {
      final response = await dio.get(
        "${ApiConstants.baseUrl}/users/me",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      if (response.statusCode == 200) {
        print("사용자 정보 가져오기 성공: ${response.data}");
        userHashId = response.data['userHashId'];
        userName = response.data['name'];
        profileImageUrl = response.data['profile'];
      }
    } catch (e) {
      print("사용자 정보 가져오기 실패: $e");
    }
  }

  //과거 메세지 불러오기
  Future<void> loadMessages() async {
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

  Future<void> sendMessage(String senderHashId, String text, DateTime sendTime) async {
    if (stompClient != null && stompClient!.connected) {
      stompClient!.send(
        destination: '${ApiConstants.baseUrl}/api/chatroom/${widget.chatRoom['id']}/send',
        body: '{"sender" : "$senderHashId", "message": "$text", "sendTime" : "$sendTime"}',
        headers: {'content-type': 'application/json'},
      );
      messageController.clear();
    } else {
      print('STOMP 연결되지 않음');
    }
  }

  

  @override
  void dispose() {
    stompClient?.deactivate();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("채팅방", style: TextStyle(fontSize: 16)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          Builder(
            builder:
                (context) => IconButton(
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                  icon: const Icon(Icons.menu),
                ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DrawerHeader(
              child: Text('채팅방 메뉴', style: TextStyle(fontSize: 18)),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('참여자 목록'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('채팅방 나가기'),
              onTap: () {
                //TODO: 채팅방 나가기
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isMine = message['senderId'] == userHashId; // 내 메시지인지 판별

                return Align(
                  alignment:
                      isMine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isMine ? Colors.blue[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          isMine
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                      children: [
                        Text(
                          message['senderName'] ?? "알 수 없음",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message['content'] ?? '',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
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
                      sendMessage(userHashId, messageController.text, DateTime.now());
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
