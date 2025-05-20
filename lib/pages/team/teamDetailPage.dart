import 'package:flutter/material.dart';
import 'package:project/data/teamEnum.dart';
import 'package:project/service/teamService.dart';

class TeamDetailPage extends StatefulWidget {
  final Map<String, dynamic> team;
  const TeamDetailPage({super.key, required this.team});

  @override
  State<TeamDetailPage> createState() => _TeamDetailPageState();
}

class _TeamDetailPageState extends State<TeamDetailPage> {
  bool isLeader = false;

  @override
  void initState() {
    super.initState();
    _checkTeamLeader();
  }

  Future<void> _checkTeamLeader() async {
    final teamId = widget.team['teamId'].toString();
    final result = await TeamService.isTeamLeader(teamId);
    setState(() {
      isLeader = result;
    });
  }

  String getEnumLabel<T>(String? enumName, Map<T, String> enumMap) {
    try {
      final T enumValue = enumMap.keys.firstWhere(
            (e) => e.toString().split('.').last.toUpperCase() == enumName?.toUpperCase(),
      );
      return enumMap[enumValue] ?? "알 수 없음";
    } catch (_) {
      return enumMap.values.contains(enumName) ? enumName! : "알 수 없음";
    }
  }

  @override
  Widget build(BuildContext context) {
    final team = widget.team;
    final String teamName = team['teamName'] ?? '팀 이름 없음';
    final String region = getEnumLabel(team['region'], regionEnumMap);
    final String teamCase = getEnumLabel(team['teamCase'], teamCaseEnumMap);
    final String age = team['memberAge'] != null ? "${team['memberAge']}대" : "연령 미상";
    final String event = getEnumLabel(team['event'], eventEnumMap);
    final String description = (team['teamDescription'] as String?)?.trim().isNotEmpty == true
        ? team['teamDescription']
        : "팀 소개가 없습니다.";
    final int wins = team['winCount'] ?? 0;
    final int draws = team['drawCount'] ?? 0;
    final int losses = team['loseCount'] ?? 0;
    final int totalMembers = team['totalMembers'] ?? 0;

    final List<String> memberNames = List<String>.from(team['memberNames'] ?? []);

    return Scaffold(
      appBar: AppBar(
        title: Text(teamName),
        actions: isLeader
            ? [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: 수정 페이지 이동
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("삭제 확인"),
                  content: const Text("정말로 이 팀을 삭제할까요?"),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("취소")),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("삭제")),
                  ],
                ),
              );
              if (confirm == true) {
                await TeamService.deleteTeam(widget.team['teamId'].toString());
                Navigator.pop(context);
              }
            },
          ),
        ]
            : null,
      ),
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
              child: Text("$wins승 $draws무 $losses패",
                  style: const TextStyle(fontSize: 16, color: Colors.grey)),
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
            const Divider(height: 32),
            const Text("팀원 목록", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...memberNames.map((name) => Text("- $name")),
          ],
        ),
      ),
    );
  }
}
