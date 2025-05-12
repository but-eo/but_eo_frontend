import 'package:flutter/material.dart';
import 'package:project/widgets/bottom_navigation.dart';
import 'package:project/appStyle/app_colors.dart';

class MyTeamPage extends StatefulWidget {
  const MyTeamPage({super.key});

  @override
  _MyTeamPageState createState() => _MyTeamPageState();
}

class _MyTeamPageState extends State<MyTeamPage> {
  int _tabIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _tabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("My Team", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
    );
  }

  Widget _tabBar() {
    return Container(
      color: Colors.white,
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
    final isSelected = _tabIndex == index;
    return GestureDetector(
      onTap: () => _onTabSelected(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red.shade100 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.red : Colors.black87,
          ),
        ),
      ),
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
    final List<Map<String, dynamic>> reviews = [
      {"team": "우라이 FC", "date": "2025-03-11", "rating": 4, "content": "팀워크와 실력이 최고였습니다."},
      {"team": "삼전 FC", "date": "2025-02-13", "rating": 3, "content": "다소 거친 플레이가 있었습니다."},
      {"team": "경희대 OB", "date": "2025-01-05", "rating": 5, "content": "정말 매너 좋은 팀! 꼭 다시 붙고 싶어요."},
      {"team": "서울조기축구단", "date": "2024-12-20", "rating": 2, "content": "연락이 잘 안 됐고 늦게 도착했어요."},
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
                  children: List.generate(
                    5,
                        (i) => Icon(Icons.star,
                        color: i < (review["rating"] as int) ? Colors.amber : Colors.grey[300]),
                  ),
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
    final List<Map<String, dynamic>> teams = [
      {"name": "블랙타이거", "sport": "축구", "image": Icons.sports_soccer},
      {"name": "화이트타이거 FC", "sport": "풋살", "image": Icons.sports_football},
      {"name": "살쾡이 탁구단", "sport": "탁구", "image": Icons.sports_tennis},
      {"name": "냥냥슛 FC", "sport": "농구", "image": Icons.sports_basketball},
      {"name": "창동 유나이티드", "sport": "족구", "image": Icons.sports_volleyball},
      {"name": "런닝맨즈", "sport": "러닝", "image": Icons.directions_run},
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