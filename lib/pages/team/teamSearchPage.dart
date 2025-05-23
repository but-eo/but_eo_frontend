import 'package:flutter/material.dart';
import 'package:project/pages/team/teamFormPage.dart';
import 'package:project/service/teamService.dart';
import 'package:project/data/teamEnum.dart';
import 'package:project/pages/team/teamDetailPage.dart';

class TeamSearchPage extends StatefulWidget {
  const TeamSearchPage({super.key});

  @override
  State<TeamSearchPage> createState() => TeamSearchPageState();
}

class TeamSearchPageState extends State<TeamSearchPage> {
  final Map<String, String> reverseRegionEnumMap = {
    for (var entry in regionEnumMap.entries) entry.value: entry.key.name.toUpperCase(),
  };
  final Map<String, String> reverseEventEnumMap = {
    for (var entry in eventEnumMap.entries) entry.value: entry.key.name.toUpperCase(),
  };

  final List<String> regions = ["전체", ...regionEnumMap.values];
  final List<String> sports = ["전체", ...eventEnumMap.values];

  String selectedRegion = "전체";
  String selectedSport = "전체";
  List<dynamic> teams = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchTeams();
  }

  Future<void> fetchTeams() async {
    setState(() => isLoading = true);
    try {
      final result = await TeamService.fetchTeams(
        region: selectedRegion != "전체" ? reverseRegionEnumMap[selectedRegion] : null,
        event: selectedSport != "전체" ? reverseEventEnumMap[selectedSport] : null,
      );
      setState(() => teams = result);
    } catch (e) {
      print("팀 조회 실패: $e");
    } finally {
      setState(() => isLoading = false);
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
                      setState(() => selectedRegion = region);
                      fetchTeams();
                    },
                    selectedColor: Colors.orange,
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 10),

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
                      setState(() => selectedSport = sport);
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
                      MaterialPageRoute(
                        builder: (_) => const TeamFormPage(),
                      ),
                    );
                    if (result == 'updated') fetchTeams();
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

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : teams.isEmpty
                ? const Center(child: Text("등록된 팀이 없습니다."))
                : ListView.builder(
              itemCount: teams.length,
              itemBuilder: (context, index) {
                final team = teams[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: team['teamImg'] != null && team['teamImg'] != ''
                        ? NetworkImage(TeamService.getFullTeamImageUrl(team['teamImg']) + "?t=${DateTime.now().millisecondsSinceEpoch}")
                        : null,
                    backgroundColor: Colors.grey,
                    child: team['teamImg'] == null || team['teamImg'] == ''
                        ? const Icon(Icons.group, color: Colors.white)
                        : null,
                  ),
                  title: Text(team['teamName'] ?? '이름 없음'),
                  subtitle: Text(
                    "${getEnumLabel(team['event'], eventEnumMap)} · "
                        "${getEnumLabel(team['region'], regionEnumMap)} · "
                        "${team['memberAge'] ?? '나이 미상'}대",
                  ),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TeamDetailPage(team: team),
                      ),
                    );
                    if (result == 'updated') fetchTeams();
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
