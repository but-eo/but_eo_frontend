import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:project/appStyle/app_colors.dart';

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
                                var userId = user['id'].toString();
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
                          final userId = user['id'].toString();
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
                  onPressed: () {
                    final selected =
                        localSearchResults.where((user) {
                          return localSelectedUsers[user['id'].toString()] ==
                              true;
                        }).toList();
                    // 여기에서 선택된 유저를 처리 가능
                    Navigator.pop(context);
                  },
                  child: Text("초대"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
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
      "http://172.29.0.102:0714/api/users/search",
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
    final response = await dio.get(
      "http://172.29.0.102:0714/api/users/searchAll",
    );
    print('Response data : ${response.data}');
    if (response.statusCode == 200) {
      print('전체 친구 목록');
    }
  } catch (e) {
    print('검색 실패 : ${e}');
  }
}
