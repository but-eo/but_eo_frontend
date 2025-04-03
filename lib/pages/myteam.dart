import 'package:flutter/material.dart';

class MyTeamPage extends StatefulWidget {
  const MyTeamPage({super.key});

  @override
  _MyTeamPageState createState() => _MyTeamPageState();
}

class _MyTeamPageState extends State<MyTeamPage> {
  int _selectedIndex = 4;
  int _tabIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onTabSelected(int index) {
    setState(() {
      _tabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Team Page",
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          _tabBar(),
          Expanded(
            child: IndexedStack(
              index: _tabIndex,
              children: [
                _teamProfile(),
                _myReviews(),
                _teamInfo(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // 아이템이 많아도 잘리지 않도록 설정
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.sports_soccer), label: '매칭찾기'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: '채팅방'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: '전적보기'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _tabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _tabButton("MY PAGE", 0),
          _tabButton("내가 남긴 리뷰", 1),
          _tabButton("MY TEAM", 2),
        ],
      ),
    );
  }

  Widget _tabButton(String title, int index) {
    return TextButton(
      onPressed: () => _onTabSelected(index),
      style: TextButton.styleFrom(
        foregroundColor: _tabIndex == index ? Colors.red : Colors.black,
      ),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _teamProfile() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircleAvatar(radius: 50, backgroundColor: Colors.grey),
          SizedBox(height: 16),
          Text("복현동 농구왕", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text("복현동 Los Angeles Lakers", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _myReviews() {
    final reviews = [
      {"team": "우라이 FC", "date": "2025-03-11", "rating": 4, "content": "우라이 FC와의 경기 너무 좋았습니다."},
      {"team": "삼전 FC", "date": "2025-02-13", "rating": 3, "content": "매너가 조금 부족했어요."},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(review["team"] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(review["date"] as String, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (i) => Icon(
                    Icons.star,
                    color: i < (review["rating"] as int) ? Colors.amber : Colors.grey[300],
                  )),
                ),
                const SizedBox(height: 8),
                Text(review["content"] as String),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _teamInfo() {
    final teams = [
      {"name": "블랙타이거", "sport": "축구", "image": Icons.sports_soccer},
      {"name": "화이트타이거 FC", "sport": "풋살", "image": Icons.sports_football},
      {"name": "살쾡이 탁구단", "sport": "탁구", "image": Icons.sports_tennis_sharp},
      {"name": "냥냥슛 FC", "sport": "농구", "image": Icons.sports_basketball},
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: teams.length,
      itemBuilder: (context, index) {
        final team = teams[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(team["image"] as IconData, size: 48, color: Colors.blueAccent),
              const SizedBox(height: 8),
              Text(team["name"] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(team["sport"] as String, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        );
      },
    );
  }
}
