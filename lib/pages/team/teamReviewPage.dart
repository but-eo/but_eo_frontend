import 'package:flutter/material.dart';
import 'package:project/service/reviewService.dart';
import 'package:project/appStyle/app_colors.dart';

class TeamReviewPage extends StatefulWidget {
  final String teamId;
  final String? sourceMatchId; // 어느 매치에서 이 팀을 만났는지
  final String? sourceTargetTeamName; // 이 팀의 이름 (표시용)

  const TeamReviewPage({
    super.key,
    required this.teamId,
    this.sourceMatchId,
    this.sourceTargetTeamName,
  });

  @override
  State<TeamReviewPage> createState() => _TeamReviewPageState();
}

class _TeamReviewPageState extends State<TeamReviewPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _teamReviews = [];
  bool _hasUserWrittenReviewForThisTeam = false; // 현재 로그인한 사용자가 이 팀에 대해 리뷰를 작성했는지 여부

  @override
  void initState() {
    super.initState();
    _fetchReviewData();
    // TODO: _hasUserWrittenReviewForThisTeam 상태를 초기화하는 로직 추가
  }

  Future<void> _fetchReviewData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final List<dynamic> fetchedReviews = await ReviewService.getTeamReviews(widget.teamId);
      setState(() {
        _teamReviews = List<Map<String, dynamic>>.from(fetchedReviews);
      });
      // TODO: 여기서 현재 사용자가 이 팀에 대해 작성한 리뷰가 있는지 확인하는 로직 추가
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('리뷰를 불러오는데 실패했습니다: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 리뷰 작성 팝업 및 API 호출 로직
  void _writeReview() async {
    // sourceMatchId가 없을 경우 경고 또는 다른 처리 필요
    if (widget.sourceMatchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('리뷰를 작성할 경기의 정보가 부족합니다.')),
      );
      return;
    }

    String reviewContent = '';
    int reviewRating = 5; // 초기 평점

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 16, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          title: Row(
            children: [
              Text(
                '${widget.sourceTargetTeamName ?? '상대팀'} 팀 리뷰 작성', // 상대팀 이름 표시
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(width: 12),
              StatefulBuilder(
                builder: (BuildContext context, StateSetter setModalState) {
                  return Row(
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            reviewRating = index + 1;
                          });
                        },
                        child: Icon(
                          index < reviewRating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        ),
                      );
                    }),
                  );
                },
              ),
              const Spacer(),
              InkWell(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, size: 20, color: AppColors.brandBlack),
              )
            ],
          ),
          content: TextField(
            maxLines: 5,
            onChanged: (value) => reviewContent = value,
            decoration: const InputDecoration(
              hintText: '상대팀에 대한 평가를 작성해주세요',
              hintStyle: TextStyle(color: AppColors.brandBlack),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
              contentPadding: EdgeInsets.all(12),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                if (reviewContent.trim().isEmpty || reviewRating == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('리뷰 내용과 평점을 모두 입력해주세요.')),
                  );
                  return;
                }
                Navigator.pop(context, {'content': reviewContent, 'rating': reviewRating});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.baseWhiteColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: const Text('저장'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      final String content = result['content'];
      final int rating = result['rating'];

      final String? error = await ReviewService.writeReview(
        matchId: widget.sourceMatchId!, // matchId는 반드시 있어야 함
        targetTeamId: widget.teamId, // 이 페이지의 teamId가 리뷰 대상
        rating: rating,
        content: content,
      );

      if (error == null) {
        setState(() {
          _hasUserWrittenReviewForThisTeam = true; // 리뷰 작성 완료 상태 업데이트
        });
        await _fetchReviewData(); // 리뷰 목록 새로고침
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('리뷰가 성공적으로 저장되었습니다.')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('리뷰 작성 실패: $error')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('팀 리뷰'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.baseWhiteColor,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.sourceTargetTeamName ?? '이 팀'}에 대한 리뷰', // 팀 이름 표시
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                // 현재 사용자가 이 팀에 대해 아직 리뷰를 작성하지 않았을 경우에만 버튼 표시
                if (!_hasUserWrittenReviewForThisTeam && widget.sourceMatchId != null)
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    margin: EdgeInsets.zero,
                    child: InkWell(
                      onTap: _writeReview,
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit_note, color: AppColors.brandBlack, size: 20),
                            const SizedBox(width: 6),
                            Text(
                              '리뷰 작성',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.brandBlack,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            const SizedBox(height: 12),
            Expanded(
              child: _teamReviews.isEmpty
                  ? Center(
                child: Text(
                  '아직 이 팀에 대한 리뷰가 없습니다.',
                  style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                ),
              )
                  : ListView.separated(
                itemCount: _teamReviews.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final review = _teamReviews[index];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.sports_soccer, color: Colors.deepOrange, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  review['writerTeamName'] ?? '익명 팀', // 작성 팀 이름 표시
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Row(
                                children: List.generate(5, (starIndex) {
                                  final double currentRating = (review['rating'] ?? 0).toDouble();
                                  return Icon(
                                    starIndex < currentRating ? Icons.star : Icons.star_border,
                                    color: Colors.amber,
                                    size: 18,
                                  );
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            review['content'] ?? '내용 없음',
                            style: TextStyle(fontSize: 14, color: AppColors.textSubtle),
                          ),
                        ],
                      ),
                    ),
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