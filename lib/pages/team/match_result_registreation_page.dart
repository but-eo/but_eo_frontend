import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:project/utils/token_storage.dart';
import 'package:project/contants/api_contants.dart';
// import 'package:project/service/reviewService.dart'; // ReviewService 임포트 제거
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
  // 점수 입력을 위한 TextEditingController
  final TextEditingController _myTeamScoreController = TextEditingController();
  final TextEditingController _opponentTeamScoreController =
  TextEditingController();

  bool _isResultRegistered = false; // 경기 결과 등록 여부 상태 (기본값 false)
  // bool _hasReviewedOpponent = false; // 리뷰 관련 상태 변수 제거

  @override
  void initState() {
    super.initState();
    print("매치 아이디 : ${widget.matchId}");
    print("내 팀 이름 : ${widget.requestingTeamName}");
    print("상대팀 이름 : ${widget.targetMatchName}");
    print("내 팀 아이디 : ${widget.requestingTeamId}");
    print("상대팀 아이디 : ${widget.targetTeamId}");

    // TODO: 실제 앱에서는 여기서 서버로부터 이미 등록된 경기 결과가 있는지 확인하여
    // _isResultRegistered 상태를 초기화해야 합니다.
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
        // 결과 등록 후 이전 화면으로 돌아감 (진행 중 경기 목록)
        Navigator.pop(context, true); // true를 반환하여 이전 화면에서 새로고침하도록
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
            // 리뷰 관련 UI는 모두 제거됨
          ],
        ),
      ),
    );
  }
}