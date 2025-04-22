import 'package:flutter/material.dart';
import 'package:project/contants/api_contants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:project/pages/EditProfilePage.dart'; // 수정 페이지 import

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  String? nickname = "로딩 중...";
  String? _profileImageUrl;

  // ✅ baseUrl: 시뮬레이터에서 서버 접근할 때 사용
  final String baseUrl = "http://192.168.0.72:714";

  // @override
  // void initState() {
  //   super.initState();
  //   fetchUserInfo();
  // }
  @override
  void initState() {
    super.initState();
    printAccessToken("MyPage");
    fetchUserInfo();
  }

  Future<void> printAccessToken(String label) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    print("🔑 [$label] accessToken: $token");
  }

  Future<void> printUserInfo(String label) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) {
      print("❌ [$label] 토큰 없음");
      return;
    }

    final dio = Dio();
    try {
      final res = await dio.get(
        "${ApiConstants.baseUrl}/users/me",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (res.statusCode == 200) {
        print("👤 [$label] 로그인된 사용자 정보: ${res.data}");
      } else {
        print("❌ [$label] 유저 정보 불러오기 실패: ${res.statusCode}");
      }
    } catch (e) {
      print("❗ [$label] 사용자 정보 요청 에러: $e");
    }
  }



  Future<void> fetchUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

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
        print("🟢 유저 정보: ${res.data}");
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
    return ListView(
      children: [
        const SizedBox(height: 20),
        Center(
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.purpleAccent.withOpacity(0.2),
            backgroundImage: _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                ? NetworkImage(
              _profileImageUrl!.startsWith("http")
                  ? _profileImageUrl!
                  : "$baseUrl${_profileImageUrl!}",
            )
                : null,
            child: _profileImageUrl == null || _profileImageUrl!.isEmpty
                ? const Icon(Icons.person, size: 50, color: Colors.white)
                : null,
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            nickname ?? '',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Divider(height: 1),

        _buildListTile(
          context,
          '회원정보 수정',
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EditProfilePage()),
            );
            if (result == true) {
              fetchUserInfo(); // ✅ 수정되었을 때만 다시 불러오기
            }
          },

        ),
        _buildListTile(context, '마이 팀'),
        _buildListTile(context, '내가 작성한 글 보기'),
        _buildListTile(context, '내가 남긴 댓글 보기'),
        _buildListTile(context, '고객센터'),
        _buildListTile(context, '내 정보 수정하기'),
      ],
    );
  }

  Widget _buildListTile(BuildContext context, String title, {VoidCallback? onTap}) {
    return Column(
      children: [
        ListTile(
          title: Text(title),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }
}