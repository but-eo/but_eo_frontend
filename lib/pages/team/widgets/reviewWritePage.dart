import 'package:flutter/material.dart';
import 'package:project/service/reviewService.dart'; // ReviewService 임포트
import 'package:project/appStyle/app_colors.dart'; // AppColors 임포트

class ReviewWritePage extends StatefulWidget {
  final String matchId; // 어떤 경기에 대한 리뷰인지 (필수)
  final String targetTeamId; // 어떤 팀에 대한 리뷰인지 (필수)
  final String targetTeamName; // 표시용 상대팀 이름 (필수)

  const ReviewWritePage({
    super.key,
    required this.matchId,
    required this.targetTeamId,
    required this.targetTeamName,
  });

  @override
  State<ReviewWritePage> createState() => _ReviewWritePageState();
}

class _ReviewWritePageState extends State<ReviewWritePage> {
  final TextEditingController _reviewContentController = TextEditingController();
  int _reviewRating = 5; // 초기 평점

  @override
  void dispose() {
    _reviewContentController.dispose();
    super.dispose();
  }

  void _submitReview() async {
    final String reviewContent = _reviewContentController.text.trim();

    if (reviewContent.isEmpty || _reviewRating == 0) {
      _showSnackBar('리뷰 내용과 평점을 모두 입력해주세요.');
      return;
    }

    // ReviewService를 사용하여 리뷰 작성
    final String? error = await ReviewService.writeReview(
      matchId: widget.matchId,
      targetTeamId: widget.targetTeamId,
      rating: _reviewRating,
      content: reviewContent,
    );

    if (error == null) {
      _showSnackBar('리뷰가 성공적으로 작성되었습니다.');
      if (mounted) {
        Navigator.pop(context, true); // 리뷰 작성 성공 시 true 반환하며 이전 화면으로 돌아감
      }
    } else {
      _showSnackBar('리뷰 작성 실패: $error');
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.targetTeamName} 팀 리뷰 작성'), // 상대팀 이름 표시
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.baseWhiteColor,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '상대팀에 대한 평점을 선택해주세요:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _reviewRating = index + 1;
                      });
                    },
                    child: Icon(
                      index < _reviewRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 40,
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              '리뷰 내용을 작성해주세요:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _reviewContentController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: '상대팀에 대한 자세한 평가를 작성해주세요 (최소 10자)',
                hintStyle: TextStyle(color: AppColors.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.baseGreenColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: AppColors.baseWhiteColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  '리뷰 등록하기',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}