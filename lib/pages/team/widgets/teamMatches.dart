import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 날짜 포맷팅을 위해 추가
import 'package:project/contants/api_contants.dart';
import 'package:project/utils/token_storage.dart';

class Teammatches extends StatefulWidget {
  final String teamId;
  const Teammatches({super.key, required this.teamId});

  @override
  State<Teammatches> createState() => _TeammatchesState();
}

class _TeammatchesState extends State<Teammatches> {
  Future<List<Map<String, dynamic>>>? _matchesFuture; // Future를 저장할 변수

  @override
  void initState() {
    super.initState();
    _matchesFuture = teamMatches(); // initState에서 데이터 로드 시작
  }

  // 경기 일정 조회
  Future<List<Map<String, dynamic>>> teamMatches() async {
    final dio = Dio();
    String? token = await TokenStorage.getAccessToken();

    if (token == null) {
      _showSnackBar("로그인이 필요합니다.");
      return []; // 토큰이 없으면 빈 리스트 반환
    }

    try {
      final response = await dio.get(
        "${ApiConstants.baseUrl}/matchings/team/${widget.teamId}/success",
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        print("일정 조회 성공 : ${response.data}");
        if (response.data is List) {
          return List<Map<String, dynamic>>.from(response.data);
        } else {
          // 백엔드 응답이 List가 아닐 경우 에러 처리
          print("🚨 API 응답 형식이 예상과 다릅니다: ${response.data.runtimeType}");
          _showSnackBar("경기 정보를 불러오는 데 실패했습니다.");
          return [];
        }
      } else {
        print("일정 조회 실패 : ${response.statusCode}");
        _showSnackBar("경기 정보를 불러오는 데 실패했습니다 (상태 코드: ${response.statusCode}).");
        return [];
      }
    } on DioException catch (e) {
      // Dio 에러 처리
      if (e.response != null) {
        print("DioError - 응답 데이터: ${e.response?.data}");
        print("DioError - 응답 상태: ${e.response?.statusCode}");
        _showSnackBar("서버 오류: ${e.response?.statusCode ?? '알 수 없음'}");
      } else {
        print("DioError - 요청 오류: ${e.message}");
        _showSnackBar("네트워크 오류가 발생했습니다.");
      }
      return [];
    } catch (e) {
      // 일반적인 Dart 에러 처리
      print("예상치 못한 오류: $e");
      _showSnackBar("경기 정보를 불러오는 중 예상치 못한 오류가 발생했습니다.");
      return [];
    }
  }

  // SnackBar를 표시하는 헬퍼 함수
  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("경기 일정"), centerTitle: true),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _matchesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // 로딩 중
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 50,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "데이터를 불러오는데 실패했습니다: ${snapshot.error}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _matchesFuture = teamMatches(); // 에러 발생 시 재시도
                        });
                      },
                      child: const Text("다시 시도"),
                    ),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sports_soccer_outlined,
                    color: Colors.grey,
                    size: 60,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "아직 확정된 경기 일정이 없습니다.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          } else {
            // 데이터가 있는 경우 리스트로 표시
            final matches = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final match = matches[index];
                // 날짜 포맷팅
                String formattedDate = '날짜 미정';
                try {
                  if (match['matchDate'] != null) {
                    final dateTime = DateTime.parse(match['matchDate']);
                    formattedDate = DateFormat(
                      'yyyy년 M월 d일 (E) HH:mm',
                      'ko_KR',
                    ).format(dateTime);
                  }
                } catch (e) {
                  print("날짜 파싱 오류: $e");
                }

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              // 긴 텍스트를 처리하기 위해 Expanded 추가
                              child: Text(
                                match['matchRegion'] ?? '주소 정보 없음',
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "우리 팀: ${match['teamName'] ?? '알 수 없음'}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "상대 팀: ${match['challengerTeam']['teamName'] ?? '상대팀 없음'}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      "상대 팀 레이팅 : ${match['challengerTeam']['rating']}",
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // 여기에 경기 결과 등 추가 정보가 있다면 표시
                            // 예를 들어: Text("스코어: ${match['homeScore']} - ${match['awayScore'] ?? ''}")
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
