import 'package:flutter/material.dart';
import 'package:project/data/teamEnum.dart';
import 'package:project/service/teamService.dart';

class TeamDetailPage extends StatelessWidget {
  final Map<String, dynamic> team;
  const TeamDetailPage({super.key, required this.team});

  String getEnumLabel<T>(String? enumName, Map<T, String> enumMap) {
    try {
      final T enumValue = enumMap.keys.firstWhere(
            (e) => e.toString().split('.').last.toUpperCase() == enumName?.toUpperCase(),
      );
      return enumMap[enumValue] ?? "알 수 없음";
    } catch (_) {
      return "알 수 없음";
    }
  }

  @override
  Widget build(BuildContext context) {
    final String teamName = team['teamName'] ?? '팀 이름 없음';
    final String region = getEnumLabel(team['region'], regionEnumMap);
    final String teamCase = getEnumLabel(team['teamCase'], teamCaseEnumMap);
    final String age = team['memberAge'] != null ? "${team['memberAge']}대" : "연령 미상";
    final String event = getEnumLabel(team['event'], eventEnumMap);
    final String description = team['teamDescription'] ?? "팀 소개가 없습니다.";
    final int wins = team['winCount'] ?? 0;
    final int draws = team['drawCount'] ?? 0;
    final int losses = team['loseCount'] ?? 0;
    final int totalMembers = team['totalMembers'] ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text(teamName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey,
                backgroundImage: team['teamImg'] != null && team['teamImg'].toString().isNotEmpty
                    ? NetworkImage(TeamService.getFullTeamImageUrl(team['teamImg']))
                    : null,
                child: team['teamImg'] == null || team['teamImg'].toString().isEmpty
                    ? const Icon(Icons.group, size: 40, color: Colors.white)
                    : null,
              ),
            ),

            const SizedBox(height: 16),
            Center(
              child: Text(
                teamName,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                "$wins승 $draws무 $losses패",
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("지역: $region"),
                Text("유형: $teamCase"),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("평균연령: $age"),
                Text("경기종목: $event"),
              ],
            ),
            const SizedBox(height: 8),
            Text("인원 수: $totalMembers명"),
            const Divider(height: 32),
            const Text("팀 소개", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(description),
          ],
        ),
      ),
    );
  }
}
