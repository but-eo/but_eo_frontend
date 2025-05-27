import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
// 실제 프로젝트 경로에 맞게 아래 import 경로를 수정해주세요.
import 'package:project/contants/api_contants.dart';
import 'package:project/pages/myteam.dart';
import 'package:project/utils/token_storage.dart';
import 'package:project/pages/EditProfilePage.dart';
import 'package:project/pages/asked_questions.dart';
import 'package:project/pages/CustomerServiceMainPage.dart';
import 'package:project/pages/NoticePage.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  String? nickname = "로딩 중...";
  String? _profileImageUrl;
  final String baseUrl = "http://${ApiConstants.serverUrl}:714";
  final String defaultProfilePath = "/uploads/profiles/default_profile.png";

  // 새로운 색상 정의
  final Color _scaffoldBgColor = Colors.grey.shade200;
  final Color _cardBgColor = Colors.white;
  final Color _appBarBgColor = Colors.white;
  final Color _primaryTextColor = Colors.black87;
  final Color _secondaryTextColor = Colors.grey.shade700;
  final Color _accentColor = Colors.blue.shade700;
  final Color _iconColor = Colors.black54;


  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) {
      if (mounted) {
        setState(() {
          nickname = "로그인 필요";
          _profileImageUrl = null;
        });
      }
      print("❌ 토큰 없음");
      return;
    }

    final dio = Dio();
    try {
      final res = await dio.get(
        "$baseUrl/api/users/me",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (res.statusCode == 200) {
        final data = res.data;
        print("👤 사용자 정보 응답 (마이페이지): $data");

        final profilePathFromServer = data['profile'];
        final timestamp = DateTime.now().millisecondsSinceEpoch;

        if (mounted) {
          setState(() {
            nickname = data['name'] ?? "닉네임 없음";
            if (profilePathFromServer != null && profilePathFromServer is String && profilePathFromServer.isNotEmpty) {
              if (profilePathFromServer.startsWith("http")) {
                _profileImageUrl = "$profilePathFromServer?v=$timestamp";
              } else {
                _profileImageUrl = "$baseUrl$profilePathFromServer?v=$timestamp";
              }
            } else {
              _profileImageUrl = "$baseUrl$defaultProfilePath?v=$timestamp";
            }
          });
        }
      } else {
        print("❌ 사용자 정보 가져오기 실패 (마이페이지): ${res.statusCode}");
        if (mounted) {
          setState(() {
            nickname = "정보 로드 실패";
          });
        }
      }
    } catch (e) {
      print("❗ 사용자 정보 요청 중 오류 (마이페이지): $e");
      if (mounted) {
        setState(() {
          nickname = "오류 발생";
        });
      }
      if (e is DioException && e.response != null) {
        print("❗ 서버 응답 데이터 (마이페이지 fetch): ${e.response!.data}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffoldBgColor, // 전체 배경색 변경
      appBar: AppBar(
        title: Text(
          '마이페이지',
          style: TextStyle(color: _primaryTextColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: _appBarBgColor,
        elevation: 0.5,
        centerTitle: false,
        iconTheme: IconThemeData(color: _primaryTextColor), // AppBar 아이콘 색상 통일
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildProfileSection(context),
          const SizedBox(height: 20),
          _buildSectionCard(
            context,
            title: '내 활동',
            children: [
              _buildListTile(Icons.group_outlined, '마이 팀', context, onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyTeamPage()),
                );
              }),
              _buildListTile(Icons.article_outlined, '내가 작성한 글 보기', context, onTap: () {
                print('내가 작성한 글 보기 클릭');
              }),
              _buildListTile(Icons.mode_comment_outlined, '내가 남긴 댓글 보기', context, onTap: () {
                print('내가 남긴 댓글 보기 클릭');
              }),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionCard(
            context,
            title: '지원',
            children: [
              _buildListTile(Icons.quiz_outlined, '자주 묻는 질문', context, onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AskedQuestions()),
                );
              }),
              _buildListTile(Icons.campaign_outlined, '공지사항', context, onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NoticePage()),
                );
              }),
              _buildListTile(Icons.support_agent_outlined, '고객센터', context, onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CustomerServiceMainPage()),
                );
              }),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionCard(
            context,
            title: '계정 및 앱 설정',
            children: [
              _buildListTile(Icons.settings_outlined, '앱 설정', context, onTap: () {
                print('앱 설정 클릭');
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: _cardBgColor,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // 그림자 색 연하게
            spreadRadius: 1,
            blurRadius: 8, // 블러 반경 증가
            offset: const Offset(0, 3), // 그림자 위치 미세 조정
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: _profileImageUrl != null && Uri.tryParse(_profileImageUrl!)?.isAbsolute == true
                ? NetworkImage(_profileImageUrl!)
                : null,
            child: (_profileImageUrl == null || Uri.tryParse(_profileImageUrl!)?.isAbsolute != true)
                ? Icon(Icons.person, size: 40, color: _secondaryTextColor)
                : null,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nickname ?? '사용자',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _primaryTextColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                // 이메일 등 추가 정보 표시 가능
                // const SizedBox(height: 4),
                // Text(
                //   'email@example.com',
                //   style: TextStyle(fontSize: 14, color: _secondaryTextColor),
                // ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, color: _secondaryTextColor),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(
                    initialProfileImageUrl: _profileImageUrl,
                  ),
                ),
              );
              if (result == true && mounted) {
                fetchUserInfo();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, {required String title, required List<Widget> children}) {
    return Container( // Card 대신 Container와 BoxDecoration 사용으로 커스텀 용이
      decoration: BoxDecoration(
          color: _cardBgColor,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 0.5,
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 8.0),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600, // 약간 더 얇게
                color: _secondaryTextColor,
              ),
            ),
          ),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildListTile(
      IconData icon,
      String title,
      BuildContext context, {
        VoidCallback? onTap,
      }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0), // InkWell 효과 범위 (선택사항)
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), // 패딩 증가
          child: Row(
            children: [
              Icon(icon, color: _iconColor, size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 16, color: _primaryTextColor),
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 22), // 색상 연하게
            ],
          ),
        ),
      ),
    );
  }
}