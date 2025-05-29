import 'package:flutter/material.dart';
import 'package:project/data/mock_posts.dart'; // mockPosts가 정의된 파일
import 'package:project/pages/board/board_detail_page.dart'; // 사용하지 않는 임포트 제거 고려
import 'package:project/pages/board/board_page.dart'; // 사용하지 않는 임포트 제거 고려
import 'package:project/widgets/image_slider_widgets.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  // 예정 경기 카드 위젯
  Widget _buildTestMatchCard(BuildContext context) {
    // context 인자 추가
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), 
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'vs 맨체스터 유나이티드',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 5.0),
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                    15.0,
                  ), 
                  child: Image.asset(
                    'assets/images/default_team.png',
                    width: 30,
                    height: 30,
                    fit: BoxFit.cover, //지정된 크기에 이미지 맞추는법
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Row(
              children: [
                Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  '2025년 7월 1일 18:00',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 5),
            const Row(
              children: [
                Icon(Icons.location_on, size: 18, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  '테스트 경기장',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: () {
                  //TODO: 예정 경기 상세 정보 페이지로 이동
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('경기 정보 상세 보기')));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text('상세 보기'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 팀 카드 위젯
  Widget _buildTemporaryTeamCard(BuildContext context, String teamName, String logoAssetPath) {
    return GestureDetector( // GestureDetector -> 탭 이벤트
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => TeamDetailPage(
        //     ),
        //   ),
        // );
      },
      child: Container(
        width: 150, // 카드의 고정 너비 (가로 스크롤이므로 필요)
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Card(
          elevation: 3.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(30.0), // 로고 크기의 절반으로 설정
                  child: Image.asset(
                    logoAssetPath, // 전달받은 로고 경로 사용
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.group, size: 60, color: Colors.grey);
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  teamName, 
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                const Text(
                  //TODO: 팀 설명 데이터 불러오기
                  '임시 팀 설명',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //공지사항 위젯
  Widget _noticeItem(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(12),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(title, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> bannerUrlItems = [
      "assets/images/banner1.png",
      "assets/images/banner2.png",
    ];

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 배너 슬라이더
            SizedBox(
              height: 150,
              width: double.infinity,
              child: ImageSliderWidgets(bannerUrlItems: bannerUrlItems),
            ),
            const SizedBox(height: 10.0),
            const Padding(
              // Text 위젯에 패딩 추가
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '예정된 경기',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 5.0),
            // _buildTestMatchCard 호출 시 context 전달
            _buildTestMatchCard(context),

            const SizedBox(height: 20.0), 
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '나의 팀', // 새로운 섹션 제목
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10.0),
            // 내 팀 슬라이드 
            SizedBox(
              height: 200, 
              child: ListView(
                // ListView.builder 대신 ListView를 사용하여 직접 위젯 나열
                scrollDirection: Axis.horizontal, // 가로 스크롤 설정
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                ), // 전체 ListView의 좌우 패딩
                children: [
                  _buildTemporaryTeamCard(
                    context,
                    'My Team A',
                    'assets/images/default_team.png',
                  ),
                  _buildTemporaryTeamCard(
                    context,
                    'My Team B',
                    'assets/images/default_team.png',
                  ),
                  _buildTemporaryTeamCard(
                    context,
                    'My Team C',
                    'assets/images/default_team.png',
                  ),
                  _buildTemporaryTeamCard(
                    context,
                    'My Team D',
                    'assets/images/default_team.png',
                  ),
                  _buildTemporaryTeamCard(
                    context,
                    'My Team E',
                    'assets/images/default_team.png',
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
