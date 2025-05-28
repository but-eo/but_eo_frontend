import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:project/contants/api_contants.dart';
import 'package:project/pages/match/fetchMatch.dart';
import 'package:project/pages/match/matching.dart';
import 'package:project/pages/match/matching_data.dart';
import 'package:project/pages/stadium/stadiumSearchPage.dart';
import 'package:project/utils/token_storage.dart';
import 'package:project/widgets/matchingCard.dart';
import 'package:table_calendar/table_calendar.dart';

class Matchpage extends StatefulWidget {
  const Matchpage({super.key});

  @override
  State<Matchpage> createState() => _MatchpageState();
}

class _MatchpageState extends State<Matchpage> {
  final List<String> regions = ["전체", "서울", "경기", "강원", "충청", "전라", "경상", "제주"];
  final List<String> sports = [
    "전체",
    "축구",
    "야구",
    "농구",
    "테니스",
    "배드민턴",
    "탁구",
    "볼링",
  ];

  //날짜 필터링

  List<MatchingData> allMatchCards = [];
  List<MatchingData> filterMatchCards = [];

  void _onDaySelected(DateTime selectedDay, DateTime focusDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusDay;

      filterMatchCards =
          allMatchCards.where((match) {
            // 날짜만 비교 (시/분/초 제외)
            return isSameDay(match.matchDay, selectedDay);
          }).toList();
    });
  }

  Future<void> fetchMatchCards() async {
    try {
      final data = await fetchMatchCardsFromServer(); // 서버 요청 함수
      setState(() {
        allMatchCards = data;
        // 초기에는 오늘 날짜 기준 필터링
        filterMatchCards =
            data
                .where((match) => isSameDay(match.matchDay, DateTime.now()))
                .toList();
      });
    } catch (e) {
      print("에러: $e");
    }
  }

  Future<void> fetchUserTeam() async {
    final token = await TokenStorage.getAccessToken();
    final dio = Dio();
    try {
      final response = await dio.get(
        //팀 정보 불러오기(리더인지 아닌지 구별은 -> 백엔드)
        "${ApiConstants.baseUrl}/users/me",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      if (response.statusCode == 200) {
        print("로그인 유저 팀조회 성공: ${response.data}");
        //TODO
      }
    } catch (e) {}
  }

  String selectedRegion = "전체";
  String selectedSport = "전체";

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();

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

            // 🔶 지역 필터
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children:
                    regions.map((region) {
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
                          },
                          selectedColor: Colors.orange,
                        ),
                      );
                    }).toList(),
              ),
            ),

            const SizedBox(height: 10),

            // 🔷 종목 필터
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children:
                    sports.map((sport) {
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
                          },
                          selectedColor: Colors.grey[700],
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
            SizedBox(height: 10.0),
            TableCalendar(
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              firstDay: DateTime.utc(2025, 1, 1),
              lastDay: DateTime.utc(2099, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                // Use `selectedDayPredicate` to determine which day is currently selected.
                // If this returns true, then `day` will be marked as selected.

                // Using `isSameDay` is recommended to disregard
                // the time-part of compared DateTime objects.
                return isSameDay(_selectedDay, day);
              },
              calendarStyle: CalendarStyle(
                defaultTextStyle: TextStyle(
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
                outsideTextStyle: TextStyle(
                  color: const Color.fromARGB(255, 182, 182, 182),
                ),
                outsideDaysVisible: true,
              ),
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  // Call `setState()` when updating the selected day
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                }
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  // Call `setState()` when updating calendar format
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
            SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Matching()),
                    );
                    fetchMatchCards();
                    fetchUserTeam();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // 배경색을 빨간색으로 설정
                    foregroundColor: Colors.black, // 텍스트 색을 흰색으로 설정
                  ).copyWith(
                    side: WidgetStateProperty.all(
                      //테두리
                      BorderSide(color: Colors.black, width: 1),
                    ),
                  ),
                  child: Text("매칭 등록", style: TextStyle(fontSize: 18)),
                ),
                SizedBox(width: 10.0),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // 배경색을 빨간색으로 설정
                    foregroundColor: Colors.black, // 텍스트 색을 흰색으로 설정
                  ).copyWith(
                    side: WidgetStateProperty.all(
                      //테두리
                      BorderSide(color: Colors.black, width: 1),
                    ),
                  ),
                  child: Text("자동 매칭", style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
            SizedBox(height: 30.0),
            ElevatedButton(
                onPressed: ()  {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const StadiumSearchPage()),
                  );
            },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                ),
                child: Text("경기장 찾기")),
            SizedBox(height: 10.0),
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
                      teamImage: data.teamImage,
                      teamName: data.teamName,
                      rating: data.rating,
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
}
//TODO: 팀 조회해서 매칭 등록 요청을 읽어서 -> 매칭카드 생성