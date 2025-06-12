import 'package:flutter/material.dart';

class TeamReviewPage extends StatefulWidget {
  final String teamId;
  const TeamReviewPage({super.key, required this.teamId});

  @override
  State<TeamReviewPage> createState() => _TeamReviewPageState();
}

class _TeamReviewPageState extends State<TeamReviewPage> {
  bool hasWrittenReview = false; // 서버에서 가져온 값이라고 가정
  List<Map<String, dynamic>> pastMatchReviews = []; // 매치한 상대팀들의 리뷰 목록

  @override
  void initState() {
    super.initState();
    _fetchReviewData();
  }

  Future<void> _fetchReviewData() async {
    // TODO: 실제 서비스에서 서버 호출로 대체
    setState(() {
      hasWrittenReview = false; // 예시: 아직 작성하지 않은 경우
      pastMatchReviews = [
        {
          'teamName': '강호 FC',
          'content': '정말 매너 좋은 팀이었습니다! 다음에도 또 하고 싶어요.',
        },
        {
          'teamName': '도전자들',
          'content': '실력이 굉장히 좋았고, 전술적으로도 배울 점이 많았습니다.',
        },
      ];
    });
  }

  void _writeReview() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        String reviewText = '';
        return AlertDialog(
          title: const Text('리뷰 작성'),
          content: TextField(
            maxLines: 5,
            onChanged: (value) => reviewText = value,
            decoration: const InputDecoration(hintText: '리뷰 내용을 입력하세요'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
            TextButton(
              onPressed: () {
                if (reviewText.trim().isNotEmpty) {
                  // TODO: 서버에 리뷰 저장 요청
                  setState(() {
                    hasWrittenReview = true;
                  });
                  Navigator.pop(context, reviewText);
                }
              },
              child: const Text('작성 완료'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('리뷰가 저장되었습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('팀 리뷰')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!hasWrittenReview)
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.edit_note),
                  label: const Text('리뷰 작성하기'),
                  onPressed: _writeReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            const Text('상대팀들의 리뷰', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: pastMatchReviews.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final review = pastMatchReviews[index];
                  return ListTile(
                    leading: const Icon(Icons.sports_soccer),
                    title: Text(review['teamName'] ?? '알 수 없는 팀'),
                    subtitle: Text(review['content'] ?? ''),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}