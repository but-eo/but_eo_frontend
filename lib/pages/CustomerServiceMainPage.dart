import 'package:flutter/material.dart';
import 'package:project/pages/InquiryFormPage.dart';
import 'package:project/pages/asked_questions.dart';
import 'package:project/pages/NoticePage.dart';
import 'package:project/pages/InquiryFormPage.dart';

import 'InquiryMainPage.dart';

class CustomerServiceMainPage extends StatelessWidget {
  const CustomerServiceMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('고객센터', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: 홈으로 이동 등 기능 추가 가능
            },
            icon: const Icon(Icons.home_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 안내
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '무엇이 궁금하세요?',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '고객센터에서 알려드릴게요.',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.headset_mic, color: Colors.blueAccent, size: 40),
              ],
            ),
            const SizedBox(height: 20),

            // 문의 버튼 3종
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInquiryButton(context, '챗봇상담 문의', isSelected: true),
                _buildInquiryButton(context, '전화문의'),
                _buildInquiryButton(context, '1:1 문의', page: const InquiryMainPage()),

              ],
            ),

            const SizedBox(height: 30),
            Divider(height: 1, color: Colors.grey.shade300),
            const SizedBox(height: 20),

            // 자주 묻는 질문
            const Text('자주 묻는 질문',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                hintText: '궁금한 점을 검색해보세요',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.blue.shade50,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: ['매칭안됨', '결제오류', '프로필변경', '매너신고', '앱 종료']
                  .map((tag) => Chip(label: Text(tag)))
                  .toList(),
            ),

            const SizedBox(height: 30),
            Divider(height: 1, color: Colors.grey.shade300),
            const SizedBox(height: 20),

            // 공지사항 + 기타 메뉴
            ListTile(
              leading: const Icon(Icons.volume_up_outlined, color: Colors.black87),
              title: const Text('공지사항'),
              subtitle: const Text('[긴급] 서비스 업데이트 안내'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NoticePage()),
              ),
            ),

            _buildExtraMenu(Icons.location_on_outlined, '매장찾기'),
            _buildExtraMenu(Icons.article_outlined, '이용약관'),
            _buildExtraMenu(Icons.bookmark_outline, '근무자 가이드'),
          ],
        ),
      ),
    );
  }

  Widget _buildInquiryButton(BuildContext context, String label,
      {bool isSelected = false, Widget? page}) {
    return Expanded(
      child: GestureDetector(
        onTap: page != null
            ? () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        )
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.black87 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(label,
              style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black54,
                  fontSize: 14)),
        ),
      ),
    );
  }

  Widget _buildExtraMenu(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // TODO: 각 기능 연결 시 여기에 네비게이션 추가
      },
    );
  }
}
