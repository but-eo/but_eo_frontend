import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/service/matchService.dart';

class OngoingMatchesList extends StatefulWidget {
  final String teamId;
  const OngoingMatchesList({super.key, required this.teamId});

  @override
  State<OngoingMatchesList> createState() => _OngoingMatchesListState();
}

class _OngoingMatchesListState extends State<OngoingMatchesList> {
  Future<List<Map<String, dynamic>>>? _matchesFuture;
  final Matchservice _matchservice = Matchservice();

  @override
  void initState() {
    super.initState();
    _matchesFuture = _fetchMatches();
  }

  Future<List<Map<String, dynamic>>> _fetchMatches() async {
    try {
      // Matchservice를 사용하여 진행 중 경기 데이터 가져오기
      return await _matchservice.fetchOngoingMatchesByTeam(widget.teamId);
    } catch (e) {
      // SnackBar는 여기서 직접 표시하는 대신, FutureBuilder의 에러 처리를 통해 메시지를 보여줄 수 있습니다.
      // 하지만 즉각적인 피드백을 위해 SnackBar도 유지합니다.
      _showSnackBar("진행 중 경기 정보를 불러오는 데 실패했습니다: $e");
      rethrow; // 에러를 다시 던져서 FutureBuilder가 처리하도록 함
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
                        _matchesFuture = _fetchMatches();
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
                  "아직 진행 예정 경기가 없습니다.",
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
              (match['challengerTeam'] != null && match['challellerTeam'] is Map)
                  ? match['challengerTeam']['teamName'] ?? '상대팀 없음'
                  : '상대팀 없음';

              return InkWell(
                onTap: () {
                  _showSnackBar("진행 예정 경기의 상세 정보를 볼 수 있습니다.");
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => OngoingMatchDetailPage(match: match)));
                },
                child: Card(
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
                          ],
                        ),
                      ],
                    ),
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