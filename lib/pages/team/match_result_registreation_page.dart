import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // Dio 사용을 위해 추가
import 'package:project/utils/token_storage.dart'; // TokenStorage 사용을 위해 추가
import 'package:project/contants/api_contants.dart'; // ApiConstants 사용을 위해 추가

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
  final TextEditingController _myTeamScoreController = TextEditingController();
  final TextEditingController _opponentTeamScoreController =
      TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("매치 아이디 : ${widget.matchId}");
    print("내 팀 이름 : ${widget.requestingTeamName}");
    print("상대팀 이름 : ${widget.targetMatchName}");
    print("내 팀 아이디 : ${widget.requestingTeamId}");
    print("상대팀 아이디 : ${widget.targetTeamId}");
  }

  @override
  void dispose() {
    _myTeamScoreController.dispose();
    _opponentTeamScoreController.dispose();
    super.dispose();
  }

  // 서버에 결과를 전송하는 비동기 함수
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

    // 승패를 결정하고 winnerScore, loserScore 설정
    int winnerScore;
    int loserScore;
    String winnerTeamId; // 승리한 팀의 ID
    String loserTeamId; // 패배한 팀의 ID

    // myScore가 opponentScore보다 크면 myScore가 winnerScore
    if (myScore > opponentScore) {
      winnerScore = myScore;
      loserScore = opponentScore;
      winnerTeamId = widget.requestingTeamId; // 우리 팀이 승리했으므로 우리 팀의 ID
      loserTeamId = widget.targetTeamId; // 상대 팀의 ID
    } else if (opponentScore > myScore) {
      winnerScore = opponentScore;
      loserScore = myScore;
      winnerTeamId = widget.targetTeamId; // 상대 팀이 승리했으므로 상대 팀의 ID
      loserTeamId = widget.requestingTeamId; // 우리 팀의 ID
    } else {
      winnerScore = myScore;
      loserScore = opponentScore;
      winnerTeamId = '';
      loserTeamId = '';
    }

    final dio = Dio();
    String? token = await TokenStorage.getAccessToken();

    if (token == null) {
      _showSnackBar("로그인이 필요합니다.");
      return;
    }

    try {
      final response = await dio.patch(
        "${ApiConstants.baseUrl}/matchings/${widget.matchId}/result", // 실제 API 엔드포인트로 변경
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: {
          'matchId': widget.matchId,
          'winnerScore': winnerScore,
          'loserScore': loserScore,
          'winnerTeamId': winnerTeamId, // 승리 팀 ID 추가
          'loserTeamId': loserTeamId, // 패배 팀 ID 추가
        },
      );

      if (response.statusCode == 200) {
        _showSnackBar('경기 결과가 성공적으로 등록되었습니다.');
        Navigator.pop(context); // 결과 등록 후 이전 화면으로 돌아가기
      } else {
        _showSnackBar('결과 등록에 실패했습니다: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _showSnackBar('네트워크 오류 또는 서버 오류: ${e.response?.statusCode ?? '알 수 없음'}');
      print('DioError: ${e.message}');
    } catch (e) {
      _showSnackBar('예상치 못한 오류 발생: $e');
      print('Error: $e');
    }
  }

  // SnackBar를 표시하는 헬퍼 함수
  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('매치 결과 등록'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              // 전체 내용을 감싸는 Card
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 현재 매치 정보 표시 (matchId는 디버깅용으로만 보통 표시)
                    // Text(
                    //   '매치 ID: ${widget.matchId}',
                    //   style: const TextStyle(fontSize: 14, color: Colors.grey),
                    // ),
                    // const SizedBox(height: 8),

                    // 나의 팀 및 상대팀 정보
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Column(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         Text(
                    //           // const 제거
                    //           "나의 팀: ${widget.requestingTeamName}",
                    //           style: const TextStyle(
                    //             fontSize: 18,
                    //             fontWeight: FontWeight.w600,
                    //           ),
                    //         ),
                    //         const SizedBox(height: 4),
                    //         Text(
                    //           // const 제거
                    //           "상대 팀: ${widget.targetMatchName}",
                    //           style: const TextStyle(
                    //             fontSize: 18,
                    //             fontWeight: FontWeight.w600,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //     // 필요한 경우 여기에 상대팀 레이팅 등의 추가 정보 표시
                    //   ],
                    // ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // 나의 팀 점수 입력
                        Column(
                          children: [
                            Text(
                              widget.requestingTeamName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 80, // 입력 필드 너비
                              child: TextField(
                                controller: _myTeamScoreController,
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
                        ),
                        const Text(
                          ':',
                          style: TextStyle(
                            fontSize: 30, // 점수 사이의 구분자이므로 더 크게
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        // 상대팀 점수 입력
                        Column(
                          children: [
                            Text(
                              widget.targetMatchName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 80, // 입력 필드 너비
                              child: TextField(
                                controller: _opponentTeamScoreController,
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
                        ),
                      ],
                    ),
                    const SizedBox(height: 30), // 점수 입력과 버튼 사이 간격
                    // 등록하기 버튼
                    Center(
                      child: ElevatedButton(
                        onPressed: _submitMatchResult, // 점수 등록 함수 호출
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // 버튼 배경색
                          foregroundColor: Colors.white, // 버튼 텍스트 색상
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          '등록하기',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
