import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project/appStyle/app_colors.dart';
import 'package:project/chat/chatpage.dart';
import 'package:project/pages/board/Board.dart';
import 'package:project/contants/api_contants.dart';
import 'package:project/pages/homepage.dart';
import 'package:project/pages/login/login.dart';
import 'package:project/pages/login/logout.dart';
import 'package:project/pages/match/matchpage.dart';
import 'package:project/pages/mypage/mypage.dart';
import 'package:project/pages/team/teamSearchPage.dart';
import 'package:project/service/teamService.dart';
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
  List<Map<String, dynamic>> leaderTeam = [];
  TeamService teamService = TeamService();
  String userName = "사용자";
  String profileImageUrl = "";
  bool isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
    fetchLeaderTeam();
    printAccessToken("MainPage");
  }

  Future<void> fetchLeaderTeam() async {
    final myTeams = await TeamService.getMyTeams();
    if (myTeams != null && myTeams.isNotEmpty) {
      setState(() {
        leaderTeam = List<Map<String, dynamic>>.from(myTeams);
      });
    } else {
      print("리더인 팀이 존재하지 않습니다");
    }
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
          profileImageUrl =
          (profile != null && profile.toString().isNotEmpty)
              ? (profile.toString().startsWith("http")
              ? profile.toString()
              : "${ApiConstants.imageBaseUrl}$profile") +
              "?v=$timestamp"
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
    final List<Widget> _pages = [
      Homepage(),
      Matchpage(leaderTeam: leaderTeam),
      ChatPage(),
      Board(),
      TeamSearchPage(),
      MyPageScreen(),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar:
        _selectedIndex == 2
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
            // 🚀 쇼츠 페이지 이동 버튼 (새로 추가됨)
            IconButton(
              onPressed: () {
                // main.dart에 등록된 '/shorts' 라우트로 이동
                Navigator.pushNamed(context, '/shorts');
              },
              // 쇼츠/릴스 스타일의 아이콘 사용
              icon: const Icon(Icons.play_circle_outline, size: 28),
            ),
            // ------------------------------------

            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none),
            ),
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
                        leading:
                        profileImageUrl.isNotEmpty
                            ? CircleAvatar(
                          backgroundImage: NetworkImage(
                            profileImageUrl,
                          ),
                          key: ValueKey(
                            profileImageUrl,
                          ), // 강제 리렌더링
                        )
                            : CircleAvatar(
                          backgroundColor: Colors.grey,
                          child: Icon(
                            Icons.person,
                            color: Colors.black,
                          ),
                        ),
                        title: Text(userName),
                      ),
                    ),
                    PopupMenuItem<int>(value: 5, child: Text('설정')),
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