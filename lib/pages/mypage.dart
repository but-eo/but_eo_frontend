import 'package:flutter/material.dart';
import 'package:project/pages/EditProfilePage.dart'; // 수정 페이지 import

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 20),
        Center(
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.purpleAccent.withOpacity(0.2),
            child: const Icon(Icons.person, size: 50, color: Colors.white),
          ),
        ),
        const SizedBox(height: 10),
        const Center(
          child: Text(
            'IM_HERO',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Divider(height: 1),

        // ✅ 회원정보 수정 → EditProfilePage로 이동
        _buildListTile(
          context,
          '회원정보 수정',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EditProfilePage()),
            );
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
