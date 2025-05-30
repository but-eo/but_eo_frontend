import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project/appStyle/app_colors.dart';
import 'package:project/chat/chatpage.dart';
import 'package:project/contants/api_contants.dart';
import 'package:project/pages/Board.dart';
import 'package:project/pages/homepage.dart';
import 'package:project/pages/login/login.dart';
import 'package:project/pages/login/logout.dart';
import 'package:project/pages/match/matchpage.dart';
import 'package:project/pages/mypage/mypage.dart';
import 'package:project/pages/team/teamSearchPage.dart';
import 'package:project/widgets/bottom_navigation.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Main extends StatefulWidget {
  static String id = "/main";

  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  String userName = "사용자";
  String profileImageUrl = "";
  bool isLoading = true;
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    Homepage(),
    Matchpage(),
    ChatPage(),
    Board(),
    TeamSearchPage(),
    MyPageScreen(),
  ];

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
    printAccessToken("MainPage");
  }

  Future<void> printAccessToken(String label) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    print("🔑 [$label] accessToken: $token");
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
        print("👤 사용자 정보 응답: ${response.data}");
        final profile = response.data['profile'];
        final timestamp = DateTime.now().millisecondsSinceEpoch;

        setState(() {
          userName = response.data['name'] ?? "이름 없음";
          profileImageUrl = (profile != null && profile.toString().isNotEmpty)
              ? (profile.toString().startsWith("http")
              ? profile.toString()
              : "${ApiConstants.imageBaseUrl}$profile") + "?v=$timestamp"
              : "${ApiConstants.imageBaseUrl}/uploads/profiles/default_profile.png?v=$timestamp";
          isLoading = false;
        });
      }
    } catch (e) {
      print("사용자 정보 가져오기 실패: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: _selectedIndex == 2
            ? null
            : AppBar(
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
            IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
            IconButton(
              onPressed: () async {
                await fetchUserInfo(); // ✅ 메뉴 열기 전에 사용자 정보 최신화

                showMenu(
                  context: context,
                  position: RelativeRect.fromLTRB(20, 20, 0, 0),
                  items: <PopupMenuEntry<dynamic>>[
                    PopupMenuItem<int>(
                      value: 1,
                      child: ListTile(
                        leading: profileImageUrl.isNotEmpty
                            ? CircleAvatar(
                          backgroundImage: NetworkImage(profileImageUrl),
                          key: ValueKey(profileImageUrl), // 강제 리렌더링
                        )
                            : CircleAvatar(
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.person, color: Colors.black),
                        ),
                        title: Text(userName),
                      ),
                    ),
                    PopupMenuItem<int>(
                      value: 2,
                      child: Text('내 정보'),
                    ),
                    PopupMenuItem<int>(
                      value: 3,
                      child: Text('My Team'),
                      onTap: () {
                        Navigator.of(context).pushNamed('/myteam');
                      },
                    ),
                    PopupMenuItem<int>(
                      value: 4,
                      child: Text('경기 일정'),
                    ),
                    PopupMenuItem<int>(
                      value: 5,
                      child: Text('설정'),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem<int>(
                      value: 6,
                      onTap: () {
                        logout();
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          Login.id,
                              (route) => false,
                        );
                      },
                      child: Text('로그아웃'),
                    ),
                  ],
                ).then((value) {
                  if (value != null) {
                    print("선택된 값: $value");
                  }
                });
              },
              icon: const Icon(Icons.menu),
            ),
          ],
        ),
        body: _pages[_selectedIndex],
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
