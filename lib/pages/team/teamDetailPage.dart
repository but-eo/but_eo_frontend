import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:project/contants/api_contants.dart';
import 'package:project/data/teamEnum.dart';
import 'package:project/pages/mainpage.dart';
import 'package:project/pages/team/teamFormPage.dart';
import 'package:project/pages/team/teaminvitationpage.dart';
import 'package:project/pages/team/widgets/teamMatchRequestPage.dart';
import 'package:project/pages/team/widgets/teamMatches.dart';
import 'package:project/service/teamInvitaionService.dart';
import 'package:project/service/teamService.dart';
import 'package:project/pages/team/widgets/teamProfile.dart';
import 'package:project/utils/token_storage.dart';

class TeamDetailPage extends StatefulWidget {
  final Map<String, dynamic> team;
  const TeamDetailPage({super.key, required this.team});

  @override
  State<TeamDetailPage> createState() => _TeamDetailPageState();
}

class _TeamDetailPageState extends State<TeamDetailPage> {
  bool isLeader = false;
  bool isRequested = false;
  late Map<String, dynamic> team;

  @override
  void initState() {
    super.initState();
    team = Map<String, dynamic>.from(widget.team);
    _checkTeamLeader();
  }

  Future<void> _checkTeamLeader() async {
    final teamId = team['teamId'].toString();
    try {
      final result = await TeamService.isTeamLeader(teamId);
      if (mounted) {
        setState(() {
          isLeader = result;
        });
      }
    } catch (e) {
      print("리더 확인 중 오류: $e");
    }
  }

  String getEnumLabel<T>(String? enumName, Map<T, String> enumMap) {
    try {
      if (enumName == null) return "알 수 없음";
      final T enumValue = enumMap.keys.firstWhere(
        (e) =>
            e.toString().split('.').last.toUpperCase() ==
            enumName.toUpperCase(),
      );
      return enumMap[enumValue] ?? "알 수 없음";
    } catch (_) {
      return enumName ?? "알 수 없음";
    }
  }

  @override
  Widget build(BuildContext context) {
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
    final int totalMembers = team['totalMembers'] ?? 0;
    final List<dynamic> members = team['members'] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(teamName),
        actions:
            isLeader
                ? [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TeamFormPage(initialData: team),
                        ),
                      );
                      if (result == 'update') {
                        try {
                          final updatedTeam = await TeamService.getTeamById(
                            team['teamId'].toString(),
                          );
                          if (mounted && updatedTeam != null) {
                            setState(() {
                              team = updatedTeam;
                            });
                          }
                        } catch (e) {
                          print("팀 정보 불러오기 실패: $e");
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("팀 정보를 다시 불러오는데 실패했습니다."),
                              ),
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
                        builder:
                            (context) => AlertDialog(
                              title: const Text("삭제 확인"),
                              content: const Text("정말로 이 팀을 삭제할까요?"),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: const Text("취소"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("삭제"),
                                ),
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
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TeamProfile(team: team),
            const SizedBox(height: 24),
            _buildInfoCard(region, teamCase, age, event),
            const SizedBox(height: 24),
            // ✨ isLeader가 true일 때만 이 버튼을 렌더링합니다.
            Center(
              // 버튼을 중앙에 정렬하고 싶다면 Center로 감쌉니다.
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLeader)
                    ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => Teammatchrequestpage(
                                  teamId: team['teamId'].toString(),
                                ),
                          ),
                        );
                        // 매치 요청 페이지에서 돌아왔을 때 필요하다면 팀 정보 갱신 로직 추가
                        if (result == true || result == 'refresh') {
                          // 예시: true나 'refresh'가 돌아오면
                          try {
                            final updatedTeam = await TeamService.getTeamById(
                              team['teamId'].toString(),
                            );
                            if (mounted && updatedTeam != null) {
                              setState(() {
                                team = updatedTeam; // 팀 정보 갱신
                              });
                            }
                          } catch (e) {
                            print("팀 정보 갱신 실패: $e");
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("팀 정보 갱신에 실패했습니다."),
                                ),
                              );
                            }
                          }
                        }
                      },
                      child: Text("매치 신청 조회"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent, // 적절한 색상 지정
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(width: 10.0),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => Teammatches(
                                teamId: team['teamId'].toString(),
                              ),
                        ),
                      );
                    },
                    child: Text("일정 조회"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent, // 적절한 색상 지정
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildDescription(description, context),
            const SizedBox(height: 24),
            _buildActionButtons(members),
            const SizedBox(height: 12),
            _buildMemberList(members),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    String region,
    String teamCase,
    String age,
    String event,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text("지역: $region"), Text("유형: $teamCase")],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text("연령대: $age"), Text("종목: $event")],
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(String description, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "팀 소개",
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Text(description),
      ],
    );
  }

  Widget _buildActionButtons(List<dynamic> members) {
    final String teamId = team['teamId'] ?? '';
    final int memberCount = members.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text(
              "팀원 목록",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 6),
            Text(
              "($memberCount명)",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        if (!isLeader)
          ElevatedButton.icon(
            icon: Icon(isRequested ? Icons.cancel : Icons.group_add, size: 18),
            label: Text(isRequested ? "요청 취소하기" : "팀 가입하기"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onPressed: _handleJoinOrCancel,
          ),
        if (isLeader)
          ElevatedButton.icon(
            icon: const Icon(Icons.people_outline),
            label: const Text("신청자 목록 보기"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Teaminvitationpage(teamId: teamId),
                ),
              );

              // 변경이 발생한 경우 팀 정보를 다시 불러와 갱신
              if (result == true) {
                final updatedTeam = await TeamService.getTeamById(teamId);
                if (mounted && updatedTeam != null) {
                  setState(() {
                    team = updatedTeam;
                  });
                }
              }
            },
          ),
      ],
    );
  }

  Future<void> _handleJoinOrCancel() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(isRequested ? "취소 확인" : "가입 확인"),
            content: Text(isRequested ? "가입 요청을 취소하시겠습니까?" : "팀에 가입하시겠습니까?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("취소"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("확인"),
              ),
            ],
          ),
    );
    if (confirm == true) {
      try {
        if (isRequested) {
          await TeamInvitaionService.cancelJoinRequest(
            team['teamId'].toString(),
          );
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("가입 요청이 취소되었습니다.")));
        } else {
          await TeamInvitaionService.requestJoinTeam(team['teamId'].toString());
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("가입 요청이 전송되었습니다.")));
        }
        if (mounted) {
          setState(() {
            isRequested = !isRequested;
          });
        }
      } catch (e) {
        print("요청 처리 오류: $e");
      }
    }
  }

  Widget _buildMemberList(List<dynamic> members) {
    if (members.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Text("아직 팀원이 없습니다."),
      );
    }

    // 리더 먼저, 그 다음 일반 멤버 정렬
    final sortedMembers = List<Map<String, dynamic>>.from(members)
      ..sort((a, b) {
        final aIsLeader = a['leader'] == true ? 0 : 1;
        final bIsLeader = b['leader'] == true ? 0 : 1;
        return aIsLeader.compareTo(bIsLeader);
      });

    return Column(
      children:
          sortedMembers.map((member) {
            final name = member['name'] ?? '이름 없음';
            final isLeader = member['leader'] == true;
            return ListTile(
              leading: const Icon(Icons.person_outline),
              title: Row(
                children: [
                  Text(name),
                  if (isLeader) const SizedBox(width: 6),
                  if (isLeader)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "Leader",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
    );
  }
}
