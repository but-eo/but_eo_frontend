import 'package:flutter/material.dart';
import 'package:project/pages/mypage/asked_questions.dart';
import 'package:url_launcher/url_launcher.dart';

import 'InquiryMainPage.dart';
import 'NoticePage.dart';

class CustomerServiceMainPage extends StatelessWidget {
  const CustomerServiceMainPage({super.key});

  // 색상 변수를 build 메소드 내에서 정의합니다.
  // final Color _scaffoldBgColor = Colors.grey.shade200; // 삭제
  // final Color _cardBgColor = Colors.white; // 삭제
  // final Color _appBarBgColor = Colors.white; // 삭제
  // final Color _primaryTextColor = Colors.black87; // 삭제
  // final Color _secondaryTextColor = Colors.grey.shade700; // 삭제
  // final Color _accentColor = Colors.blue.shade700; // 삭제

  @override
  Widget build(BuildContext context) {
    // 색상 정의를 build 메소드 내부로 이동
    final Color scaffoldBgColor = Colors.grey.shade200;
    final Color cardBgColor = Colors.white;
    final Color appBarBgColor = Colors.white;
    final Color primaryTextColor = Colors.black87;
    final Color secondaryTextColor = Colors.grey.shade700;
    final Color accentColor = Colors.blue.shade700;

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        title: Text(
          '고객센터',
          style: TextStyle(
            color: primaryTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: appBarBgColor,
        elevation: 0.5,
        iconTheme: IconThemeData(color: primaryTextColor),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildHeaderSection(
            context,
            primaryTextColor,
            secondaryTextColor,
            cardBgColor,
            accentColor,
          ),
          const SizedBox(height: 20),
          _buildInquiryButtonsSection(
            context,
            primaryTextColor,
            secondaryTextColor,
            cardBgColor,
            accentColor,
          ),
          const SizedBox(height: 20),
          _buildFAQSearchSection(
            context,
            primaryTextColor,
            secondaryTextColor,
            cardBgColor,
            scaffoldBgColor,
            accentColor,
          ),
          const SizedBox(height: 20),
          _buildMenuListSection(
            context,
            primaryTextColor,
            secondaryTextColor,
            cardBgColor,
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(
    BuildContext context,
    Color primaryTextColor,
    Color secondaryTextColor,
    Color cardBgColor,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0.5,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '무엇을 도와드릴까요?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '궁금한 점이나 불편한 점을 해결해 보세요.',
                  style: TextStyle(fontSize: 15, color: secondaryTextColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Icon(Icons.support_agent_rounded, color: accentColor, size: 48),
        ],
      ),
    );
  }

  Widget _buildInquiryButtonsSection(
    BuildContext context,
    Color primaryTextColor,
    Color secondaryTextColor,
    Color cardBgColor,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0.5,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12.0, top: 8.0, bottom: 8.0),
            child: Text(
              "문의하기",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: secondaryTextColor,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInquiryButton(
                context,
                Icons.chat_bubble_outline,
                '챗봇 상담',
                primaryTextColor,
                secondaryTextColor,
                accentColor,
                isSelected: false,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('챗봇 상담 기능은 준비 중입니다.')),
                  );
                },
              ),
              _buildInquiryButton(context, Icons.phone_outlined, '전화 문의', primaryTextColor, secondaryTextColor, accentColor, onTap: () {
                final String phoneNumber = '01027460094'; 
                final Uri launchUri = Uri(
                  scheme: 'tel',
                  path: phoneNumber,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('전화 문의: $phoneNumber'), // 스낵바 내용에 전화번호 표시
                    backgroundColor: Colors.blueGrey, // 스낵바 색상 (선택 사항)
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    margin: EdgeInsets.only(bottom: 30, left: 16, right: 16),
                    duration: Duration(seconds: 5),
                    action: SnackBarAction( 
                      label: '통화 걸기', 
                      textColor: Colors.white, 
                      onPressed: () async {
                        if (await canLaunchUrl(launchUri)) {
                          await launchUrl(launchUri);
                        } else {
                          // 전화 앱을 열 수 없을 때 (예: 에뮬레이터, 웹 환경 등)
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('전화 앱을 열 수 없습니다.')),
                          );
                        }
                      },
                    ),
                  ),
                );
              }),
              _buildInquiryButton(
                context,
                Icons.edit_note_outlined,
                '1:1 문의',
                primaryTextColor,
                secondaryTextColor,
                accentColor,
                page: const InquiryMainPage(),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildInquiryButton(
    BuildContext context,
    IconData icon,
    String label,
    Color primaryTextColor,
    Color secondaryTextColor,
    Color accentColor, {
    bool isSelected = false,
    Widget? page,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap:
            page != null
                ? () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => page),
                )
                : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color:
                isSelected ? accentColor.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? accentColor : Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? accentColor : secondaryTextColor,
                size: 26,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? accentColor : primaryTextColor,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQSearchSection(
    BuildContext context,
    Color primaryTextColor,
    Color secondaryTextColor,
    Color cardBgColor,
    Color scaffoldBgColor,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0.5,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '자주 묻는 질문',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: secondaryTextColor,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.search,
                color: accentColor.withOpacity(0.7),
              ),
              hintText: '궁금한 점을 검색해보세요',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              filled: true,
              fillColor: scaffoldBgColor,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14.0,
                horizontal: 16.0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  color: accentColor.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AskedQuestions()),
              );
            },
            readOnly: true,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children:
                ['매칭', '결제', '프로필', '신고', '계정']
                    .map(
                      (tag) => ActionChip(
                        label: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 13,
                            color: primaryTextColor,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AskedQuestions(),
                            ),
                          );
                        },
                        backgroundColor: Colors.grey.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          side: BorderSide(
                            color: Colors.grey.shade300,
                            width: 0.5,
                          ),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuListSection(
    BuildContext context,
    Color primaryTextColor,
    Color secondaryTextColor,
    Color cardBgColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0.5,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildListTile(
            context,
            Icons.campaign_outlined,
            '공지사항',
            primaryTextColor,
            secondaryTextColor,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NoticePage()),
              );
            },
          ),
          _buildListTile(
            context,
            Icons.article_outlined,
            '이용약관',
            primaryTextColor,
            secondaryTextColor,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('이용약관 페이지는 준비 중입니다.')),
              );
            },
          ),
          _buildListTile(
            context,
            Icons.shield_outlined,
            '개인정보 처리방침',
            primaryTextColor,
            secondaryTextColor,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('개인정보 처리방침 페이지는 준비 중입니다.')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context,
    IconData icon,
    String title,
    Color primaryTextColor,
    Color secondaryTextColor, {
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: secondaryTextColor, size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 16, color: primaryTextColor),
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
