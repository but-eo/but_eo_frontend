import 'package:flutter/material.dart';
import 'FAQDetailPage.dart'; // FAQDetailPage는 이미 생성되어 있다고 가정합니다.

class AskedQuestions extends StatelessWidget {
  const AskedQuestions({super.key});

  // 색상 변수를 build 메소드 안으로 이동하거나, 아래처럼 클래스 멤버로 두되 final을 제거합니다.
  // StatelessWidget에서는 build 메소드 안에 지역 변수로 두는 것이 더 일반적입니다.
  // final Color _scaffoldBgColor = Colors.grey.shade200; // 이렇게 직접 초기화 X
  // final Color _cardBgColor = Colors.white;
  // final Color _appBarBgColor = Colors.white;
  // final Color _primaryTextColor = Colors.black87;
  // final Color _secondaryTextColor = Colors.grey.shade700;

  @override
  Widget build(BuildContext context) {
    // 색상 정의를 build 메소드 내부로 이동
    final Color scaffoldBgColor = Colors.grey.shade200;
    final Color cardBgColor = Colors.white;
    final Color appBarBgColor = Colors.white;
    final Color primaryTextColor = Colors.black87;
    final Color secondaryTextColor = Colors.grey.shade700;

    return Scaffold(
      backgroundColor: scaffoldBgColor, // 수정된 변수 사용
      appBar: AppBar(
        title: Text('자주 묻는 질문', style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold)),
        backgroundColor: appBarBgColor, // 수정된 변수 사용
        elevation: 0.5,
        iconTheme: IconThemeData(color: primaryTextColor),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: dummyInquiries.length,
        itemBuilder: (context, index) {
          final inquiry = dummyInquiries[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 1.0,
            color: cardBgColor, // 수정된 변수 사용
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FAQDetailPage(inquiry: inquiry),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            inquiry['title']!,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: primaryTextColor, // 수정된 변수 사용
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            inquiry['content']!,
                            style: TextStyle(color: secondaryTextColor, fontSize: 14), // 수정된 변수 사용
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                      child: Icon(Icons.chevron_right, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// 자주 묻는 질문 더미 데이터 (기존 코드 유지)
final List<Map<String, String>> dummyInquiries = [
  {
    'title': '매칭이 잡히지 않아요',
    'content': '3일째 매칭 요청했는데 응답이 없어요. 다른 방법 없을까요?',
    'answer': '일부 지역은 인원이 적어 시간이 소요될 수 있습니다. 계속 시도해 주세요!',
  },
  {
    'title': '결제했는데 프리미엄이 적용 안 돼요',
    'content': '광고 제거 옵션 결제했는데 여전히 광고가 나옵니다.',
    'answer': '앱을 재시작하거나 복원 버튼을 눌러주세요. 해결되지 않으면 문의 주세요.',
  },
  {
    'title': '비매너 사용자 신고하고 싶어요',
    'content': '상대방이 비속어를 사용하며 불쾌한 채팅을 했습니다.',
    'answer': '해당 사용자는 경고 조치되었으며 재발 시 제재됩니다.',
  },
  {
    'title': '닉네임 변경 가능한가요?',
    'content': '가입할 때 만든 닉네임을 수정하고 싶어요.',
    'answer': '설정 > 프로필 편집에서 닉네임 변경이 가능합니다.',
  },
  {
    'title': '앱이 자주 꺼져요',
    'content': '채팅방 들어갈 때마다 앱이 종료돼요. 오류인가요?',
    'answer': '해당 문제는 현재 수정 중이며 곧 업데이트될 예정입니다.',
  },
  {
    'title': '탈퇴 후 정보는 어떻게 되나요?',
    'content': '계정을 탈퇴하면 기존 기록도 모두 사라지나요?',
    'answer': '네, 탈퇴 시 모든 정보는 영구 삭제됩니다.',
  },
  {
    'title': '프로필 사진 변경이 안 돼요',
    'content': '갤러리에서 사진 선택했는데 저장이 안 됩니다.',
    'answer': '이미지 용량이 너무 클 경우 오류가 날 수 있습니다. 5MB 이하 이미지를 권장합니다.',
  },
];