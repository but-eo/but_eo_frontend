import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:project/appStyle/app_colors.dart';
import 'package:project/chat/chatdetailpage.dart';
import 'package:project/contants/api_contants.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Map<String, dynamic>> chatRooms = []; // 채팅방 리스트
  List<Map<String, dynamic>> localSearchResults = [];
  Map<String, bool> localSelectedUsers = {};

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, //
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "채팅",
            style: TextStyle(
              fontSize: 26.0,
              color: AppColors.baseBlackColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
            IconButton(
              onPressed: () {
                _showCreateChatDialog(context);
                searchAll();
              },
              icon: const Icon(Icons.add_comment),
              //person_add_alt_1_rounded
            ),
          ],
        ),
      ),
    );
  }

  // 채팅방 생성 다이얼로그
  void _showCreateChatDialog(BuildContext context) {
    TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("대화상대 선택"),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(hintText: "친구 이름 입력"),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () async {
                            final results = await searchUser(_controller.text);
                            setState(() {
                              localSearchResults = results;
                              localSelectedUsers.clear();
                              for (var user in localSearchResults) {
                                var userId = user['userHashId'].toString();
                                localSelectedUsers[userId] = false;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 250, //
                      child: ListView.builder(
                        itemCount: localSearchResults.length,
                        itemBuilder: (context, index) {
                          final user = localSearchResults[index];
                          final userId = user['userHashId'].toString();
                          return ListTile(
                            leading:
                                user['profile'] != null
                                    ? CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        user['profile'],
                                      ),
                                    )
                                    : CircleAvatar(child: Icon(Icons.person)),
                            title: Text(user['name']),
                            trailing: Checkbox(
                              value: localSelectedUsers[userId] ?? false,
                              onChanged: (bool? value) {
                                setState(() {
                                  localSelectedUsers[userId] = value ?? false;
                                });
                                print(localSelectedUsers[userId]);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    final selected =
                        localSearchResults.where((user) {
                          return localSelectedUsers[user['userHashId']
                                  .toString()] ==
                              true;
                        }).toList();

                    print(
                      '선택된 유저들: ${selected.map((e) => e['name']).toList()}',
                    );
                    print(
                      '선택된 유저 ID들: ${selected.map((e) => e['userHashId']).toList()}',
                    );

                    if (selected.isNotEmpty) {
                      final room = await createChatRoom(
                        selected.map((e) => e['userHashId']).toList(),
                      );
                      if (room != null) {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ChatDetailpage(chatRoom: room),
                          ),
                        );
                      }
                    }
                  },
                  child: Text("초대"),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      localSearchResults.clear();
                      localSelectedUsers.clear();
                    });
                    Navigator.pop(context);
                  },
                  child: Text("취소"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

Future<List<Map<String, dynamic>>> searchUser(String nickname) async {
  final dio = Dio();
  List<Map<String, dynamic>> searchResults = [];
  Map<String, bool> selectedUsers = {};
  try {
    final response = await dio.get(
      "${ApiConstants.baseUrl}/users/search",

      queryParameters: {'name': nickname},
    );
    if (response.statusCode == 200 && response.data is List) {
      print('${nickname} 검색결과 : ${response.data}');
      return List<Map<String, dynamic>>.from(response.data);
    }
  } catch (e) {
    print('검색 실패 : $e');
  }
  return [];
}

Future<void> searchAll() async {
  final dio = Dio();
  try {
    final response = await dio.get("${ApiConstants.baseUrl}/users/searchAll");
    print('Response data : ${response.data}');
    if (response.statusCode == 200) {
      print('전체 친구 목록');
    }
  } catch (e) {
    print('검색 실패 : ${e}');
  }
}

Future<Map<String, dynamic>?> createChatRoom(List<dynamic> userIds) async {
  final dio = Dio();
  try {
    print('채팅방 생성 요청: $userIds');
    final response = await dio.post(
      "${ApiConstants.baseUrl}/chatrooms",
      data: {"userHashId": userIds, "chatRoomName": "채팅방"},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data;
    }
  } catch (e) {
    print('채팅방 생성 실패: $e');
  }
  return null;
}
