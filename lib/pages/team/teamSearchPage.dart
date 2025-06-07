import 'package:flutter/material.dart';
import 'package:project/appStyle/app_colors.dart';
import 'package:project/pages/components/reusable_filter.dart';
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
    for (var entry in regionEnumMap.entries)
      entry.value: entry.key.name.toUpperCase(),
  };
  final Map<String, String> reverseEventEnumMap = {
    for (var entry in eventEnumMap.entries)
      entry.value: entry.key.name.toUpperCase(),
  };

  final List<String> regions = ["전체", ...regionEnumMap.values];
  final List<String> sports = ["전체", ...eventEnumMap.values];

  String _selectedRegionApiValue = "전체";
  String _selectedSportApiValue = "전체";

  List<dynamic> _allTeams = [];
  List<dynamic> _filteredTeams = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTeamsInitial();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchTeamsInitial() async {
    await _fetchTeams();
  }

  Future<void> _fetchTeams({String? teamNameQuery}) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final result = await TeamService.fetchTeams(
        region: _selectedRegionApiValue == "전체" ? null : reverseRegionEnumMap[_selectedRegionApiValue],
        event: _selectedSportApiValue == "전체" ? null : reverseEventEnumMap[_selectedSportApiValue],
        teamName: teamNameQuery?.isNotEmpty == true ? teamNameQuery : null,
      );
      if (mounted) {
        setState(() {
          _allTeams = result;
          _applyFiltersAndSearch(teamNameQuery ?? _searchController.text.trim());
        });
      }
    } catch (e) {
      print("팀 조회 실패: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("팀 목록을 불러오는데 실패했습니다: \${e.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFiltersAndSearch(String searchQuery) {
    List<dynamic> tempFiltered = List.from(_allTeams);
    setState(() {
      _filteredTeams = tempFiltered;
    });
  }

  void _showFilterModal(BuildContext context) {
    ReusableFilter.show(
      context: context,
      regions: regions,
      sports: sports,
      selectedRegion: _selectedRegionApiValue,
      selectedSport: _selectedSportApiValue,
      onApply: (region, sport) {
        setState(() {
          _selectedRegionApiValue = region;
          _selectedSportApiValue = sport;
        });
        _fetchTeams(teamNameQuery: _searchController.text.trim());
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        title: Text('팀 찾기', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.baseWhiteColor,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        elevation: 0.8,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list_rounded, color: AppColors.textPrimary),
            tooltip: "필터",
            onPressed: () => _showFilterModal(context),
          ),
          Tooltip(
            message: "새 팀 만들기",
            child: IconButton(
              icon: Icon(Icons.add_circle_outline, color: AppColors.brandBlue, size: 28),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TeamFormPage()),
                );
                if (result == 'update' || result == true) {
                  _fetchTeams(teamNameQuery: _searchController.text.trim());
                }
              },
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
            color: AppColors.baseWhiteColor, // Consistent with AppBar background
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                  hintText: '팀 이름으로 검색...',
                  hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.7)),
                  prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondary.withOpacity(0.9)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear_rounded, color: AppColors.textSecondary.withOpacity(0.7)),
                    onPressed: () {
                      _searchController.clear();
                      _fetchTeams();
                    },
                  )
                      : null,
                  filled: true,
                  fillColor: AppColors.lightGrey.withOpacity(0.8), // Search bar fill
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15)
              ),
              onSubmitted: (value) => _fetchTeams(teamNameQuery: value.trim()),
            ),
          ),
          _buildAppliedFiltersRow(),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: AppColors.brandBlue))
                : _filteredTeams.isEmpty
                ? _buildEmptyTeamList()
                : RefreshIndicator(
              onRefresh: () => _fetchTeams(teamNameQuery: _searchController.text.trim()),
              color: AppColors.brandBlue,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                itemCount: _filteredTeams.length,
                itemBuilder: (context, index) {
                  final team = _filteredTeams[index];
                  return _buildTeamListItem(team);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppliedFiltersRow() {
    bool hasRegionFilter = _selectedRegionApiValue != "전체";
    bool hasSportFilter = _selectedSportApiValue != "전체";

    if (!hasRegionFilter && !hasSportFilter) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: AppColors.lightGrey, // Background for this row
      child: Row(
        children: [
          Text("적용된 필터: ", style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          if (hasRegionFilter)
            Chip(
              label: Text(_selectedRegionApiValue, style: const TextStyle(fontSize: 11, color: AppColors.baseBlackColor)),
              backgroundColor: AppColors.baseWhiteColor,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                setState(() {
                  _selectedRegionApiValue = "전체";
                });
                _fetchTeams(teamNameQuery: _searchController.text.trim());
              },
            ),

          if (hasRegionFilter && hasSportFilter) const SizedBox(width: 6),
          if (hasSportFilter)
            Chip(
              label: Text(_selectedSportApiValue, style: const TextStyle(fontSize: 11, color: AppColors.baseBlackColor)),
              backgroundColor: AppColors.baseWhiteColor,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                setState(() {
                  _selectedSportApiValue = "전체";
                });
                _fetchTeams(teamNameQuery: _searchController.text.trim());
              },
            ),

        ],
      ),
    );
  }

  Widget _buildTeamListItem(Map<String, dynamic> team) {
    final String teamName = team['teamName'] ?? '이름 없음';
    final String? teamPath = team['teamImg'];
    String? teamImageUrl;
    if (teamPath != null && teamPath.isNotEmpty) {
      teamImageUrl = TeamService.getFullTeamImageUrl(teamPath);
    }
    final String teamEvent = TeamService.getEventLabel(team['event']) ?? '종목 미정';
    final String teamRegion = TeamService.getRegionLabel(team['region']) ?? '지역 미정';
    final String memberAge = team['memberAge'] != null ? "${team['memberAge']}대" : "연령 미정";
    final int rating = team['rating'] ?? 1000;
    final String description = team['teamDescription'] ?? '팀 소개가 없습니다.';
    final int totalMembers = team['totalMembers'] ?? 0;

    return Card(
      color: AppColors.baseWhiteColor,
      margin: const EdgeInsets.only(bottom: 14.0),
      elevation: 2.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TeamDetailPage(team: Map<String, dynamic>.from(team)),
            ),
          );
          if (result == 'update' || result == 'updated' || result == 'deleted' || result == 'left') {
            _fetchTeams(teamNameQuery: _searchController.text.trim());
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.lightGrey,
                    backgroundImage: teamImageUrl != null ? NetworkImage("$teamImageUrl?v=${DateTime.now().millisecondsSinceEpoch}") : null,
                    child: teamImageUrl == null ? Icon(Icons.shield_outlined, color: AppColors.textSecondary.withOpacity(0.7), size: 30) : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          teamName,
                          style: TextStyle(fontSize: 17.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.sports_soccer, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(teamEvent, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                            Text(" • ", style: TextStyle(color: AppColors.textSubtle, fontSize: 13)),
                            Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 2),
                            Text(teamRegion, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.cake_outlined, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(memberAge, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                            Text(" • ", style: TextStyle(color: AppColors.textSubtle, fontSize: 13)),
                            Icon(Icons.star_outline_rounded, color: Colors.orange.shade600, size: 15), // Kept orange as it's specific
                            const SizedBox(width: 2),
                            Text(
                              "$rating 점",
                              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                            ),
                            Text(" • ", style: TextStyle(color: AppColors.textSubtle, fontSize: 13)),
                            Icon(Icons.group_outlined, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 2),
                            Text(
                              "$totalMembers명",
                              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 18, color: AppColors.textSubtle), // Arrow color
                ],
              ),
              if (description.isNotEmpty) ...[
                const Divider(height: 24, thickness: 0.5),
                Text(
                  description,
                  style: TextStyle(color: AppColors.textSecondary.withOpacity(0.9), fontSize: 13, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyTeamList() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sentiment_dissatisfied_outlined, size: 70, color: AppColors.textSecondary.withOpacity(0.5)),
            const SizedBox(height: 20),
            Text("앗, 조건에 맞는 팀이 없어요!", style: TextStyle(fontSize: 17, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Text(
              "다른 검색어나 필터를 사용해보시거나\n아래 버튼으로 새로운 팀을 만들어보세요!",
              style: TextStyle(color: AppColors.textSecondary, height: 1.5, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.baseWhiteColor),
              label: const Text("새로운 팀 만들기", style: TextStyle(color: AppColors.baseWhiteColor, fontWeight: FontWeight.bold)),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TeamFormPage()),
                );
                if (result == 'update' || result == true) {
                  _fetchTeams(teamNameQuery: _searchController.text.trim());
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)
              ),
            ),
          ],
        ),
      ),
    );
  }
}