import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:project/contants/api_contants.dart';
import 'package:project/data/teamEnum.dart';
import 'package:project/pages/components/reusable_filter.dart';
import 'package:project/pages/match/fetchMatch.dart';
import 'package:project/pages/match/matching.dart';
import 'package:project/pages/match/matching_data.dart';
import 'package:project/pages/stadium/stadiumSearchPage.dart';
import 'package:project/utils/token_storage.dart';
import 'package:project/widgets/matchingCard.dart';
import 'package:table_calendar/table_calendar.dart';

class Matchpage extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const Matchpage({super.key, this.initialData});

  @override
  State<Matchpage> createState() => _MatchpageState();
}

class _MatchpageState extends State<Matchpage> {
  late Future<List<MatchingData>> _matchDataFuture;
  List<MatchingData> allMatchCards = [];
  List<MatchingData> filterMatchCards = [];
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final List<String> regions = ["전체", ...regionEnumMap.values];
  final List<String> sports = ["전체", ...eventEnumMap.values];
  String selectedRegion = "전체";
  String selectedSport = "전체";

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    fetchMatchCards();
  }

  T? enumFromBackend<T>(String? value, List<T> enumValues) {
    if (value == null) return null;
    return enumValues.firstWhere(
          (e) => e.toString().split('.').last.toUpperCase() == value.toUpperCase(),
      orElse: () => enumValues.first,
    );
  }

  void applyFilters() {
    setState(() {
      filterMatchCards = allMatchCards.where((match) {
        final matchesDate =
            _selectedDay == null || isSameDay(match.matchDay, _selectedDay!);
        final matchesRegion =
            selectedRegion == "전체" ||
                regionEnumMap[match.teamRegion] == selectedRegion;
        final matchesSport =
            selectedSport == "전체" || match.matchType == selectedSport;

        return matchesDate && matchesRegion && matchesSport;
      }).toList();
    });
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
        filterMatchCards = data.where((match) => isSameDay(match.matchDay, DateTime.now())).toList();
        applyFilters();
      });
    } catch (e) {
      print("에러: $e");
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              "매칭 보기",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),

            // ReusableFilter(
            //   options: regions,
            //   selectedOption: selectedRegion,
            //   onSelected: (region) {
            //     setState(() => selectedRegion = region);
            //     applyFilters();
            //   },
            // ),
            // const SizedBox(height: 6),
            // ReusableFilter(
            //   options: sports,
            //   selectedOption: selectedSport,
            //   onSelected: (sport) {
            //     setState(() => selectedSport = sport);
            //     applyFilters();
            //   },
            // ),

            const SizedBox(height: 10.0),

            TableCalendar(
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              firstDay: DateTime.utc(2025, 1, 1),
              lastDay: DateTime.utc(2099, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarStyle: CalendarStyle(
                defaultTextStyle: TextStyle(color: Colors.black),
                outsideTextStyle: TextStyle(color: Colors.grey),
                outsideDaysVisible: true,
              ),
              onDaySelected: _onDaySelected,
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() => _calendarFormat = format);
                }
              },
              onPageChanged: (focusedDay) => _focusedDay = focusedDay,
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
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ).copyWith(
                    side: WidgetStateProperty.all(
                      BorderSide(color: Colors.black, width: 1),
                    ),
                  ),
                  child: const Text("매칭 등록", style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 10.0),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ).copyWith(
                    side: WidgetStateProperty.all(
                      BorderSide(color: Colors.black, width: 1),
                    ),
                  ),
                  child: const Text("자동 매칭", style: TextStyle(fontSize: 18)),
                ),
              ],
            ),

            const SizedBox(height: 30.0),

            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StadiumSearchPage(),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: const Text("경기장 찾기"),
            ),

            const SizedBox(height: 10.0),

            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: filterMatchCards.length,
              itemBuilder: (context, index) {
                final data = filterMatchCards[index];
                return Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(top: index == 0 ? 0 : 16.0),
                    child: Matchingcard(
                      teamImg: data.teamImage,
                      teamName: data.teamName,
                      rating: data.rating,
                      region: getShortRegion(data.matchRegion),
                      matchDay: data.matchDay,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} // TODO: 팀 조회해서 매칭 등록 요청을 읽어서 -> 매칭카드 생성
