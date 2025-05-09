import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:project/contants/api_contants.dart';
import 'package:project/http/teamService.dart';
import 'package:project/pages/team/createTeamPage.dart';
import 'package:project/data/teamEnum.dart';
import 'package:project/pages/team/teamDetailPage.dart';

class TeamSearchPage extends StatefulWidget {
  const TeamSearchPage({super.key});

  @override
  State<TeamSearchPage> createState() => TeamSearchPageState();
}

class TeamSearchPageState extends State<TeamSearchPage> {

  //역 매핑 서버는 영어로 받아서 변환
  final Map<String, String> reverseRegionEnumMap = {
    for (var entry in regionEnumMap.entries) entry.value: entry.key.name.toUpperCase(),
  };
  final Map<String, String> reverseEventEnumMap = {
    for (var entry in eventEnumMap.entries) entry.value: entry.key.name.toUpperCase(),
  };

  //지역, 종목 상태 저장용
  final List<String> regions = ["전체", ...regionEnumMap.values];
  final List<String> sports = ["전체", ...eventEnumMap.values];

  String selectedRegion = "전체";
  String selectedSport = "전체";
  List<dynamic> teams = [];
  bool isLoading = false;

  // 팀 목록 받아옴
  @override
  void initState() {
    super.initState();
    fetchTeams();
  }

  Future<void> fetchTeams() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await TeamService.fetchTeams(
        region: selectedRegion != "전체" ? reverseRegionEnumMap[selectedRegion] : null,
        event: selectedSport != "전체" ? reverseEventEnumMap[selectedSport] : null,
      );
      setState(() {
        teams = result;
      });
    } catch (e) {
      print("팀 조회 실패: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

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
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 16),
          const Text("전체 팀", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Divider(),

          // 지역 필터
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: regions.map((region) {
                final isSelected = region == selectedRegion;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: ChoiceChip(
                    label: Text(region),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        selectedRegion = region;
                      });
                      fetchTeams();
                    },
                    selectedColor: Colors.orange,
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 10),

          // 종목 필터
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: sports.map((sport) {
                final isSelected = sport == selectedSport;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: ChoiceChip(
                    label: Text(sport),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        selectedSport = sport;
                      });
                      fetchTeams();
                    },
                    selectedColor: Colors.grey[700],
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          //  테이블 헤더
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("팀명", style: TextStyle(fontWeight: FontWeight.bold)),
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateTeamPage()),
                    );

                    if (result == true) {
                      fetchTeams();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(10),
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 팀 리스트
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : teams.isEmpty
                ? const Center(child: Text("등록된 팀이 없습니다."))
                : ListView.builder(
              itemCount: teams.length,
              itemBuilder: (context, index) {
                final team = teams[index];

                print("팀명: ${team['teamName']}, 이미지 URL: https://your-server-url.com${team['teamImg']}");

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: team['teamImg'] != null && team['teamImg'] != ''
                        ? NetworkImage("${ApiConstants.baseUrl}/images/team/${team['teamImg']}")
                        : const AssetImage('assets/images/butteoLogo.png') as ImageProvider,
                  ),

                  title: Text(team['teamName'] ?? '이름 없음'),
                  subtitle: Text(
                    "${getEnumLabel(team['event'], eventEnumMap)} · "
                        "${getEnumLabel(team['region'], regionEnumMap)} · "
                        "${team['memberAge'] ?? '나이 미상'}대",
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder : (_) => TeamDetailPage(team: team),
                        ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
