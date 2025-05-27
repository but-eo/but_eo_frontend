import 'package:flutter/material.dart';
import 'package:project/data/teamEnum.dart';
import 'package:project/pages/team/teamFormPage.dart';
import 'package:project/pages/team/teamInvitaion.dart';
import 'package:project/service/teamService.dart';

class TeamDetailPage extends StatefulWidget {
  final Map<String, dynamic> team;
  const TeamDetailPage({super.key, required this.team});

  @override
  State<TeamDetailPage> createState() => _TeamDetailPageState();
}

class _TeamDetailPageState extends State<TeamDetailPage> {
  bool isLeader = false;
  late Map<String, dynamic> team; // 'team' 상태를 업데이트할 수 있도록 late로 선언

  @override
  void initState() {
    super.initState();
    team = Map<String, dynamic>.from(widget.team); // 초기 데이터를 복사
    _checkTeamLeader();
  }

  Future<void> _checkTeamLeader() async {
    final teamId = team['teamId'].toString();
    final result = await TeamService.isTeamLeader(teamId);
    if (mounted) {
      setState(() {
        isLeader = result;
      });
    }
  }

  String getEnumLabel<T>(String? enumName, Map<T, String> enumMap) {
    try {
      if (enumName == null) return "알 수 없음";
      final T enumValue = enumMap.keys.firstWhere(
            (e) => e.toString().split('.').last.toUpperCase() == enumName.toUpperCase(),
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
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TeamFormPage(initialData: team), // 현재 팀 정보를 전달
                ),
              );

              if (result == 'update') {
                // 팀 이름으로 최신 정보를 다시 불러온다
                try {
                  final updatedTeam = await TeamService.getTeamByName(team['teamName'].toString());
                  if (mounted && updatedTeam != null) {
                    setState(() {
                      team = updatedTeam; // 업데이트된 팀 정보로 상태를 갱신
                    });
                  }
                } catch (e) {
                  print("팀 정보 다시 불러오기 실패: $e");
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("팀 정보를 다시 불러오는데 실패했습니다.")),
                    );
                  }
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("삭제 확인"),
                  content: const Text("정말로 이 팀을 삭제할까요?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text("취소"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text("삭제"),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await TeamService.deleteTeam(team['teamId'].toString());
                if (mounted) {
                  // 팀 삭제 후 'updated' 신호를 전달하여 팀 목록을 갱신
                  Navigator.pop(context, 'updated');
                }
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
                // 이미지 URL 갱신을 위해 캐시를 피하는 쿼리 파라미터 추가
                backgroundImage: team['teamImg'] != null && team['teamImg'].toString().isNotEmpty
                    ? NetworkImage("${TeamService.getFullTeamImageUrl(team['teamImg'])}?v=${DateTime.now().millisecondsSinceEpoch}")
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("팀원 목록", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (!isLeader) // 리더가 아닐 때만 "팀 가입하기" 버튼 표시
                  ElevatedButton.icon(
                    icon: const Icon(Icons.group_add),
                    label: const Text("팀 가입하기"),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TeamInvitation(isRequested: false),
                        ),
                      );
                      //TODO: 가입 후 팀원 목록 갱신이 필요하다면 여기서 fetchTeams() 또는 별도 함수 호출
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ...memberNames.map((name) => Text("- $name")),
          ],
        ),
      ),
    );
  }
}