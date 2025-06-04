// lib/pages/team/teamSearchPage.dart
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
  // 색상 정의
  final Color _scaffoldBgColor = Colors.grey.shade50;
  final Color _cardBgColor = Colors.white;
  final Color _appBarBgColor = Colors.white; // ✅ 누락되었던 변수 추가
  final Color _primaryTextColor = Colors.black87;
  final Color _secondaryTextColor = Colors.grey.shade600;
  final Color _accentColor = Colors.blue.shade700;
  final Color _chipBackgroundColor = Colors.grey.shade100;
  final Color _chipSelectedColor = Colors.blue.shade700;
  final Color _chipLabelSelectedColor = Colors.white;
  final Color _chipLabelUnselectedColor = Colors.black54; // 이전 코드에서는 _primaryTextColor.withOpacity(0.8) 였음, 명확한 색상으로 변경

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
  bool _isLoading = true; // ✅ 누락되었던 상태 변수 추가 (초기값 true로 설정)
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
    await _fetchTeams(); // 초기 로드
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
          // API가 이미 필터링된 결과를 반환한다고 가정, 검색어가 있다면 해당 검색어 기준으로 필터링
          _applyFiltersAndSearch(teamNameQuery ?? _searchController.text.trim());
        });
      }
    } catch (e) {
      print("팀 조회 실패: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("팀 목록을 불러오는데 실패했습니다: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFiltersAndSearch(String searchQuery) {
    List<dynamic> tempFiltered = List.from(_allTeams);
    // 이름 검색은 API에서 이미 처리되었으므로, 여기서는 추가적인 클라이언트 필터링이 필요하다면 로직 추가
    // 현재는 API가 모든 필터링과 검색을 처리한다고 가정하고, 받은 allTeams를 그대로 filteredTeams에 할당
    // 만약 클라이언트 측 검색이 필요하다면 아래 주석 해제
    // if (searchQuery.isNotEmpty) {
    //   tempFiltered = tempFiltered.where((team) {
    //     final teamName = team['teamName'] as String?;
    //     return teamName?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false;
    //   }).toList();
    // }
    setState(() {
      _filteredTeams = tempFiltered;
    });
  }

  void _showFilterModal(BuildContext context) {
    String tempSelectedRegion = _selectedRegionApiValue;
    String tempSelectedSport = _selectedSportApiValue;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter modalSetState) {
              return Container(
                padding: const EdgeInsets.all(20),
                height: MediaQuery.of(context).size.height * 0.6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("필터 설정", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryTextColor)),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const Divider(height: 24),
                    Text("지역 선택", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _secondaryTextColor)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: regions.map((region) {
                        return ChoiceChip(
                          label: Text(region, style: TextStyle(fontSize: 13, color: tempSelectedRegion == region ? _chipLabelSelectedColor : _primaryTextColor.withOpacity(0.8))),
                          selected: tempSelectedRegion == region,
                          onSelected: (selected) {
                            modalSetState(() => tempSelectedRegion = region);
                          },
                          selectedColor: _chipSelectedColor,
                          backgroundColor: _chipBackgroundColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: tempSelectedRegion == region ? _chipSelectedColor : Colors.grey.shade300)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Text("종목 선택", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _secondaryTextColor)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: sports.map((sport) {
                        return ChoiceChip(
                          label: Text(sport, style: TextStyle(fontSize: 13, color: tempSelectedSport == sport ? _chipLabelSelectedColor : _primaryTextColor.withOpacity(0.8))),
                          selected: tempSelectedSport == sport,
                          onSelected: (selected) {
                            modalSetState(() => tempSelectedSport = sport);
                          },
                          selectedColor: _chipSelectedColor,
                          backgroundColor: _chipBackgroundColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: tempSelectedSport == sport ? _chipSelectedColor : Colors.grey.shade300)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        );
                      }).toList(),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedRegionApiValue = tempSelectedRegion;
                            _selectedSportApiValue = tempSelectedSport;
                          });
                          _fetchTeams(teamNameQuery: _searchController.text.trim()); // ✅ _fetchTeams로 수정
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: _accentColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                        ),
                        child: const Text("필터 적용", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffoldBgColor,
      appBar: AppBar(
        title: Text('팀 찾기', style: TextStyle(color: _primaryTextColor, fontWeight: FontWeight.bold)),
        backgroundColor: _appBarBgColor, // ✅ 로컬 변수 사용
        iconTheme: IconThemeData(color: _primaryTextColor),
        elevation: 0.8,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list_rounded, color: _primaryTextColor),
            tooltip: "필터",
            onPressed: () => _showFilterModal(context),
          ),
          Tooltip(
            message: "새 팀 만들기",
            child: IconButton(
              icon: Icon(Icons.add_circle_outline, color: _accentColor, size: 28),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TeamFormPage()),
                );
                if (result == 'update' || result == true) {
                  _fetchTeams(teamNameQuery: _searchController.text.trim()); // ✅ _fetchTeams로 수정
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
            color: _appBarBgColor, // ✅ 로컬 변수 사용
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                  hintText: '팀 이름으로 검색...',
                  hintStyle: TextStyle(color: _secondaryTextColor.withOpacity(0.7)),
                  prefixIcon: Icon(Icons.search_rounded, color: _secondaryTextColor.withOpacity(0.9)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear_rounded, color: _secondaryTextColor.withOpacity(0.7)),
                    onPressed: () {
                      _searchController.clear();
                      _fetchTeams(); // ✅ _fetchTeams로 수정
                    },
                  )
                      : null,
                  filled: true,
                  fillColor: _scaffoldBgColor.withOpacity(0.8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15)
              ),
              onSubmitted: (value) => _fetchTeams(teamNameQuery: value.trim()), // ✅ _fetchTeams로 수정
            ),
          ),
          _buildAppliedFiltersRow(),
          Expanded(
            child: _isLoading // ✅ 로컬 변수 사용
                ? Center(child: CircularProgressIndicator(color: _accentColor))
                : _filteredTeams.isEmpty
                ? _buildEmptyTeamList()
                : RefreshIndicator(
              onRefresh: () => _fetchTeams(teamNameQuery: _searchController.text.trim()), // ✅ _fetchTeams로 수정
              color: _accentColor,
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
      color: _scaffoldBgColor,
      child: Row(
        children: [
          Text("적용된 필터: ", style: TextStyle(fontSize: 12, color: _secondaryTextColor, fontWeight: FontWeight.w500)),
          if (hasRegionFilter)
            Chip(
              label: Text(_selectedRegionApiValue, style: const TextStyle(fontSize: 11)),
              backgroundColor: _chipBackgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          if (hasRegionFilter && hasSportFilter) const SizedBox(width: 6),
          if (hasSportFilter)
            Chip(
              label: Text(_selectedSportApiValue, style: const TextStyle(fontSize: 11)),
              backgroundColor: _chipBackgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
      color: _cardBgColor,
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
            _fetchTeams(teamNameQuery: _searchController.text.trim()); // ✅ _fetchTeams로 수정
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
                    backgroundColor: _scaffoldBgColor,
                    backgroundImage: teamImageUrl != null ? NetworkImage("$teamImageUrl?v=${DateTime.now().millisecondsSinceEpoch}") : null,
                    child: teamImageUrl == null ? Icon(Icons.shield_outlined, color: _secondaryTextColor.withOpacity(0.7), size: 30) : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          teamName,
                          style: TextStyle(fontSize: 17.5, fontWeight: FontWeight.bold, color: _primaryTextColor),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.sports_soccer, size: 14, color: _secondaryTextColor),
                            const SizedBox(width: 4),
                            Text(teamEvent, style: TextStyle(color: _secondaryTextColor, fontSize: 13)),
                            Text(" • ", style: TextStyle(color: Colors.grey.shade400, fontSize: 13)), // 구분자 색상 변경
                            Icon(Icons.location_on_outlined, size: 14, color: _secondaryTextColor),
                            const SizedBox(width: 2),
                            Text(teamRegion, style: TextStyle(color: _secondaryTextColor, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.cake_outlined, size: 14, color: _secondaryTextColor),
                            const SizedBox(width: 4),
                            Text(memberAge, style: TextStyle(color: _secondaryTextColor, fontSize: 13)),
                            Text(" • ", style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                            Icon(Icons.star_outline_rounded, color: Colors.orange.shade600, size: 15),
                            const SizedBox(width: 2),
                            Text(
                              "$rating 점",
                              style: TextStyle(fontSize: 13, color: _secondaryTextColor, fontWeight: FontWeight.w500),
                            ),
                            Text(" • ", style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                            Icon(Icons.group_outlined, size: 14, color: _secondaryTextColor),
                            const SizedBox(width: 2),
                            Text(
                              "$totalMembers명",
                              style: TextStyle(fontSize: 13, color: _secondaryTextColor, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey.shade400),
                ],
              ),
              if (description.isNotEmpty) ...[
                const Divider(height: 24, thickness: 0.5),
                Text(
                  description,
                  style: TextStyle(color: _secondaryTextColor.withOpacity(0.9), fontSize: 13, height: 1.4),
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
            Icon(Icons.sentiment_dissatisfied_outlined, size: 70, color: _secondaryTextColor.withOpacity(0.5)),
            const SizedBox(height: 20),
            Text("앗, 조건에 맞는 팀이 없어요!", style: TextStyle(fontSize: 17, color: _primaryTextColor, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Text(
              "다른 검색어나 필터를 사용해보시거나\n아래 버튼으로 새로운 팀을 만들어보세요!",
              style: TextStyle(color: _secondaryTextColor, height: 1.5, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white),
              label: const Text("새로운 팀 만들기", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TeamFormPage()),
                );
                if (result == 'update' || result == true) {
                  _fetchTeams(teamNameQuery: _searchController.text.trim()); // ✅ _fetchTeams로 수정
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: _accentColor,
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