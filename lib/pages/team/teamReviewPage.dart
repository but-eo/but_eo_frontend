import 'package:flutter/material.dart';
import 'package:project/service/reviewService.dart';

//TODO : 색 옮기기
class AppColors {
  static const baseBlackColor = Color(0xff1b1b1d);
  static const baseGrey10Color = Color(0xfff6f6f6);
  static const baseGreenColor = Color(0xff03c75a);
  static const baseWhiteColor = Colors.white;

  static final Color brandBlue = Colors.blue.shade500;
  static const Color brandBlack = Color(0xff1b1b1d);
  static const Color lightGrey = Color(0xfff6f6f6);
  static final Color mediumGrey = Colors.grey.shade600;
  static const Color textPrimary = Colors.black87;
  static final Color textSecondary = mediumGrey;
  static final Color textSubtle = Colors.black54;
}

class TeamReviewPage extends StatefulWidget {
  final String teamId;
  const TeamReviewPage({super.key, required this.teamId});

  @override
  State<TeamReviewPage> createState() => _TeamReviewPageState();
}

class _TeamReviewPageState extends State<TeamReviewPage> {
  // 로딩 상태를 위한 변수
  bool _isLoading = true;
  // 현재 팀의 리뷰 목록
  List<Map<String, dynamic>> _teamReviews = [];
  // 현재 사용자가 이 팀에 리뷰를 작성했는지 여부 (성공적으로 작성 후 true로 설정)
  bool _hasUserWrittenReview = false; // TODO: 서버에서 실제 값 가져오도록 구현 필요

  @override
  void initState() {
    super.initState();
    _fetchReviewData();
  }

  // 팀 리뷰 데이터를 서버에서 가져오는 함수
  Future<void> _fetchReviewData() async {
    setState(() {
      _isLoading = true; // 데이터 로딩 시작
    });

    try {
      final List<dynamic> fetchedReviews = await ReviewService.getTeamReviews(widget.teamId);

      setState(() {
        _teamReviews = List<Map<String, dynamic>>.from(fetchedReviews);

      });
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

  void _writeReview() async {
    String reviewContent = '';
    int reviewRating = 5; // 초기 평점 5점

    final result = await showDialog<Map<String, dynamic>>( // Map<String, dynamic>으로 결과 받기
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('리뷰 작성', style: TextStyle(fontWeight: FontWeight.bold)),
          content: StatefulBuilder( // AlertDialog 내의 상태를 업데이트하기 위해 StatefulBuilder 사용
            builder: (BuildContext context, StateSetter setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 별점 입력 위젯
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return InkWell(
                        onTap: () {
                          setModalState(() { // 다이얼로그 내의 상태 업데이트
                            reviewRating = index + 1;
                          });
                        },
                        child: Icon(
                          index < reviewRating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 30,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  // 리뷰 내용 입력 필드
                  TextField(
                    maxLines: 5,
                    onChanged: (value) => reviewContent = value,
                    decoration: InputDecoration(
                      hintText: '이 팀에 대한 리뷰를 입력해주세요.',
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: AppColors.brandBlack),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('취소', style: TextStyle(color: AppColors.mediumGrey)), // 취소 버튼 색상 변경
            ),
            ElevatedButton( // '작성 완료' 버튼을 ElevatedButton으로 변경
              onPressed: () async {
                if (reviewContent.trim().isEmpty || reviewRating == 0) {
                  // 내용 또는 평점이 없을 경우 경고 메시지 표시
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('리뷰 내용과 평점을 모두 입력해주세요.')),
                    );
                  }
                  return; // 함수 종료
                }
                Navigator.pop(context, {'content': reviewContent, 'rating': reviewRating});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandBlue, // 버튼 배경색 변경
                foregroundColor: AppColors.baseWhiteColor, // 버튼 텍스트 색상 변경
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('작성 완료'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      final String content = result['content'];
      final int rating = result['rating'];

      // TODO: matchId는 현재 페이지에서 알 수 없는 정보 지금 매치가 안됨
      const String placeholderMatchId = 'TODO_MATCH_ID';

      final String? error = await ReviewService.writeReview(
        matchId: placeholderMatchId,
        targetTeamId: widget.teamId,
        rating: rating,
        content: content,
      );

      if (error == null) {
        // 리뷰 작성 성공
        setState(() {
          _hasUserWrittenReview = true; // 리뷰 작성 성공했음을 표시
        });
        await _fetchReviewData(); // 리뷰 목록 새로고침
        if (mounted) { // 위젯이 마운트된 상태인지 확인
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('리뷰가 성공적으로 저장되었습니다.')),
          );
        }
      } else {
        // 리뷰 작성 실패
        if (mounted) { // 위젯이 마운트된 상태인지 확인
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
        backgroundColor: AppColors.brandBlue,
        foregroundColor: AppColors.baseWhiteColor,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // '상대팀들이 남긴 리뷰' 제목
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '상대팀들이 남긴 리뷰',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary, // 텍스트 색상 변경
                      ),
                    ),
                    // 리뷰 작성 버튼 섹션 (오른쪽에 작게 배치)
                    if (!_hasUserWrittenReview) // 이미 리뷰를 작성했다면 버튼을 숨깁니다.
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), // 둥근 모양으로 변경
                        margin: EdgeInsets.zero, // 기본 마진 제거
                        child: InkWell(
                          onTap: _writeReview,
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // 패딩 더 줄이기
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.edit_note, color: AppColors.brandBlack, size: 20), // 아이콘 색상 변경
                                const SizedBox(width: 6), // 간격 줄이기
                                Text(
                                  '리뷰 작성',
                                  style: TextStyle(
                                      fontSize: 14, // 텍스트 크기 줄이기
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.brandBlack // 텍스트 색상 변경
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const Divider(height: 20, thickness: 1), // 구분선 추가
                const SizedBox(height: 12),
                // 리뷰 목록
                Expanded(
                  child: _teamReviews.isEmpty
                      ? Center(
                    child: Text(
                      '아직 이 팀에 대한 리뷰가 없습니다.',
                      style: TextStyle(fontSize: 16, color: AppColors.textSecondary), // 텍스트 색상 변경
                    ),
                  )
                      : ListView.separated(
                    itemCount: _teamReviews.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10), // 리뷰 사이 간격
                    itemBuilder: (context, index) {
                      final review = _teamReviews[index];
                      // 각 리뷰를 Card 위젯으로 감싸서 더 보기 좋게 만듭니다.
                      return Card(
                        elevation: 3, // 그림자 더 강조
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // 둥근 모서리
                        margin: const EdgeInsets.symmetric(vertical: 4), // 목록 아이템 간 여백
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.sports_soccer, color: Colors.deepOrange, size: 20), // 아이콘 색상 유지 (포인트 색상)
                                  const SizedBox(width: 8),
                                  Expanded( // 텍스트가 길어질 경우를 대비해 Expanded 추가
                                    child: Text(
                                      review['writerName'] ?? '익명 팀', // 리뷰 작성 팀 이름 (writerName 필드 사용)
                                      style: TextStyle(
                                          fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary), // 텍스트 색상 변경
                                      overflow: TextOverflow.ellipsis, // 텍스트 오버플로우 처리
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // 평점 별 아이콘 표시
                                  Row(
                                    children: List.generate(5, (starIndex) {
                                      final double currentRating = (review['rating'] ?? 0).toDouble(); // rating 필드 사용
                                      return Icon(
                                        starIndex < currentRating ? Icons.star : Icons.star_border,
                                        color: Colors.amber, // 별점 색상 유지
                                        size: 18,
                                      );
                                    }),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                review['content'] ?? '내용 없음',
                                style: TextStyle(fontSize: 14, color: AppColors.textSubtle), // 텍스트 색상 변경
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

        ],
      ),
    );
  }
}
