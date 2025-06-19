import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:project/appStyle/app_colors.dart';
import 'package:project/chat/chatdetailpage.dart';
import 'package:project/contants/api_contants.dart';
import 'package:project/utils/token_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  void initState() {
    super.initState();
    loadChatRooms(); // 초기 로딩
  }

  List<Map<String, dynamic>> chatRooms = []; // 채팅방 리스트
  List<Map<String, dynamic>> localSearchResults = [];
  Map<String, bool> localSelectedUsers = {};

  Future<void> loadChatRooms() async {
    final dio = Dio();
    String? token = await TokenStorage.getAccessToken();
    print("채팅방 로드 요청 토큰 :   ${token}");
    if (token == null || token.isEmpty) {
      print("토큰이 유효하지 않습니다.");
      return;
    }
    try {
      final response = await dio.get(
        "${ApiConstants.webSocketConnectUrl}/searchChatRooms",
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      ); // <-- 여기는 실제 API 경로에 맞게 수정
      if (response.statusCode == 200 && response.data is List) {
        setState(() {
          chatRooms = List<Map<String, dynamic>>.from(response.data);
          print("채팅방 목록  : $chatRooms");
        });
      }
    } catch (e) {
      print("채팅방 로딩 실패 : $e");
    }
  }

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

                // searchAll(); // 이 함수는 현재 _showCreateChatDialog 내에서 호출되지 않으므로 필요에 따라 위치를 조정하거나 제거하세요.
              },
              icon: const Icon(Icons.add_comment),
              //person_add_alt_1_rounded
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: chatRooms.length,
          itemBuilder: (context, index) {
            final room = chatRooms[index];
            final size = MediaQuery.of(context).size;
            return ListTile(
              leading: CircleAvatar(
                backgroundImage:
                    room['chatImg'] != null && room['chatImg'] != ''
                        ? NetworkImage(
                          "${ApiConstants.webSocketConnectUrl}/chatRoom/${room['chatImg']}",
                        )
                        : const AssetImage('assets/images/butteoLogo.png')
                            as ImageProvider,
              ),
              title: Text(room['roomName'] ?? '채팅방'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(height: 10.0),
                      Text(
                        room['lastMessage'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  SizedBox(width: size.width * 0.5),
                  Text(
                    (room['lastMessageTime'] ?? ''),
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
              onTap: () async {
                print(room['lastMessageTime']);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatDetailpage(chatRoom: room),
                  ),
                );
                if (result == 'refresh') {
                  await loadChatRooms();
                }
                print("현재 접속 채팅방 :  ${room}");
              },
            );
          },
        ),
      ),
    );
  }

  // 채팅방 생성 다이얼로그
  void _showCreateChatDialog(BuildContext context) {
    TextEditingController _controller = TextEditingController();

    // 다이얼로그가 열릴 때 초기 친구 목록을 로드하도록 searchAll() 호출
    // 다이얼로그의 StatefulBuilder 내부에서 setState를 통해 localSearchResults를 업데이트해야 합니다.
    searchAllForDialog(); // 다이얼로그가 열릴 때 초기 검색 결과를 로드

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
                              // 검색 결과가 바뀔 때마다 기존 선택 상태 초기화
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
                    Expanded(
                      child: ListView.builder(
                        itemCount: localSearchResults.length,
                        itemBuilder: (context, index) {
                          final user = localSearchResults[index];
                          final userId = user['userHashId'].toString();
                          // 1. 서버에서 받은 프로필 경로를 변수에 저장합니다.
                          String profilePathFromServer = user['profile'] ?? '';

                          // 2. 프로필 경로가 http로 시작하는지 확인합니다.
                          final bool isFullUrl = profilePathFromServer
                              .startsWith('http');

                          // 3. 조건에 따라 최종 이미지 URL을 결정합니다.
                          //    (상대 경로일 경우 ApiConstants.imageBaseUrl을 앞에 붙여줍니다.)
                          String finalImageUrl =
                              isFullUrl
                                  ? profilePathFromServer
                                  : (profilePathFromServer.isNotEmpty
                                      ? '${ApiConstants.imageBaseUrl}$profilePathFromServer'
                                      : '');
                          return ListTile(
                            leading:
                                finalImageUrl
                                        .isNotEmpty // 1. 조건문을 finalImageUrl이 비어있는지로 변경
                                    ? CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        finalImageUrl,
                                      ),
                                      // 2. 여기서 finalImageUrl 사용!
                                      onBackgroundImageError: (
                                        exception,
                                        stackTrace,
                                      ) {
                                        // 이미지 로드 실패 시 콘솔에 로그 출력
                                        print(
                                          '이미지 로드 실패: $finalImageUrl, 에러: $exception',
                                        );
                                      },
                                    )
                                    : const CircleAvatar(
                                      child: Icon(Icons.person),
                                    ),
                            // 3. 이미지가 없을 때 기본 아이콘 표시
                            title: Text(user['name'] ?? '알 수 없는 사용자'),
                            trailing: Checkbox(
                              value: localSelectedUsers[userId] ?? false,
                              onChanged: (bool? value) {
                                setState(() {
                                  localSelectedUsers[userId] = value ?? false;
                                });
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
                      // 💡 채팅방 이름 생성 로직
                      String chatRoomName;
                      if (selected.length == 1) {
                        chatRoomName = selected[0]['name'] ?? '새 채팅방';
                      } else if (selected.length > 1) {
                        final firstTwoNames =
                            selected
                                .take(2)
                                .map((user) => user['name'] ?? '이름 없음')
                                .toList();
                        final remainingCount = selected.length - 2;
                        chatRoomName = '${firstTwoNames.join(', ')}';
                        if (remainingCount > 0) {
                          chatRoomName += ' 외 $remainingCount명';
                        }
                      } else {
                        chatRoomName = '새 채팅방';
                      }

                      final room = await createChatRoom(
                        selected.map((e) => e['userHashId']).toList(),
                        chatRoomName, // ✅ 생성된 이름 전달
                      );
                      if (room != null) {
                        // 메인 _ChatPageState의 setState를 호출하여 chatRooms 업데이트
                        setState(() {
                          // _ChatPageState의 setState
                          chatRooms.add(room);
                        });
                        Navigator.pop(context); // 다이얼로그 닫기

                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ChatDetailpage(chatRoom: room),
                          ),
                        );
                        if (result == 'refresh') {
                          await loadChatRooms();
                        }
                      }
                    }
                  },
                  child: Text("초대"),
                ),
                TextButton(
                  onPressed: () {
                    // 다이얼로그 닫기 전에 상태 초기화 (선택 사항)
                    setState(() {
                      // _showCreateChatDialog 내부의 setState
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

  // 다이얼로그가 열릴 때 전체 친구 목록을 로드하는 함수 (다이얼로그의 setState를 사용)
  Future<void> searchAllForDialog() async {
    final dio = Dio();
    String? token = await TokenStorage.getAccessToken(); // 토큰 필요할 수 있음
    try {
      final response = await dio.get(
        "${ApiConstants.baseUrl}/users/searchAll",
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ), // 토큰 필요시 추가
      );
      if (response.statusCode == 200 && response.data is List) {
        // StatefulBuilder의 setState를 통해 localSearchResults 업데이트
        if (mounted) {
          // 위젯이 마운트된 상태인지 확인
          (context as Element)
              .markNeedsBuild(); // StatefulBuilder의 setState를 직접 호출하는 대신 build를 강제
          // 대안: 다이얼로그 builder 내에서 StatefulWidget을 분리하거나,
          // StatefulBuilder의 setState 콜백을 명시적으로 사용해야 합니다.
          // 여기서는 setState가 다이얼로그의 build context에 바인딩되어 있으므로 직접 사용 가능
          setState(() {
            // 이 setState는 AlertDialog의 StatefulBuilder에 속함
            localSearchResults = List<Map<String, dynamic>>.from(response.data);
            localSelectedUsers.clear(); // 초기화
            for (var user in localSearchResults) {
              var userId = user['userHashId'].toString();
              localSelectedUsers[userId] = false;
            }
          });
          print('전체 친구 목록 로드됨: ${localSearchResults.length}명');
        }
      }
    } catch (e) {
      print('전체 친구 목록 로드 실패 : $e');
    }
  }
}

// 자기 자신 제외한 유저 검색 (수정 없음)
Future<List<Map<String, dynamic>>> searchUser(String nickname) async {
  final dio = Dio();
  String? token = await TokenStorage.getAccessToken();
  try {
    final response = await dio.get(
      "${ApiConstants.baseUrl}/users/search", //UserController
      options: Options(headers: {'Authorization': 'Bearer $token'}),
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

// 전체 친구 목록 검색 (다이얼로그에서 사용되지 않음 - 제거 또는 용도 변경 필요)
// 이 함수는 더 이상 _showCreateChatDialog 내에서 호출되지 않으므로 필요에 따라 제거하거나 용도를 변경하세요.
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

// 채팅방 생성 (chatRoomName 매개변수 추가)
Future<Map<String, dynamic>?> createChatRoom(
  List<dynamic> userIds,
  String chatRoomName,
) async {
  // ✅ chatRoomName 매개변수 추가
  final dio = Dio();
  String? token = await TokenStorage.getAccessToken();
  try {
    print('채팅방 생성 요청: $userIds, 이름: $chatRoomName');
    final response = await dio.post(
      "${ApiConstants.webSocketConnectUrl}/chatrooms",
      data: {"userHashId": userIds, "chatRoomName": chatRoomName}, // ✅ 이름 전달
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("create ChatROOM : ${response.data}");
      return response.data;
    }
  } catch (e) {
    print('채팅방 생성 실패: $e');
  }
  return null;
}
