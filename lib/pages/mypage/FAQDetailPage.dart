import 'package:flutter/material.dart';

class FAQDetailPage extends StatelessWidget {
  final Map<String, String> inquiry;

  const FAQDetailPage({super.key, required this.inquiry});

  @override
  Widget build(BuildContext context) {
    // 색상 정의를 build 메소드 내부로 이동
    final Color scaffoldBgColor = Colors.grey.shade200;
    final Color cardBgColor = Colors.white;
    final Color appBarBgColor = Colors.white;
    final Color primaryTextColor = Colors.black87;
    final Color secondaryTextColor = Colors.grey.shade700;
    final Color accentColor = Colors.blue.shade700; // 질문 아이콘 등에 사용
    final Color answerIconColor = Colors.green.shade600; // 답변 아이콘 색상

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        title: Text('질문 상세', style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold)),
        backgroundColor: appBarBgColor,
        elevation: 0.5,
        iconTheme: IconThemeData(color: primaryTextColor),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionContainer(
              context: context,
              icon: Icons.help_outline,
              iconColor: accentColor,
              titleText: "질문",
              cardBgColor: cardBgColor,
              primaryTextColor: primaryTextColor,
              secondaryTextColor: secondaryTextColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    inquiry['title'] ?? '제목 없음',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    inquiry['content'] ?? '내용 없음',
                    style: TextStyle(
                      fontSize: 15,
                      color: primaryTextColor.withOpacity(0.8),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // *** 여기가 최종 수정된 부분입니다 ***
            _buildSectionContainer(
              context: context,
              icon:Icons.comment_outlined, // 정확한 아이콘으로 수정
              iconColor: answerIconColor,
              titleText: "답변",
              cardBgColor: cardBgColor,
              primaryTextColor: primaryTextColor,
              secondaryTextColor: secondaryTextColor,
              child: Text(
                inquiry['answer'] != null && inquiry['answer']!.isNotEmpty
                    ? inquiry['answer']!
                    : '아직 답변이 등록되지 않았습니다. 조금만 기다려주세요.',
                style: TextStyle(
                  fontSize: 15,
                  color: inquiry['answer'] != null && inquiry['answer']!.isNotEmpty
                      ? primaryTextColor.withOpacity(0.8)
                      : secondaryTextColor,
                  height: 1.5,
                  fontStyle: inquiry['answer'] != null && inquiry['answer']!.isNotEmpty
                      ? FontStyle.normal
                      : FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildSectionContainer({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String titleText,
    required Widget child,
    required Color cardBgColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
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
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 8),
              Text(
                titleText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: secondaryTextColor,
                ),
              ),
            ],
          ),
          const Divider(height: 20, thickness: 0.5),
          child,
        ],
      ),
    );
  }
}