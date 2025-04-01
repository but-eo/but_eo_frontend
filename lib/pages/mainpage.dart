import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project/appStyle/app_colors.dart';
import 'package:project/pages/chatpage.dart';
import 'package:project/pages/homepage.dart';
import 'package:project/pages/login.dart';
import 'package:project/pages/logout.dart';
import 'package:project/pages/matchpage.dart';
import 'package:project/pages/mypage.dart';
import 'package:project/pages/recordpage.dart';
import 'package:project/widgets/bottom_navigation.dart';
import 'package:dio/dio.dart';
import 'package:project/widgets/image_slider_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Main extends StatefulWidget {
  static String id = "/main";

  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  String userName = "사용자";
  String profileImageUrl = ""; //프로필 이미지
  bool isLoading = true;

  @override
  void initState() {
    // 위젯 로딩이 실행될 때
    // TODO: implement initState
    super.initState();
    fetchUserInfo(); //
  }

  int _selectedIndex = 0;

  final List<Widget> _pages = [
    Homepage(),
    Matchpage(),
    ChatPage(),
    Recordpage(),
    Mypage(),
  ];

  //사용자 정보 불러오기 -> 토큰을 통해
  Future<void> fetchUserInfo() async {
    final dio = Dio();
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('accesstoken');

    if (token == null) {
      print("로그인이 필요합니다.");
      return;
    }

    try {
      final response = await dio.get(
        "http://192.168.45.179:0714/api/users/my-info",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      if (response.statusCode == 200) {
        print("사용자 정보 가져오기 성공: ${response.data}");
        // userName = response.data['name'];
        // profileImageUrl = response.data['profileImage'];
        isLoading = false;
      }
    } catch (e) {
      print("사용자 정보 가져오기 실패: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "BUTTEO",
            style: TextStyle(
              fontSize: 26.0,
              color: AppColors.baseBlackColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none),
            ),
            IconButton(
              onPressed: () {
                showMenu(
                  context: context,
                  position: RelativeRect.fromLTRB(
                    20,
                    20,
                    0,
                    0,
                  ), // 메뉴의 위치 설정 (left, top, right, bottom)
                  items: <PopupMenuEntry<dynamic>>[
                    PopupMenuItem<int>(
                      value: 1,
                      child: ListTile(
                        leading:
                            (profileImageUrl?.isNotEmpty ?? false)
                                ? CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    profileImageUrl!,
                                  ),
                                )
                                : CircleAvatar(
                                  backgroundColor: Colors.grey,
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.black,
                                  ),
                                ), // 기본 아이콘
                        title: Text(userName ?? "이름 없음"),
                      ),
                    ),
                    PopupMenuItem<int>(
                      value: 2, // 메뉴 항목의 값
                      child: Text('내 정보'),
                    ),
                    PopupMenuItem<int>(
                      value: 3, // 메뉴 항목의 값
                      child: Text('My Team'),
                    ),
                    PopupMenuItem<int>(
                      value: 4, // 메뉴 항목의 값
                      child: Text('경기 일정'),
                    ),
                    PopupMenuItem<int>(
                      value: 5, // 메뉴 항목의 값
                      child: Text('설정'),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem<int>(
                      onTap: () {
                        // logout(); //토큰 정보 삭제
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          //특정화면으로 이동하면서 이전 모든 화면을 스택에서 제거 (새 화면을 띄우고 뒤로가기 버튼을 눌러도 이전 화면으로 돌아갈 수 없음)
                          Login.id, //이동할 경로의 이름
                          (route) => false, //스택의 모든 화면 제거
                        );
                      },
                      value: 6, // 메뉴 항목의 값
                      child: Text('로그아웃'),
                    ),
                  ],
                ).then((value) {
                  if (value != null) {
                    // 팝업 메뉴에서 선택된 값에 따른 작업 처리
                    print("선택된 값: $value");
                  }
                });
              },
              icon: const Icon(Icons.menu),
            ),
          ],
        ),

        body: _pages[_selectedIndex],
        // bottomNavigationBar를 추가한 부분
        bottomNavigationBar: CustomBottomNavBar(
          selectedIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}



