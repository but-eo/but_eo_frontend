import 'package:flutter/material.dart';
import 'package:project/data/teamEnum.dart';
import 'package:project/pages/team/teamFormPage.dart';
import 'package:project/pages/team/teaminvitationpage.dart';
import 'package:project/pages/team/widgets/teamMatchRequestPage.dart';
import 'package:project/pages/team/teamMatches.dart';
import 'package:project/service/teamInvitaionService.dart';
import '../../service/teamService.dart';
import 'package:project/pages/team/widgets/teamProfile.dart';

class TeamDetailPage extends StatefulWidget {
  final Map<String, dynamic>? team;
  const TeamDetailPage({super.key, this.team});

  @override
  State<TeamDetailPage> createState() => _TeamDetailPageState();
}

class _TeamDetailPageState extends State<TeamDetailPage> {
  bool isLeader = false;
  bool isRequested = false; // 팀 가입 요청 상태
  Map<String, dynamic>? _team;
  bool _leaderChecked = false;

  @override
  void initState() {
    super.initState();
    _team = widget.team;
    if (_team != null) {
      print("📦 초기 팀 데이터: $_team"); // ✅ 팀 정보 확인
      _checkTeamLeader(_team!);
      // TODO: 사용자가 이 팀에 이미 가입 요청을 했는지 확인하는 API를 호출하여 isRequested 상태를 초기화해야 합니다.
      // 예: _checkJoinRequestStatus(_team!['teamId'].toString());
    }
  }

  void _checkTeamLeader(Map<String, dynamic> team) async {
    final teamId = team['teamId'].toString();
    try {
      final result = await TeamService.isTeamLeader(teamId);
      if (mounted) {
        setState(() {
          isLeader = result;
          _leaderChecked = true;
        });
      }
    } catch (e) {
      print("리더 확인 중 오류: $e");
      if (mounted) {
        setState(() => _leaderChecked = true); // 오류 발생 시에도 체크는 완료된 것으로 간주
      }
    }
  }

  Future<void> _handleJoinOrCancel() async {
    final teamId = _team!['teamId'].toString();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isRequested ? "가입 요청 취소" : "팀 가입 신청"),
        content: Text(isRequested ? "가입 요청을 취소하시겠습니까?" : "이 팀에 가입을 신청하시겠습니까?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("아니요")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("예")),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      if (isRequested) {
        await TeamInvitaionService.cancelJoinRequest(teamId);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("가입 요청이 취소되었습니다.")));
      } else {
        await TeamInvitaionService.requestJoinTeam(teamId);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("가입 요청이 전송되었습니다.")));
      }
      if (mounted) {
        setState(() => isRequested = !isRequested);
      }
    } catch (e) {
      print("요청 처리 오류: $e");
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("오류가 발생했습니다: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (_team == null && args != null && args is Map<String, dynamic>) {
      _team = Map<String, dynamic>.from(args);
      if (!_leaderChecked) {
        _checkTeamLeader(_team!);
      }
    }

    if (_team == null) {
      return Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(title: const Text('오류')),
        body: const Center(child: Text('팀 데이터가 없습니다.')),
      );
    }

    final team = _team!;
    final String teamName = team['teamName'] ?? '팀 이름 없음';
    final String region = getEnumLabel(team['region'], regionEnumMap);
    final String teamCase = getEnumLabel(team['teamCase'], teamCaseEnumMap);
    final String age =
        team['memberAge'] != null ? "${team['memberAge']}대" : "연령 미상";
    final String event = getEnumLabel(team['event'], eventEnumMap);
    final String description =
        (team['teamDescription'] as String?)?.trim().isNotEmpty == true
            ? team['teamDescription']
            : "팀 소개가 없습니다.";
    final int memberCount = team['totalMembers'] ?? 0;
    final List<dynamic> members = team['members'] ?? [];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(teamName,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 20)),
        actions: isLeader
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => TeamFormPage(initialData: team)));
                    if (result == 'update') {
                      try {
                        final updatedTeam = await TeamService.getTeamById(
                            team['teamId'].toString());
                        if (mounted) {
                          setState(() {
                            _team = updatedTeam;
                            _checkTeamLeader(_team!);
                          });
                        }
                      } catch (e) {
                        if (mounted)
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("팀 정보를 다시 불러오는데 실패했습니다.")));
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
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("취소")),
                          TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("삭제")),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await TeamService.deleteTeam(team['teamId'].toString());
                      if (mounted) Navigator.pop(context, 'updated');
                    }
                  },
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: TeamProfile(team: team)),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                ],
              ),
              child: Column(
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("지역: $region",
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        Text("유형: $teamCase",
                            style: TextStyle(fontWeight: FontWeight.w500)),
                      ]),
                  const SizedBox(height: 10),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("연령대: $age",
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        Text("종목: $event",
                            style: TextStyle(fontWeight: FontWeight.w500)),
                      ]),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text("팀 소개",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12, blurRadius: 3, offset: Offset(0, 1))
                ],
              ),
              child: Text(description,
                  style: TextStyle(fontSize: 15, color: Colors.black87)),
            ),
            if (isLeader) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  _buildLeaderButton(
                    context: context,
                    label: "매치 신청 조회",
                    icon: Icons.assignment_turned_in_outlined,
                    color: Colors.blueAccent,
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => Teammatchrequestpage(
                                teamId: team['teamId'].toString()))),
                  ),
                  const SizedBox(width: 12),
                  _buildLeaderButton(
                    context: context,
                    label: "팀 경기 일정",
                    icon: Icons.calendar_month_outlined,
                    color: Colors.orangeAccent,
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                Teammatches(teamId: team['teamId'].toString()))),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text("팀원 목록",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 6),
                    Text("($memberCount명)",
                        style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
                if (_leaderChecked)
                  isLeader
                      ? ElevatedButton.icon(
                          icon: const Icon(Icons.people_outline),
                          label: const Text("신청자 목록 보기"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          onPressed: () async {
                            final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => Teaminvitationpage(
                                        teamId: team['teamId'].toString())));
                            if (result == true) {
                              final updatedTeam =
                                  await TeamService.getTeamById(
                                      team['teamId'].toString());
                              if (mounted) setState(() => _team = updatedTeam);
                            }
                          },
                        )
                      : ElevatedButton.icon(
                          icon: Icon(
                              isRequested
                                  ? Icons.cancel_outlined
                                  : Icons.group_add_outlined,
                              size: 18),
                          label:
                              Text(isRequested ? "요청 취소" : "팀 가입하기"),
                          onPressed: _handleJoinOrCancel,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: isRequested
                                  ? Colors.grey[600]
                                  : Colors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                        )
              ],
            ),
            const SizedBox(height: 12),
            _buildMemberList(members),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderButton(
      {required BuildContext context,
      required String label,
      required IconData icon,
      required Color color,
      required VoidCallback onPressed}) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          textStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          elevation: 2,
        ),
      ),
    );
  }

  String getEnumLabel<T>(String? enumName, Map<T, String> enumMap) {
    try {
      if (enumName == null) return "알 수 없음";
      final T enumValue = enumMap.keys.firstWhere(
        (e) => e.toString().split('.').last.toUpperCase() == enumName.toUpperCase(),
      );
      return enumMap[enumValue] ?? "알 수 없음";
    } catch (_) {
      return enumName ?? "알 수 없음";
    }
  }

  Widget _buildMemberList(List<dynamic> members) {
    if (members.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Text("아직 팀원이 없습니다."),
      );
    }
    final sortedMembers = List<Map<String, dynamic>>.from(members)
      ..sort((a, b) {
        final aIsLeader = a['leader'] == true ? 0 : 1;
        final bIsLeader = b['leader'] == true ? 0 : 1;
        return aIsLeader.compareTo(bIsLeader);
      });
    return Column(
      children: sortedMembers.map((member) {
        final name = member['name'] ?? '이름 없음';
        final isLeader = member['leader'] == true;
        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            leading:
                const Icon(Icons.person_outline, color: Colors.indigo, size: 28),
            title: Row(
              children: [
                Expanded(
                    child: Text(name,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1)),
                if (isLeader) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.indigo[100],
                        borderRadius: BorderRadius.circular(12)),
                    child: const Text("Leader",
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.indigo,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}