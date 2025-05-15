import 'package:flutter/material.dart';

class NoticePage extends StatelessWidget {
  const NoticePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> notices = [
      {
        'title': '[안내] 5월 20일 서비스 점검 예정',
        'date': '2025.05.13',
        'content': '더 나은 서비스를 위해 5월 20일 00:00~04:00 동안 서버 점검이 진행됩니다. 이 시간 동안 일부 기능이 제한될 수 있습니다.'
      },
      {
        'title': '[공지] 개인정보 처리방침 변경 안내',
        'date': '2025.05.01',
        'content': '개인정보 처리방침이 2025년 6월 1일자로 변경됩니다. 변경된 내용은 고객센터 > 공지사항을 참고해 주세요.'
      },
      {
        'title': '[신규] 경기장 예약 기능 업데이트',
        'date': '2025.04.25',
        'content': '경기장 예약 기능이 새롭게 개선되었습니다. 상세 페이지에서 시간대별 예약 현황을 확인할 수 있습니다.'
      },
      {
        'title': '[점검 완료] 시스템 안정화 작업',
        'date': '2025.04.15',
        'content': '4월 15일 오전 5시부터 7시까지 진행된 시스템 안정화 작업이 정상적으로 완료되었습니다.'
      },
      {
        'title': '[이벤트] 친구 초대하고 포인트 받자!',
        'date': '2025.04.10',
        'content': '친구를 초대하면 포인트를 드려요. 마이페이지 > 친구 초대 메뉴를 통해 참여하세요.'
      },
      {
        'title': '[중요] 앱 최신 버전 업데이트 권장',
        'date': '2025.03.30',
        'content': '보다 안전한 사용을 위해 앱을 최신 버전으로 업데이트해 주세요.'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('공지사항', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0.3,
      ),
      backgroundColor: Colors.white,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notices.length,
        itemBuilder: (context, index) {
          final notice = notices[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notice['title']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Text(
                      notice['date']!,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  notice['content']!,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
