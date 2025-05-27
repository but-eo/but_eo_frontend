import 'package:flutter/material.dart';
import 'package:project/pages/InquiryMainPage.dart'; // Inquiry 모델 사용을 위해

class InquiryDetailPage extends StatelessWidget {
  final Inquiry inquiry;

  const InquiryDetailPage({super.key, required this.inquiry});

  // 색상 변수를 build 메소드 내에서 정의합니다.
  // final Color _scaffoldBgColor = Colors.grey.shade200; // 삭제
  // final Color _cardBgColor = Colors.white; // 삭제
  // final Color _appBarBgColor = Colors.white; // 삭제
  // final Color _primaryTextColor = Colors.black87; // 삭제
  // final Color _secondaryTextColor = Colors.grey.shade700; // 삭제
  // final Color _accentColor = Colors.blue.shade700; // 삭제
  // final Color _answerIconColor = Colors.green.shade600; // 삭제


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
        title: Text('문의 상세', style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold)),
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
              icon: inquiry.isPrivate ? Icons.lock_person_outlined : Icons.help_outline,
              iconColor: accentColor, // 수정된 accentColor 사용
              titleText: "문의 내용",
              cardBgColor: cardBgColor, // 전달
              primaryTextColor: primaryTextColor, // 전달
              secondaryTextColor: secondaryTextColor, // 전달
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start, // 제목이 길 경우를 대비
                    children: [
                      Expanded(
                        child: Text(
                          inquiry.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: primaryTextColor,
                          ),
                        ),
                      ),
                      Padding( // 날짜가 너무 붙지 않도록 약간의 왼쪽 여백 추가
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          inquiry.date,
                          style: TextStyle(fontSize: 12, color: secondaryTextColor),
                        ),
                      ),
                    ],
                  ),
                  if(inquiry.writerName != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        "작성자: ${inquiry.writerName}",
                        style: TextStyle(fontSize: 13, color: secondaryTextColor),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    inquiry.fullContent ?? inquiry.contentPreview,
                    style: TextStyle(
                      fontSize: 15,
                      color: primaryTextColor.withOpacity(0.85),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionContainer(
              context: context,
              icon: Icons.chat_bubble_outline,
              iconColor: answerIconColor,
              titleText: "답변 내용",
              cardBgColor: cardBgColor, // 전달
              primaryTextColor: primaryTextColor, // 전달
              secondaryTextColor: secondaryTextColor, // 전달
              child: Text(
                inquiry.answer != null && inquiry.answer!.isNotEmpty
                    ? inquiry.answer!
                    : '아직 답변이 등록되지 않았습니다.',
                style: TextStyle(
                  fontSize: 15,
                  color: inquiry.answer != null && inquiry.answer!.isNotEmpty
                      ? primaryTextColor.withOpacity(0.85)
                      : secondaryTextColor,
                  height: 1.6,
                  fontStyle: inquiry.answer != null && inquiry.answer!.isNotEmpty
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

  // _buildSectionContainer는 StatelessWidget의 멤버가 될 수 없으므로 static으로 만들거나,
  // 별도의 함수로 빼거나, build 메소드 내에 지역 함수로 정의해야 합니다.
  // 여기서는 편의상 static 메소드로 변경 (또는 build 메소드 안으로 옮겨도 됩니다)
  static Widget _buildSectionContainer({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String titleText,
    required Widget child,
    // 색상 변수를 파라미터로 전달받음
    required Color cardBgColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    return Container(
      width: double.infinity,
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