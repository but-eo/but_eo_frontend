import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/model/board_model.dart'; // Board 모델 import
import 'package:project/pages/team/teamDetailPage.dart';
import 'package:project/pages/team/teamFormPage.dart';
import 'package:project/widgets/loading_placeholder.dart';

import '../service/board_api_get_service.dart' as BoardApiService;
import '../service/matching_api_service.dart';
import '../service/teamService.dart';
import '../widgets/image_slider_widgets.dart';
import 'board/board_detail_page.dart';
import 'mypage/myteam.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  Future<Map<String, dynamic>?>? _upcomingMatchFuture;
  Future<List<dynamic>>? _myTeamsFuture;
  Future<List<Board>>? _latestPostsFuture;

  // ✨ 다른 페이지와 색감 통일을 위한 색상 변수 정의
  final Color _scaffoldBgColor = Colors.grey.shade100;
  final Color _cardBgColor = Colors.white;
  final Color _primaryTextColor = Colors.black87;
  final Color _secondaryTextColor = Colors.grey.shade700;
  final Color _accentColor = Colors.blue.shade700; // ✨ 파란색 계열 강조색 추가

  @override
  void initState() {
    super.initState();
    _loadHomepageData();
  }

  Future<void> _loadHomepageData() async {
    setState(() {
      _upcomingMatchFuture = MatchingApiService.getUpcomingMatch();
      _myTeamsFuture = TeamService.getMyTeams();
      _latestPostsFuture = BoardApiService.fetchBoards('FREE', 'FREE', page: 0, size: 5);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> bannerUrlItems = [
      "assets/images/banner1.png",
      "assets/images/banner2.png",
    ];

    return Scaffold(
      backgroundColor: _scaffoldBgColor,
      body: RefreshIndicator(
        onRefresh: _loadHomepageData,
        color: _accentColor, // ✨ 강조색으로 변경
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImageSliderWidgets(bannerUrlItems: bannerUrlItems),
              const SizedBox(height: 16),

              // "나의 팀" 섹션
              _buildSectionHeader(context, title: "나의 팀", icon: Icons.group_work_outlined, onMoreTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MyTeamPage(initialTabIndex: 2)));
              }),
              const SizedBox(height: 12),
              _buildMyTeamsSection(context),
              const SizedBox(height: 32),

              // "예정된 경기" 섹션
              _buildSectionHeader(context, title: "예정된 경기", icon: Icons.event_available_outlined, onMoreTap: () {
                // TODO: 매칭 페이지로 이동
              }),
              const SizedBox(height: 12),
              _buildUpcomingMatchSection(context),
              const SizedBox(height: 32),

              // "최신글" 섹션
              _buildSectionHeader(context, title: "최신글", icon: Icons.article_outlined, onMoreTap: () {
                // TODO: 게시판 페이지로 이동
              }),
              const SizedBox(height: 12),
              _buildLatestPostsSection(context),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, {required String title, required IconData icon, VoidCallback? onMoreTap}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: _accentColor, size: 22), // ✨ 강조색으로 변경
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 19, color: _primaryTextColor),
              ),
            ],
          ),
          if (onMoreTap != null)
            InkWell(
              onTap: onMoreTap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Row(
                  children: [
                    Text("더보기", style: TextStyle(color: _secondaryTextColor, fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(width: 2),
                    Icon(Icons.arrow_forward_ios, size: 12, color: _secondaryTextColor),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMyTeamsSection(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _myTeamsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildMyTeamsLoadingIndicator();
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildEmptyStateCard(
              title: "소속된 팀이 없어요!",
              subtitle: "팀을 만들거나 가입하여 활동을 시작해보세요.",
              buttonText: "팀 생성/가입하기",
              icon: Icons.group_add_outlined,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const TeamFormPage()));
              },
            ),
          );
        }
        final myTeams = snapshot.data!;
        return SizedBox(
          height: 170,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            clipBehavior: Clip.none,
            itemCount: myTeams.length,
            itemBuilder: (context, index) {
              final team = myTeams[index];
              return _buildMyTeamCard(context, team);
            },
            separatorBuilder: (context, index) => const SizedBox(width: 12),
          ),
        );
      },
    );
  }

  Widget _buildUpcomingMatchSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: FutureBuilder<Map<String, dynamic>?>(
        future: _upcomingMatchFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildMatchCardLoadingIndicator();
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return _buildEmptyStateCard(
              title: "예정된 경기가 없어요!",
              subtitle: "새로운 경기를 주최하거나 참여해보세요.",
              buttonText: "매칭 둘러보기",
              icon: Icons.calendar_today_outlined,
              onPressed: () { /* TODO: 매칭 페이지로 이동 */ },
            );
          }
          final match = snapshot.data!;
          return _buildMatchCard(context, match);
        },
      ),
    );
  }

  Widget _buildLatestPostsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: FutureBuilder<List<Board>>(
        future: _latestPostsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildPostsLoadingIndicator();
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                color: _cardBgColor,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Center(child: Text("아직 게시글이 없어요.", style: TextStyle(color: _secondaryTextColor))),
            );
          }
          final posts = snapshot.data!;
          return Container(
            decoration: BoxDecoration(
                color: _cardBgColor,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))
                ]
            ),
            child: Column(
              children: List.generate(posts.length, (index) {
                return _buildPostItem(context, posts[index], index == posts.length - 1);
              }),
            ),
          );
        },
      ),
    );
  }

  // --- 상세 위젯 빌더들 (디자인 통일) ---

  Widget _buildMyTeamCard(BuildContext context, Map<String, dynamic> team) {
    final String teamName = team['teamName'] ?? '이름 없음';
    final String? teamImagePath = team['teamImg'];
    final String? teamImageUrl = (teamImagePath != null && teamImagePath.isNotEmpty)
        ? TeamService.getFullTeamImageUrl(teamImagePath) : null;

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => TeamDetailPage(team: team)));
      },
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: _cardBgColor,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 38,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: teamImageUrl != null ? NetworkImage("$teamImageUrl?v=${DateTime.now().millisecondsSinceEpoch}") : null,
              child: teamImageUrl == null ? Icon(Icons.shield_outlined, size: 35, color: _secondaryTextColor) : null,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                teamName,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _primaryTextColor),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${TeamService.getEventLabel(team['event']) ?? '미지정'}",
              style: TextStyle(fontSize: 13, color: _secondaryTextColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchCard(BuildContext context, Map<String, dynamic> match) {
    final theme = Theme.of(context);
    final String teamName = match['teamName'] ?? '팀 이름 없음';
    final String stadiumName = match['stadiumName'] ?? '장소 미정';
    final String matchDateStr = match['matchDate'] ?? '';
    String formattedDate = '날짜 미정';
    if (matchDateStr.isNotEmpty) {
      try {
        final matchDate = DateTime.parse(matchDateStr);
        formattedDate = DateFormat('M월 d일 (E) HH:mm', 'ko_KR').format(matchDate);
      } catch(e) { /* 날짜 파싱 실패 */ }
    }

    return Container(
      decoration: BoxDecoration(
        color: _cardBgColor,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () { /* TODO: 매칭 상세 정보 페이지로 이동 */ },
          borderRadius: BorderRadius.circular(12.0),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      teamName,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: _primaryTextColor),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400)
                  ],
                ),
                const SizedBox(height: 16),
                _buildMatchInfoRow(icon: Icons.calendar_today_outlined, text: formattedDate),
                const SizedBox(height: 10),
                _buildMatchInfoRow(icon: Icons.location_on_outlined, text: stadiumName),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMatchInfoRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _secondaryTextColor),
        const SizedBox(width: 12),
        Expanded(
            child: Text(text, style: TextStyle(fontSize: 14.5, color: _primaryTextColor), overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _buildPostItem(BuildContext context, Board post, bool isLast) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => BoardDetailPage(boardId: post.boardId)));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  post.title,
                  style: TextStyle(fontSize: 15, color: _primaryTextColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  Icon(Icons.thumb_up_alt_outlined, size: 14, color: _secondaryTextColor),
                  const SizedBox(width: 4),
                  Text("${post.likeCount}", style: TextStyle(fontSize: 13, color: _secondaryTextColor)),
                  const SizedBox(width: 12),
                  Icon(Icons.chat_bubble_outline, size: 14, color: _secondaryTextColor),
                  const SizedBox(width: 4),
                  Text("${post.commentCount}", style: TextStyle(fontSize: 13, color: _secondaryTextColor)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyStateCard({
    required String title,
    required String subtitle,
    required String buttonText,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
          color: _cardBgColor,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))
          ]
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: _accentColor.withOpacity(0.1), // ✨ 강조색으로 변경
            child: Icon(icon, size: 30, color: _accentColor), // ✨ 강조색으로 변경
          ),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: _primaryTextColor)),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: _secondaryTextColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.add, size: 20),
            label: Text(buttonText),
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentColor, // ✨ 강조색으로 변경
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  // --- 로딩 인디케이터 위젯들 (디자인 통일) ---

  Widget _buildMyTeamsLoadingIndicator() {
    return SizedBox(
      height: 170,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: 3,
        itemBuilder: (context, index) => LoadingPlaceholder(
          width: 150,
          height: 170,
          borderRadius: 12.0,
        ),
        separatorBuilder: (context, index) => const SizedBox(width: 12),
      ),
    );
  }

  Widget _buildMatchCardLoadingIndicator() {
    return const LoadingPlaceholder(
      height: 140,
      borderRadius: 12.0,
    );
  }

  Widget _buildPostsLoadingIndicator() {
    return Container(
      decoration: BoxDecoration(
        color: _cardBgColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: List.generate(5, (index)
        => LoadingPlaceholder(
          height: 55,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          borderRadius: 8.0,
        ),
        ),
      ),
    );
  }
}