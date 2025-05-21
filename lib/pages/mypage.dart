import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:project/contants/api_contants.dart';
import 'package:project/pages/myteam.dart';
import 'package:project/utils/token_storage.dart';
import 'package:project/pages/EditProfilePage.dart';
import 'package:project/pages/asked_questions.dart';

import 'CustomerServiceMainPage.dart';
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
  final String defaultProfilePath = "/uploads/profiles/default_profile.png";

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
        final data = res.data;
        print("👤 사용자 정보 응답: $data");

        final profile = data['profile'];
        final timestamp = DateTime.now().millisecondsSinceEpoch;

        setState(() {
          nickname = data['name'] ?? "닉네임 없음";
          _profileImageUrl = (profile == null || (profile is String && profile.trim().isEmpty))
              ? "$baseUrl$defaultProfilePath?v=$timestamp"
              : (profile.startsWith("http") ? profile : "$baseUrl$profile") + "?v=$timestamp";
        });
      } else {
        print("❌ 사용자 정보 가져오기 실패: ${res.statusCode}");
      }
    } catch (e) {
      print("❗ 사용자 정보 요청 중 오류: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        children: [
          Center(
            child: ClipOval(
              child: Container(
                width: 120,
                height: 120,
                color: Colors.grey.shade300,
                child: _profileImageUrl != null
                    ? Image.network(
                  _profileImageUrl!,
                  key: ValueKey(_profileImageUrl), // ✅ 이미지 변경 시 강제 리빌드
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.network(
                      "$baseUrl$defaultProfilePath",
                      fit: BoxFit.cover,
                    );
                  },
                )
                    : Image.network(
                  "$baseUrl$defaultProfilePath",
                  fit: BoxFit.cover,
                ),
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
                    fetchUserInfo(); // ✅ 수정 후 재호출
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
                    MaterialPageRoute(builder: (context) => const AskedQuestions()),
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
                    MaterialPageRoute(builder: (_) => const CustomerServiceMainPage()),
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
