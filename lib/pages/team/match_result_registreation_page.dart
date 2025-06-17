import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:project/utils/token_storage.dart';
import 'package:project/contants/api_contants.dart';
import 'package:project/service/reviewService.dart'; // ReviewService 임포트
import 'package:project/appStyle/app_colors.dart'; // AppColors 임포트

class MatchResultRegistrationPage extends StatefulWidget {
  final String matchId; // 결과를 등록할 매치의 ID
  final String requestingTeamName; // 요청 팀 이름 (표시용)
  final String targetMatchName; // 대상 매치 이름 (표시용)
  final String requestingTeamId; // 우리 팀의 ID
  final String targetTeamId; // 상대 팀의 ID

  const MatchResultRegistrationPage({
    super.key,
    required this.matchId,
    required this.requestingTeamName,
    required this.targetMatchName,
    required this.requestingTeamId,
    required this.targetTeamId,
  });

  @override
  State<MatchResultRegistrationPage> createState() =>
      _MatchResultRegistrationPageState();
}

class _MatchResultRegistrationPageState
    extends State<MatchResultRegistrationPage> {
  // 점수 입력을 위한 TextEditingController 다시 사용
  final TextEditingController _myTeamScoreController = TextEditingController();
  final TextEditingController _opponentTeamScoreController =
  TextEditingController();

  bool _isResultRegistered = false; // 경기 결과 등록 여부 상태 (기본값 false)
  bool _hasReviewedOpponent = false; // 상대팀 리뷰 작성 여부 상태 (기본값 false)

  @override
  void initState() {
    super.initState();
    print("매치 아이디 : ${widget.matchId}");
    print("내 팀 이름 : ${widget.requestingTeamName}");
    print("상대팀 이름 : ${widget.targetMatchName}");
    print("내 팀 아이디 : ${widget.requestingTeamId}");
    print("상대팀 아이디 : ${widget.targetTeamId}");

    // TODO: 실제 앱에서는 여기서 서버로부터 이미 등록된 경기 결과나 리뷰 여부를 확인하여
    // _isResultRegistered 와 _hasReviewedOpponent 상태를 초기화해야 합니다.
    // 예: ReviewService.checkIfReviewed(widget.matchId, widget.targetTeamId) 등.
  }

  @override
  void dispose() {
    _myTeamScoreController.dispose();
    _opponentTeamScoreController.dispose();
    super.dispose();
  }

  // 서버에 경기 결과를 전송하는 비동기 함수
  void _submitMatchResult() async {
    final String myScoreText = _myTeamScoreController.text.trim();
    final String opponentScoreText = _opponentTeamScoreController.text.trim();

    if (myScoreText.isEmpty || opponentScoreText.isEmpty) {
      _showSnackBar('양 팀의 점수를 모두 입력해주세요.');
      return;
    }

    final int? myScore = int.tryParse(myScoreText);
    final int? opponentScore = int.tryParse(opponentScoreText);

    if (myScore == null || opponentScore == null) {
      _showSnackBar('점수는 숫자로 입력해주세요.');
      return;
    }

    // 무승부 처리 로직은 백엔드의 MatchResultRequest DTO와 컨트롤러에 따라 다르게 구현될 수 있습니다.
    // 여기서는 승패가 명확한 경우만 처리합니다.
    if (myScore == opponentScore) {
      _showSnackBar('무승부는 현재 지원되지 않거나 별도 처리가 필요합니다.');
      return;
    }

    int winnerScore;
    int loserScore;
    String winnerTeamId;
    String loserTeamId;

    if (myScore > opponentScore) {
      winnerScore = myScore;
      loserScore = opponentScore;
      winnerTeamId = widget.requestingTeamId; // 우리 팀 승리
      loserTeamId = widget.targetTeamId;
    } else {
      winnerScore = opponentScore;
      loserScore = myScore;
      winnerTeamId = widget.targetTeamId; // 상대 팀 승리
      loserTeamId = widget.requestingTeamId;
    }

    final dio = Dio();
    String? token = await TokenStorage.getAccessToken();

    if (token == null) {
      _showSnackBar("로그인이 필요합니다.");
      return;
    }

    try {
      final response = await dio.patch(
        "${ApiConstants.baseUrl}/matchings/${widget.matchId}/result",
        options: Options(headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'}),
        data: {
          // 'matchId': widget.matchId, // PathVariable로 받으므로 DTO에 없다면 불필요
          'winnerScore': winnerScore,
          'loserScore': loserScore,
          'winnerTeamId': winnerTeamId,
          'loserTeamId': loserTeamId,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _isResultRegistered = true; // 결과 등록 성공 시 상태 업데이트
        });
        _showSnackBar('경기 결과가 성공적으로 등록되었습니다.');
        // 경기 결과 등록 후 바로 페이지를 닫지 않고, 리뷰 작성 기회를 제공
      } else {
        _showSnackBar('결과 등록에 실패했습니다: ${response.statusCode}');
        print('결과 등록 실패 응답: ${response.data}');
      }
    } on DioException catch (e) {
      _showSnackBar('네트워크 오류 또는 서버 오류: ${e.response?.statusCode ?? '알 수 없음'}');
      print('DioError (결과 등록): ${e.message}');
      if (e.response != null) {
        print('DioError Response Data (결과 등록): ${e.response?.data}');
      }
    } catch (e) {
      _showSnackBar('예상치 못한 오류 발생 (결과 등록): $e');
      print('Error (결과 등록): $e');
    }
  }

  // 상대팀 리뷰 작성 비동기 함수
  void _writeReviewForOpponent() async {
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
                '${widget.targetMatchName} 팀 리뷰 작성',
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
        matchId: widget.matchId,
        targetTeamId: widget.targetTeamId,
        rating: rating,
        content: content,
      );

      if (error == null) {
        setState(() {
          _hasReviewedOpponent = true;
        });
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

  // SnackBar를 표시하는 헬퍼 함수
  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  // 점수 입력 필드를 만드는 헬퍼 위젯
  Widget _buildScoreInputField(String teamName, TextEditingController controller) {
    return Column(
      children: [
        Text(
          teamName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 100, // 입력 필드 너비
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 8,
              ),
              hintText: '점수',
            ),
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('경기 결과 등록'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.baseWhiteColor,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${widget.requestingTeamName} vs ${widget.targetMatchName}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 우리 팀 점수 입력 필드
                _buildScoreInputField(widget.requestingTeamName, _myTeamScoreController),
                const Text(':', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                // 상대 팀 점수 입력 필드
                _buildScoreInputField(widget.targetMatchName, _opponentTeamScoreController),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              // 경기 결과가 등록되지 않았고, 현재 로딩 중이 아니라면 활성화
              onPressed: _isResultRegistered ? null : _submitMatchResult,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isResultRegistered ? Colors.grey : AppColors.primaryBlue,
                foregroundColor: AppColors.baseWhiteColor,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                _isResultRegistered ? '경기 결과 등록 완료' : '경기 결과 등록',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 30),

            Text(
              '상대팀 (${widget.targetMatchName}) 평가하기',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              // 경기 결과가 등록되었고, 아직 리뷰를 작성하지 않았다면 활성화
              onPressed: _isResultRegistered && !_hasReviewedOpponent ? _writeReviewForOpponent : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: (_isResultRegistered && !_hasReviewedOpponent) ? AppColors.baseGreenColor : Colors.grey,
                foregroundColor: AppColors.baseWhiteColor,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                _hasReviewedOpponent ? '리뷰 작성 완료' : '상대팀 리뷰 작성',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}