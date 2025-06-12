import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:project/contants/api_contants.dart';
import 'package:project/utils/token_storage.dart';
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

  //채팅방 참여자 목록
  List<Map<String, dynamic>> participants = [];

  @override
  void initState() {
    super.initState();
    //stompConfig 설정
    fetchUserInfo().then((_) async {
      String? token = await TokenStorage.getAccessToken();
      stompClient = StompClient(
        config: StompConfig.sockJS(
          url: '${ApiConstants.webSocketConnectUrl}/ws', // 서버의 WebSocket URL
          onConnect: onStompConnected,
          onWebSocketError: (dynamic error) => print('WebSocket Error: $error'),
          webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
          stompConnectHeaders: {'Authorization': 'Bearer $token'},
        ),
      );
      stompClient!.activate();
      loadMessages();
    });
    fetchUsers(widget.chatRoom['roomId'].toString());
  }

  //웹소켓 연결후 메세지 구독
  void onStompConnected(StompFrame frame) {
    stompClient!.subscribe(
      destination: '/all/chat/${widget.chatRoom['roomId']}',
      callback: (frame) {
        if (frame.body != null) {
          final newMsg = jsonDecode(frame.body!);
          print(newMsg);
          setState(() {
            messages.add(newMsg); // 실시간 새 메시지만 추가
          });
        }
      },
    );

    print("채팅방 아이디 : ${widget.chatRoom['roomId']}");
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
        setState(() {
          userHashId = response.data['userHashId'];
          userName = response.data['name'];
          profileImageUrl = response.data['profile'];
        });
      }
    } catch (e) {
      print("사용자 정보 가져오기 실패: $e");
    }
  }

  // 과거 메세지 불러오기
  Future<void> loadMessages() async {
    final dio = Dio();
    try {
      final response = await dio.get(
        "${ApiConstants.webSocketConnectUrl}/load/messages/${widget.chatRoom['roomId']}",
      );
      if (response.statusCode == 200) {
        setState(() {
          messages = List<Map<String, dynamic>>.from(response.data);
        });
        print(response.data);
      }
    } catch (e) {
      print('메시지 불러오기 실패: $e');
    }
  }

  Future<void> sendMessage(
      String chatroomId,
      String senderHashId,
      String text,
      ) async {
    if (stompClient != null && stompClient!.connected) {
      final localMsg = {
        "chatroomId": chatroomId,
        "sender": senderHashId,
        "message": text,
        "nickName": userName,
      };
      stompClient!.send(
        destination: '/app/chat/message',
        body:
        '{"chatroomId" : "$chatroomId" , "sender" : "$senderHashId", "message": "$text"}',
        headers: {'content-type': 'application/json'},
      );
      messageController.clear();
    } else {
      print('STOMP 연결되지 않음');
    }
  }

  Future<bool> exitChatRoom(String chatRoomId) async {
    try {
      final dio = Dio();
      final token = await TokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        print("인증 토큰이 존재하지 않습니다.");
        return false;
        ;
      }
      final response = await dio.post(
        "${ApiConstants.webSocketConnectUrl}/exit/ChatRoom/${chatRoomId}",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      print("token : ${token}");
      if (response.statusCode == 200 || response.statusCode == 204) {
        print("채팅방 나가기 성공!");
        Navigator.pop(context);
        return true;
      } else {
        print("채팅방 나가기 실패 - 상태 코드: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("채팅방 나가기 실패 ${e}");
      return false;
    }
  }

  Future<void> fetchUsers(String chatRoomId) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        "${ApiConstants.webSocketConnectUrl}/load/members/${chatRoomId}",
      );
      if (response.statusCode == 200) {
        setState(() {
          participants = List<Map<String, dynamic>>.from(response.data);
          print("채팅방 유저 리스트 조회 성공: $participants");
        });
      } else {
        print("채팅방 유저 리스트 조회 실패 : ${response.statusCode}");
      }
    } catch (e) {
      print("채팅방 유저 리스트 조회 실패 : ${e}");
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
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          Navigator.pop(context, 'refresh'); // refresh를 리턴하며 pop
        }
      },
      child: Scaffold(
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
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                child: Text('채팅방 메뉴', style: TextStyle(fontSize: 18)),
              ),
              ExpansionTile(
                leading: const Icon(Icons.people),
                title: const Text('참여자 목록'),
                children: <Widget>[
                  // 각 참여자를 ListTile로 표시 (참여자가 항상 있다고 가정)
                  ...participants.map((participant) {
                    final String name =
                        participant['nickName'] ?? '유저'; // 이름이 없을 경우 기본값 설정
                    final String? profileImageUrl =
                    participant['profile']; // 프로필 이미지 URL (nullable)
                    return ListTile(
                      leading: CircleAvatar(
                        // profileImageUrl이 존재하면 NetworkImage를 사용하고,
                        // 없으면 기본 아이콘이나 Asset 이미지를 사용합니다.
                        backgroundImage:
                        profileImageUrl != null &&
                            profileImageUrl.isNotEmpty
                            ? NetworkImage(profileImageUrl)
                        as ImageProvider<Object>?
                            : null, // profileImageUrl이 없으면 null로 설정
                        child:
                        profileImageUrl == null || profileImageUrl.isEmpty
                            ? const Icon(
                          Icons.person,
                        ) // 프로필 이미지가 없으면 기본 아이콘
                            : null, // 이미지가 있으면 child는 null
                      ),
                      // title: 참여자의 이름을 표시합니다.
                      title: Text(name),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 4.0,
                      ),
                    );
                  }).toList(),
                ],
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text('채팅방 나가기'),
                onTap: () async {
                  final bool success = await exitChatRoom(
                    widget.chatRoom['roomId'].toString(),
                  );
                  if (success) {
                    Navigator.pop(context, 'refresh');
                    print("채팅방 나가기 성공");
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('채팅방 나가기에 실패했습니다.')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: false,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isMine = message['sender'] == userHashId; // 내 메시지인지 판별
                  print(
                    'userHashId: $userHashId, message sender: ${message['sender']}',
                  );
                  return Align(
                    alignment:
                    isMine
                        ? Alignment.centerRight
                        : Alignment
                        .centerLeft, //내가 보낸 메세지면 오른쪽 배치, 아니면 왼쪽 배치
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
                            message['nickName'] ?? "알 수 없음",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            message['message'] ?? '',
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
                    onPressed: () async {
                      if (messageController.text.isNotEmpty) {
                        print(
                          "메세지 전송 : ${widget.chatRoom['roomId'].toString()} , ${messageController.text}",
                        );
                        await sendMessage(
                          widget.chatRoom['roomId'].toString(),
                          userHashId,
                          messageController.text,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}