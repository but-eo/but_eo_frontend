import 'package:flutter/material.dart';
import 'FAQDetailPage.dart'; // 반드시 lib/pages/FAQDetailPage.dart에 따로 만들어주세요

class AskedQuestions extends StatelessWidget {
  const AskedQuestions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('자주 묻는 질문', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: dummyInquiries.length,
        itemBuilder: (context, index) {
          final inquiry = dummyInquiries[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FAQDetailPage(inquiry: inquiry),
                  ),
                );
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          inquiry['title']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          inquiry['content']!,
                          style: const TextStyle(color: Colors.black54, fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// 자주 묻는 질문 더미 데이터
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
