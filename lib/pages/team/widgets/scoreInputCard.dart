import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 날짜 포맷팅을 위해 추가

// MatchResultRegistrationPage는 이전 답변에서 보여드린 것처럼 필요한 데이터를 받을 수 있도록 선언되어 있어야 합니다.

class ScoreInputCard extends StatefulWidget {
  final Map<String, dynamic> match;
  final String formattedDate;

  const ScoreInputCard({
    Key? key,
    required this.match,
    required this.formattedDate,
  }) : super(key: key);

  @override
  State<ScoreInputCard> createState() => _ScoreInputCardState();
}

class _ScoreInputCardState extends State<ScoreInputCard> {
  final TextEditingController _myTeamScoreController = TextEditingController();
  final TextEditingController _opponentTeamScoreController =
      TextEditingController();

  @override
  void dispose() {
    _myTeamScoreController.dispose();
    _opponentTeamScoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 기존 날짜 및 장소 정보
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  widget.formattedDate,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.match['matchRegion'] ?? '주소 정보 없음',
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            // 나의 팀 및 상대팀 정보 (상단에 배치)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "우리 팀: ${widget.match['teamName'] ?? '알 수 없음'}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "상대 팀: ${widget.match['challengerTeam']['teamName'] ?? '상대팀 없음'}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  "상대 팀 레이팅 : ${widget.match['challengerTeam']['rating']}",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20), // 팀 정보와 점수 입력 필드 사이 간격
            // 점수 입력 섹션
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 나의 팀 점수 입력
                Column(
                  children: [
                    const Text(
                      '나의 팀',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 60, // 입력 필드 너비
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
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
                const Text(
                  'vs', // 'vs' 텍스트 추가
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                // 상대팀 점수 입력
                Column(
                  children: [
                    const Text(
                      '상대팀',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 60, // 입력 필드 너비
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
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 등록하기 버튼
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // 여기에 점수 등록 로직 추가
                  // _myTeamScoreController.text 와 _opponentTeamScoreController.text 값을 사용
                  final String myScore = _myTeamScoreController.text;
                  final String opponentScore =
                      _opponentTeamScoreController.text;

                  if (myScore.isNotEmpty && opponentScore.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '점수 등록: 나의 팀 $myScore, 상대팀 $opponentScore',
                        ),
                      ),
                    );
                    // 실제로는 여기서 API 호출 등의 등록 로직을 수행합니다.
                    // 예: registerMatchResult(widget.match['matchId'], myScore, opponentScore);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('양 팀의 점수를 모두 입력해주세요.')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  '등록하기',
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

// 이 ScoreInputCard를 기존 Teammatches 위젯의 ListView.builder 내에서 사용
// 예를 들어:
/*
// TeammatchesState의 build 메서드 내부
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text("경기 일정"), centerTitle: true),
    body: FutureBuilder<List<Map<String, dynamic>>>(
      future: _matchesFuture,
      builder: (context, snapshot) {
        // ... (기존 로딩, 에러, 데이터 없음 처리)

        else {
          final matches = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final match = matches[index];
              String formattedDate = '날짜 미정';
              try {
                if (match['matchDate'] != null) {
                  final dateTime = DateTime.parse(match['matchDate']);
                  formattedDate = DateFormat(
                    'yyyy년 M월 d일 (E) HH:mm',
                    'ko_KR',
                  ).format(dateTime);
                }
              } catch (e) {
                print("날짜 파싱 오류: $e");
              }

              // 여기에서 ScoreInputCard를 반환합니다.
              return ScoreInputCard(
                match: match,
                formattedDate: formattedDate,
              );
            },
          );
        }
      },
    ),
  );
}
*/
