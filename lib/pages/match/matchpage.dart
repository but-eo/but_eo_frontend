import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:project/contants/api_contants.dart';
import 'package:project/data/teamEnum.dart';
import 'package:project/pages/match/fetchMatch.dart';
import 'package:project/pages/match/matching.dart';
import 'package:project/pages/match/matching_data.dart';
import 'package:project/pages/match/matching_detail.dart';
import 'package:project/pages/stadium/stadiumSearchPage.dart';
import 'package:project/utils/token_storage.dart';
import 'package:project/widgets/matchingCard.dart';
import 'package:project/widgets/scroll_to_top_button.dart';
import 'package:table_calendar/table_calendar.dart';

class Matchpage extends StatefulWidget {
  final List<Map<String, dynamic>>? leaderTeam;
  const Matchpage({super.key, required this.leaderTeam});

  @override
  State<Matchpage> createState() => _MatchpageState();
}

class _MatchpageState extends State<Matchpage> {
  final Color _scaffoldBgColor = Colors.grey.shade50;
  final Color _cardBgColor = Colors.white;
  final Color _appBarBgColor = Colors.white;
  final Color _primaryTextColor = Colors.black87;
  final Color _secondaryTextColor = Colors.grey.shade600;
  final Color _accentColor = Colors.blue.shade700;
  final Color _chipBackgroundColor = Colors.grey.shade100;
  final Color _chipSelectedColor = Colors.blue.shade700;
  final Color _chipLabelSelectedColor = Colors.white;
  final Color _chipLabelUnselectedColor = Colors.black54;

  List<Map<String, dynamic>> teamSports = [];
  String? selectedTeam;

  late Future<List<MatchingData>> _matchDataFuture;
  List<MatchingData> allMatchCards = [];
  List<MatchingData> filterMatchCards = [];
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final Map<DateTime, List<MatchingData>> _events = {};

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final List<String> regions = ["전체", ...regionEnumMap.values];
  final List<String> sports = ["전체", ...eventEnumMap.values];
  String selectedRegion = "전체";
  String selectedSport = "전체";

  final ScrollController _scrollController = ScrollController();
  bool _showButton = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();

    _scrollController.addListener(() {
      if (_scrollController.offset > 50) {
        if (!_showButton) {
          setState(() => _showButton = true);
        }
      } else {
        if (_showButton) {
          setState(() => _showButton = false);
        }
      }
    });

    fetchMatchCards();
    fetchUserTeam().then((data) {
      setState(() {
        teamSports = data;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void applyFilters() {
    setState(() {
      filterMatchCards =
          allMatchCards.where((match) {
            final matchesDate =
                _selectedDay == null ||
                isSameDay(match.matchDay, _selectedDay!);
            final matchesRegion =
                selectedRegion == "전체" ||
                regionEnumMap[match.teamRegion] == selectedRegion;
            final matchesSport =
                selectedSport == "전체" || match.matchType == selectedSport;

            return matchesDate && matchesRegion && matchesSport;
          }).toList();
    });
  }

  void _showFilterModal(BuildContext context) {
    String tempSelectedRegion = selectedRegion;
    String tempSelectedSport = selectedSport;

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
                      Text(
                        "필터 설정",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _primaryTextColor,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Text(
                    "지역 선택",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children:
                        regions.map((region) {
                          return ChoiceChip(
                            label: Text(
                              region,
                              style: TextStyle(
                                fontSize: 13,
                                color:
                                    tempSelectedRegion == region
                                        ? _chipLabelSelectedColor
                                        : _primaryTextColor.withOpacity(0.8),
                              ),
                            ),
                            selected: tempSelectedRegion == region,
                            onSelected:
                                (selected) => modalSetState(
                                  () => tempSelectedRegion = region,
                                ),
                            selectedColor: _chipSelectedColor,
                            backgroundColor: _chipBackgroundColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color:
                                    tempSelectedRegion == region
                                        ? _chipSelectedColor
                                        : Colors.grey.shade300,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "종목 선택",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children:
                        sports.map((sport) {
                          return ChoiceChip(
                            label: Text(
                              sport,
                              style: TextStyle(
                                fontSize: 13,
                                color:
                                    tempSelectedSport == sport
                                        ? _chipLabelSelectedColor
                                        : _primaryTextColor.withOpacity(0.8),
                              ),
                            ),
                            selected: tempSelectedSport == sport,
                            onSelected:
                                (selected) => modalSetState(
                                  () => tempSelectedSport = sport,
                                ),
                            selectedColor: _chipSelectedColor,
                            backgroundColor: _chipBackgroundColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color:
                                    tempSelectedSport == sport
                                        ? _chipSelectedColor
                                        : Colors.grey.shade300,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                          );
                        }).toList(),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedRegion = tempSelectedRegion;
                          selectedSport = tempSelectedSport;
                        });
                        applyFilters();
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accentColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text(
                        "필터 적용",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusDay;
    });
    applyFilters();
  }

  Future<void> fetchMatchCards() async {
    try {
      final data = await fetchMatchCardsFromServer();
      setState(() {
        allMatchCards = data;
        filterMatchCards =
            data
                .where((match) => isSameDay(match.matchDay, DateTime.now()))
                .toList();
        applyFilters();
      });
      for (var match in allMatchCards) {
        final date = DateTime.utc(
          match.matchDay.year,
          match.matchDay.month,
          match.matchDay.day,
        );
        _events.putIfAbsent(date, () => []);
        _events[date]!.add(match); //해당 날짜 매칭 정보를 이벤트에 추가
      }
    } catch (e) {
      print("에러: $e");
    }
  }

  //특정 날짜의 이벤트 가져오는 헬퍼 함수
  List<MatchingData> _getEventsForDay(DateTime day) {
    final utcDay = DateTime.utc(day.year, day.month, day.day);
    return _events[utcDay] ?? [];
  }

  Future<List<Map<String, dynamic>>> fetchUserTeam() async {
    final token = await TokenStorage.getAccessToken();
    final dio = Dio();
    try {
      final response = await dio.get(
        "${ApiConstants.baseUrl}/teams/my-leader-teams",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception("서버 응답 오류: ${response.statusCode}");
      }
    } catch (e) {
      print("팀조회 실패 $e");
      throw Exception("팀 조회 실패");
    }
  }

  String getShortRegion(String fullAddress) {
    final parts = fullAddress.split(' ');
    if (parts.length >= 3) {
      return '${parts[1]} ${parts[3]} ${parts[4]}';
    }
    return fullAddress;
  }

  // _MatchpageState 클래스 내부에 추가
  Widget _buildEventMarker(int count) {
    return Container(
      width: 16.0,
      height: 16.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.green[400], // 매칭이 있는 날짜의 마커 색상 (원하는 색상으로 변경)
      ),
      alignment: Alignment.center,
      child: Text(
        '$count',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:
          _showButton
              ? ScrollToTopButton(scrollController: _scrollController)
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "매칭 찾기",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.filter_list_rounded, color: _primaryTextColor),
                tooltip: "필터",
                onPressed: () => _showFilterModal(context),
              ),
            ],
          ),
          const Divider(),
          TableCalendar(
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            firstDay: DateTime.utc(2025, 1, 1),
            lastDay: DateTime.utc(2099, 12, 31),
            locale: 'ko-KR',
            daysOfWeekHeight: 30,
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarStyle: const CalendarStyle(
              defaultTextStyle: TextStyle(color: Colors.black),
              outsideTextStyle: TextStyle(color: Colors.grey),
              outsideDaysVisible: true,
            ),
            onDaySelected: _onDaySelected,
            onPageChanged: (focusedDay) => _focusedDay = focusedDay,
            eventLoader: _getEventsForDay,

            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                if (!isSameDay(day, _selectedDay) &&
                    !isSameDay(day, DateTime.now())) {
                  return Center(
                    child: Text(
                      '${day.day}',
                      style: TextStyle(color: Colors.black, fontSize: 16.0),
                    ),
                  );
                }
                return null;
              },
              dowBuilder: (context, day) {
                switch (day.weekday) {
                  case 1:
                    return Center(child: Text('월'));
                  case 2:
                    return Center(child: Text('화'));
                  case 3:
                    return Center(child: Text('수'));
                  case 4:
                    return Center(child: Text('목'));
                  case 5:
                    return Center(child: Text('금'));
                  case 6:
                    return Center(child: Text('토'));
                  case 7:
                    return Center(
                      child: Text('일', style: TextStyle(color: Colors.red)),
                    );
                }
              },

              todayBuilder: (context, day, focuesdDay) {
                return Container(
                  margin: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
              selectedBuilder: (context, day, focusedDay) {
                return Container(
                  margin: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
              // MARK: - markerBuilder 추가 (이벤트 마커)
              markerBuilder: (context, day, events) {
                final List<MatchingData> dayMatches = _getEventsForDay(day);

                if (dayMatches.isNotEmpty) {
                  return Positioned(
                    right: 1, // 날짜 셀의 오른쪽 아래에 배치
                    bottom: 1,
                    child: _buildEventMarker(dayMatches.length), // 매칭 개수에 따른 마커
                  );
                }
                return null; // 매칭이 없으면 마커 없음
              },
            ),
          ),
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final myTeam = await fetchUserTeam();
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Matching(userTeam: myTeam),
                    ),
                  );
                  fetchMatchCards();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text("매칭 등록", style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 10.0),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text("자동 매칭", style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          ElevatedButton(
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StadiumSearchPage(),
                  ),
                ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text("경기장 찾기", style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(height: 10.0),
          Text("팀 선택", style: const TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            isExpanded: true,
            hint: const Text("팀을 선택하세요"),
            value: selectedTeam, // selectedTeam이 null이면 hint가 보임
            items:
                teamSports
                    .map((team) {
                      final teamName = team['teamName'] as String?;
                      if (teamName == null) return null;
                      return DropdownMenuItem<String>(
                        value: teamName,
                        child: Text(teamName),
                      );
                    })
                    .whereType<DropdownMenuItem<String>>()
                    .toList(), // null 제거
            onChanged: (value) {
              setState(() {
                selectedTeam = value;
              });
            },
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 10.0),
            itemCount: filterMatchCards.length,
            itemBuilder: (context, index) {
              final data = filterMatchCards[index];
              return Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.only(top: index == 0 ? 0 : 16.0),
                  child: Matchingcard(
                    matchId: data.matchId,
                    teamImg: data.teamImage,
                    teamName: data.teamName,
                    rating: data.rating,
                    region: getShortRegion(data.matchRegion),
                    matchDay: data.matchDay,
                    onTap: () {
                      if (selectedTeam == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("팀을 선택해주세요.")),
                        );
                        return;
                      }
                      final teamData = teamSports.firstWhere(
                        (team) => team['teamName'] == selectedTeam,
                        orElse: () => <String, dynamic>{}, // 명시적 Map 타입
                      );

                      // 여기서 selectedTeamId를 추출합니다.
                      final String? selectedTeamId =
                          teamData['teamId'] as String?; // <<< 이 부분

                      if (selectedTeamId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("선택된 팀의 ID를 찾을 수 없습니다."),
                          ),
                        );
                        return;
                      }

                      final selectedEvent = teamData['event'];
                      final matchEvent = data.matchType;
                      if (selectedTeam == data.teamName) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("자기 팀과는 매칭할 수 없습니다.")),
                        );
                        return;
                      }
                      if (selectedEvent == matchEvent) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => MatchingDetailPage(
                                  matchId: data.matchId,
                                  challengerTeamId:
                                      selectedTeamId, // <<< 여기에 전달!
                                ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("종목이 일치하지 않습니다")),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}