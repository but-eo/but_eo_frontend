import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project/appColors/app_colors.dart';
import 'package:project/pages/login/login.dart';
import 'package:project/pages/mypage.dart';
import 'package:project/widgets/bottom_navigation.dart';

class Home extends StatefulWidget {
  static String id = "/home";

  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(), // 첫 번째 페이지
    MatchPage(), // 두 번째 페이지
    ChatPage(), // 세 번째 페이지
    RecordPage(), // 네 번째 페이지
    ProfilePage(), // 다섯 번째 페이지
  ];

  @override
  Widget build(BuildContext context) {
    List<String> menuItems = [
      "축구",
      "풋살",
      "야구",
      "농구",
      "탁구",
      "배드민턴",
      "테니스",
      "볼링",
    ];
    return MaterialApp(
      home: DefaultTabController(
        length: menuItems.length,
        child: Scaffold(
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
                    ), // 메뉴의 위치 설정
                    items: [
                      PopupMenuItem(
                        value: 1, // 메뉴 항목의 값
                        child: Text('옵션 1'),
                      ),
                      PopupMenuItem(
                        value: 2, // 메뉴 항목의 값
                        child: Text('옵션 2'),
                      ),
                      PopupMenuItem(
                        onTap: (){
                          // logout();
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            //특정화면으로 이동하면서 이전 모든 화면을 스택에서 제거 (새 화면을 띄우고 뒤로가기 버튼을 눌러도 이전 화면으로 돌아갈 수 없음)
                            Login.id, //이동할 경로의 이름
                            (route) => false, //스택의 모든 화면 제거
                          );
                        },
                        value: 3, // 메뉴 항목의 값
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
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(50), // 탭바 높이 조절
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: TabBar(
                  tabAlignment: TabAlignment.center,
                  isScrollable: true, // 탭이 스크롤 가능하도록 설정
                  tabs: menuItems.map((item) => Tab(text: item)).toList(),
                  indicator: BoxDecoration(
                    color: Colors.black, // 선택된 탭 배경색
                    borderRadius: BorderRadius.circular(20), // 둥근 모양
                  ),
                  indicatorSize: TabBarIndicatorSize.tab, // 가로 길게 확장
                  labelPadding: EdgeInsets.symmetric(
                    horizontal: 24,
                  ), // 각 탭 간 가로 간격 조절
                  labelColor: Colors.white, // 선택된 탭 글씨 색상
                  unselectedLabelColor: Colors.black, // 선택되지 않은 탭 글씨 색상
                ),
              ),
            ),
          ),
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  pinned: true, // 상단 탭 고정
                ),
              ];
            },
            body: _pages[_selectedIndex],
          ),

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
      ),
    );
  }
}

// 홈 페이지
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('홈 페이지'));
  }
}

// 매칭 찾기 페이지
class MatchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('매칭 찾기 페이지'));
  }
}

// 채팅방 페이지
class ChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('채팅방 페이지'));
  }
}

// 전적 보기 페이지
class RecordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('전적 보기 페이지'));
  }
}

// 마이페이지
class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('마이페이지'));
  }
}
