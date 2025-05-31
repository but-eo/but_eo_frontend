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
  List<dynamic> allTeams = [];
  List<dynamic> teams = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchTeams();
  }

  Future<void> fetchTeams() async {
    if (mounted) setState(() => isLoading = true);
    try {
      final result = await TeamService.fetchTeams();
      allTeams = result;
      applyFilters();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("팀 목록을 불러오는데 실패했습니다: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void applyFilters() {
    setState(() {
      teams = allTeams.where((team) {
        final regionMatch = selectedRegion == "전체" ||
            team['region']?.toString().toUpperCase() == reverseRegionEnumMap[selectedRegion];
        final eventMatch = selectedSport == "전체" ||
            team['event']?.toString().toUpperCase() == reverseEventEnumMap[selectedSport];
        return regionMatch && eventMatch;
      }).toList();
    });
  }

  String getEnumLabel<T>(String? value, Map<T, String> enumMap) {
    if (value == null) return "알 수 없음";
    if (enumMap.containsValue(value)) return value;
    try {
      final T enumKey = enumMap.keys.firstWhere(
            (e) => e.toString().split('.').last.toUpperCase() == value.toUpperCase(),
      );
      return enumMap[enumKey] ?? "알 수 없음";
    } catch (_) {
      return "알 수 없음";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCFE5EF),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Team", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TeamFormPage()),
                    );
                    if (result == 'update') fetchTeams();
                  },
                ),
              ],
            ),
          ),
          _buildChips(),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : teams.isEmpty
                  ? const Center(child: Text("등록된 팀이 없습니다."))
                  : ListView.builder(
                itemCount: teams.length,
                padding: const EdgeInsets.all(12),
                itemBuilder: (context, index) {
                  final team = teams[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    color: const Color(0xFFF5EFFD),
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TeamDetailPage(team: team),
                          ),
                        );
                        if (result == 'update' || result == 'updated') {
                          fetchTeams();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundImage: team['teamImg'] != null && team['teamImg'].toString().isNotEmpty
                                  ? NetworkImage("${TeamService.getFullTeamImageUrl(team['teamImg'])}?v=${DateTime.now().millisecondsSinceEpoch}")
                                  : null,
                              backgroundColor: Colors.black,
                              child: team['teamImg'] == null || team['teamImg'].toString().isEmpty
                                  ? const Icon(Icons.group, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(team['teamName'] ?? '이름 없음',
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  Text(
                                    "${getEnumLabel(team['event'], eventEnumMap)} · ${getEnumLabel(team['region'], regionEnumMap)} · ${team['memberAge'] ?? '나이 미상'}대",
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.zero,
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
                    applyFilters();
                  },
                  selectedColor: Colors.white,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.grey),
                ),
              );
            }).toList(),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(top: 6, bottom: 12),
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
                    applyFilters();
                  },
                  selectedColor: Colors.white,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.grey),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}