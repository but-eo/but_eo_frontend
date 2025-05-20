import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:project/contants/api_contants.dart';
import 'package:project/pages/myteam.dart';
import 'package:project/utils/token_storage.dart';
import 'package:project/pages/EditProfilePage.dart';
import 'package:project/pages/asked_questions.dart';

import 'Customer_Service.dart';
import 'NoticePage.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  String? nickname = "로딩 중...";
  String? _profileImageUrl;
  final String baseUrl = "http://${ApiConstants.serverUrl}:714";

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future fetchUserInfo() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) {
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
        setState(() {
          nickname = res.data['name'] ?? "닉네임 없음";
          _profileImageUrl = res.data['profile'];
        });
      } else {
        print("❌ 사용자 정보 불러오기 실패: ${res.statusCode}");
      }
    } catch (e) {
      print("❗ 사용자 정보 요청 중 오류: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색을 흰색으로 설정
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        children: [
          Center(
            child: ClipOval(
              child: Container(
                width: 120,
                height: 120,
                color: Colors.grey.shade300,
                child: _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                    ? Image.network(
                  _profileImageUrl!.startsWith("http")
                      ? _profileImageUrl!
                      : "$baseUrl${_profileImageUrl!}",
                  fit: BoxFit.cover,
                )
                    : const Icon(Icons.person, size: 60, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              nickname ?? '',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 30),
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 1,
            child: Column(
              children: [
                _buildListTile(Icons.edit, '회원정보 수정', context, onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfilePage(
                        initialProfileImageUrl: _profileImageUrl,
                      ),
                    ),
                  );
                  if (result == true) {
                    fetchUserInfo();
                  }
                }),
                _buildListTile(Icons.group_outlined, '마이 팀', context, onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyTeamPage()),
                  );
                }),
                _buildListTile(Icons.grid_on, '내가 작성한 글 보기', context),
                _buildListTile(Icons.mode_comment_outlined, '내가 남긴 댓글 보기', context),
                _buildListTile(Icons.question_answer_outlined, '자주 묻는 질문', context, onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const asked_questions()),
                  );
                }),
                _buildListTile(Icons.my_library_books_rounded, '공지사항', context, onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NoticePage()),
                  );
                }),
                _buildListTile(Icons.support_agent, '고객센터', context, onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CustomerServicePage()),
                  );
                }),
                _buildListTile(Icons.settings_outlined, '앱 설정', context, hasDivider: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
      IconData icon,
      String title,
      BuildContext context, {
        VoidCallback? onTap,
        bool hasDivider = true,
      }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.black54),
          title: Text(title, style: const TextStyle(fontSize: 16, color: Colors.black87)),
          trailing: const Icon(Icons.chevron_right, color: Colors.black54),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          onTap: onTap,
        ),
        if (hasDivider)
          const Divider(indent: 20, endIndent: 20, height: 1, color: Colors.grey),
      ],
    );
  }
}
