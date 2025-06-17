import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/pages/team/teamReviewPage.dart'; // 팀 리뷰 조회 페이지 임포트
import 'package:project/pages/team/widgets/reviewWritePage.dart';
import 'package:project/service/matchService.dart';
import 'package:project/appStyle/app_colors.dart';

class CompletedMatchesList extends StatefulWidget {
  final String teamId;
  const CompletedMatchesList({super.key, required this.teamId});

  @override
  State<CompletedMatchesList> createState() => _CompletedMatchesListState();
}

class _CompletedMatchesListState extends State<CompletedMatchesList> {
  Future<List<Map<String, dynamic>>>? _matchesFuture;
  final Matchservice _matchservice = Matchservice();

  @override
  void initState() {
    super.initState();
    _matchesFuture = _fetchMatches(); // 초기 데이터 로드 시작
  }

  // 이 메서드는 Future<List<Map<String, dynamic>>> 타입을 반환해야 합니다.
  Future<List<Map<String, dynamic>>> _fetchMatches() async {
    try {
      final List<Map<String, dynamic>> fetchedData = await _matchservice.fetchCompletedMatchesByTeam(widget.teamId);
      // 데이터를 성공적으로 가져왔다면, 이 데이터를 직접 반환합니다.
      return fetchedData;
    } catch (e) {
      if (mounted) { // 위젯이 아직 위젯 트리에 있는지 확인
        _showSnackBar("완료된 경기 정보를 불러오는 데 실패했습니다: $e");
      }
      // 에러가 발생하면, 이 에러를 다시 던져서 FutureBuilder가 에러를 잡을 수 있도록 합니다.
      rethrow; // 'throw e;' 대신 'rethrow;'를 사용하여 스택 트레이스를 보존하는 것이 더 좋습니다.
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _matchesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 50),
                  const SizedBox(height: 10),
                  Text(
                    "데이터를 불러오는데 실패했습니다: ${snapshot.error}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _matchesFuture = _fetchMatches(); // 에러 발생 시 재시도
                      });
                    },
                    child: const Text("다시 시도"),
                  ),
                ],
              ),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sports_soccer_outlined, color: Colors.grey, size: 60),
                SizedBox(height: 10),
                Text(
                  "아직 완료된 경기가 없습니다.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        } else {
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
                  formattedDate = DateFormat('yyyy년 M월 d일 (E) HH:mm', 'ko_KR').format(dateTime);
                }
              } catch (e) {
                print("날짜 파싱 오류: $e");
              }

              final String requestingTeamName = match['teamName'] ?? '알 수 없음';
              final String targetMatchName =
              (match['challengerTeam'] != null && match['challengerTeam'] is Map)
                  ? match['challengerTeam']['teamName'] ?? '상대팀 없음'
                  : '상대팀 없음';

              final String requestingTeamId = widget.teamId;
              final String targetTeamId =
              (match['challengerTeam'] != null && match['challengerTeam'] is Map) // 'challellerTeam' 오타 수정
                  ? match['challengerTeam']['teamId'] ?? ''
                  : '';

              // 현재 스코어 정보 추출 (없을 경우 기본값)
              final int homeScore = match['homeScore'] ?? 0;
              final int awayScore = match['awayScore'] ?? 0;

              // 리뷰 작성 여부 (TODO: 실제로는 서버에서 가져와야 함)
              // 여기서는 임시로 'false'로 설정합니다.
              final bool hasReviewed = false; // 예를 들어, match['hasReviewed'] 같은 필드가 있다면 사용

              return Card( // InkWell로 감싸지 않고, 카드 내부에 탭 가능한 요소 배치
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            formattedDate,
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
                              match['matchRegion'] ?? '주소 정보 없음',
                              style: const TextStyle(fontSize: 15, color: Colors.black87),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "우리 팀: ${match['teamName'] ?? '알 수 없음'}",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "상대 팀: $targetMatchName",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                "상대 팀 레이팅 : ${match['challengerTeam']['rating']}",
                              ),
                            ],
                          ),
                          // 스코어 표시
                          Text(
                            "$homeScore : $awayScore",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      // 리뷰 관련 버튼들
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // 이 경기의 상대팀에 대한 리뷰 조회 페이지로 이동
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TeamReviewPage(
                                      teamId: targetTeamId, // 리뷰 조회 대상은 상대 팀 ID
                                      sourceMatchId: match['matchId'], // 해당 매치 정보
                                      sourceTargetTeamName: targetMatchName, // 상대팀 이름
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: AppColors.baseWhiteColor,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('리뷰 보기', style: TextStyle(fontSize: 14)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: hasReviewed ? null : () async {
                                // 리뷰 작성 페이지로 이동
                                final bool? result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReviewWritePage(
                                      matchId: match['matchId'],
                                      targetTeamId: targetTeamId,
                                      targetTeamName: targetMatchName,
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  // 리뷰 작성 성공 시 목록 새로고침 또는 상태 업데이트
                                  _fetchMatches(); // 상태가 변경될 수 있으므로 목록 새로고침
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: hasReviewed ? Colors.grey : AppColors.baseGreenColor, // AppColors 사용
                                foregroundColor: AppColors.baseWhiteColor,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text(hasReviewed ? '리뷰 작성 완료' : '리뷰 작성', style: const TextStyle(fontSize: 14)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}