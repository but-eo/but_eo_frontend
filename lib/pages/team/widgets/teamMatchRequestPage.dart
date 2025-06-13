import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:project/contants/api_contants.dart';
import 'package:project/utils/token_storage.dart';

class Teammatchrequestpage extends StatefulWidget {
  final String teamId;
  const Teammatchrequestpage({super.key, required this.teamId});

  @override
  State<Teammatchrequestpage> createState() => _TeammatchrequestpageState();
}

class _TeammatchrequestpageState extends State<Teammatchrequestpage> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> matchRequests = []; // ✨ 변수명 변경

  @override
  void initState() {
    super.initState();
    fetchMatchRequests(); // 함수명도 변경
    print("Team ID: ${widget.teamId}");
  }

  Future<void> fetchMatchRequests() async { // ✨ 함수명 변경
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final dio = Dio(
      BaseOptions(
        connectTimeout: Duration(seconds: 5),
        receiveTimeout: Duration(seconds: 3),
      ),
    );
    String? token = await TokenStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = "로그인 정보가 없거나 유효하지 않습니다.";
        print("fetchMatchRequests - 로그인 정보가 유효하지 않습니다.");
      });
      return;
    }
    try {
      final response = await dio.get(
        "${ApiConstants.baseUrl}/matchings/team/${widget.teamId}",
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        print("fetchMatchRequests - 매치 정보 조회 성공");
        if (response.data is List) {
          final List<Map<String, dynamic>> fetchedMatches =
              List<Map<String, dynamic>>.from(response.data);

          List<Map<String, dynamic>> tempMatchRequests = [];
          for (var match in fetchedMatches) {
            final List<dynamic>? challengerTeams = match['challengerTeams'];
            if (challengerTeams != null && challengerTeams.isNotEmpty) {
              for (var challengerTeam in challengerTeams) {
                tempMatchRequests.add({
                  'matchRequestId':
                      '${match['matchId'] ?? 'N/A'}_${challengerTeam['teamId'] ?? 'N/A'}',
                  'requestingTeamName':
                      challengerTeam['teamName'] ?? 'N/A', // ✨ 도전 팀의 이름을 요청 팀으로 사용
                  'requestingTeamId': challengerTeam['teamId'] ?? 'N/A',
                  'targetMatchName':
                      match['matchType'] ?? 'N/A', // 매치 종류를 대상 매치 이름으로 사용
                  'targetMatchId': match['matchId'] ?? 'N/A', // 실제 매치의 ID
                  'targetMatchDate': match['matchDate'] ?? 'N/A', // 매치 날짜
                });
              }
            }
          }

          setState(() {
            matchRequests = tempMatchRequests; // 변환된 리스트로 업데이트
            _isLoading = false;
            print("변환된 매치 요청 개수: ${matchRequests.length}");
            print("변환된 매치 요청 데이터: $matchRequests"); // 디버깅용
          });
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = "서버로부터 예상치 못한 데이터 형식입니다. (List가 아님)";
          });
          print(
              "fetchMatchRequests - 예상치 못한 데이터 형식: ${response.data.runtimeType}");
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = "서버 응답 오류 : ${response.statusCode}";
        });
        print("fetchMatchRequests - 서버 응답 오류 : ${response.statusCode}");
      }
    } on DioException catch (e) {
      setState(() {
        _isLoading = false;
        if (e.response != null) {
          _errorMessage =
              "API 오류: ${e.response!.statusCode} - ${e.response!.data}";
          print(
              "Dio Error response: ${e.response!.statusCode} - ${e.response!.data}");
        } else {
          _errorMessage = "네트워크 오류: ${e.message}";
          print("Dio Error: ${e.message}");
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "알 수 없는 오류: $e";
      });
      print("fetchMatchRequests - 알 수 없는 오류: $e");
    }
  }

  Future<void> acceptChallenge(
    String targetMatchId,
    String requestingTeamId,
  ) async {
    final dio = Dio();
    String? token = await TokenStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      _showSnackBar("로그인 정보가 없습니다. 다시 로그인해주세요.");
      return;
    }
    try {
      final response = await dio.patch(
        "${ApiConstants.baseUrl}/matchings/$targetMatchId/accept/$requestingTeamId",
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        print("매치 $targetMatchId에 대한 도전 $requestingTeamId 수락 성공");
        _showSnackBar("도전이 수락되었습니다.");
        fetchMatchRequests();
      } else {
        _showSnackBar("도전 수락 실패: ${response.statusCode}");
        print("도전 수락 실패: ${response.statusCode} - ${response.data}");
      }
    } on DioException catch (e) {
      String message = "도전 수락 중 네트워크 오류";
      if (e.response != null) {
        message = "도전 수락 실패: ${e.response!.statusCode} - ${e.response!.data}";
      }
      _showSnackBar(message);
      print("도전 수락 에러: $e");
    } catch (e) {
      _showSnackBar("도전 수락 중 알 수 없는 오류: $e");
      print("도전 수락 알 수 없는 에러: $e");
    }
  }

  Future<void> declineChallenge(
    String targetMatchId,
    String requestingTeamId,
  ) async {
    final dio = Dio();
    String? token = await TokenStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      _showSnackBar("로그인 정보가 없습니다. 다시 로그인해주세요.");
      return;
    }
    try {
      final response = await dio.delete(
        "${ApiConstants.baseUrl}/matchings/$targetMatchId/decline/$requestingTeamId",
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        print("매치 $targetMatchId에 대한 도전 $requestingTeamId 거절 성공");
        _showSnackBar("도전이 거절되었습니다.");
        fetchMatchRequests();
      } else {
        _showSnackBar("도전 거절 실패: ${response.statusCode}");
        print("도전 거절 실패: ${response.statusCode} - ${response.data}");
      }
    } on DioException catch (e) {
      String message = "도전 거절 중 네트워크 오류";
      if (e.response != null) {
        message = "도전 거절 실패: ${e.response!.statusCode} - ${e.response!.data}";
      }
      _showSnackBar(message);
      print("도전 거절 에러: $e");
    } catch (e) {
      _showSnackBar("도전 거절 중 알 수 없는 오류: $e");
      print("도전 거절 알 수 없는 에러: $e");
    }
  }

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
      appBar: AppBar(title: Text("매칭 요청 조회")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: fetchMatchRequests, // 함수명 변경
                          child: Text("다시 시도"),
                        ),
                      ],
                    ),
                  ),
                )
              : matchRequests.isEmpty
                  ? Center(child: Text("받은 매칭 요청이 없습니다."))
                  : ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: matchRequests.length, // 변수명 변경
                      itemBuilder: (context, index) {
                        final matchRequest = matchRequests[index]; // 변수명 변경

                        final String matchRequestId = matchRequest['matchRequestId'] ?? 'N/A';
                        final String requestingTeamName = matchRequest['requestingTeamName'] ?? 'N/A';
                        final String requestingTeamId = matchRequest['requestingTeamId'] ?? 'N/A';
                        final String targetMatchName = matchRequest['targetMatchName'] ?? 'N/A';
                        final String targetMatchId = matchRequest['targetMatchId'] ?? 'N/A';
                        final String targetMatchDate = matchRequest['targetMatchDate'] ?? 'N/A';

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "요청 팀: $requestingTeamName", // ✨ 도전 팀 이름이 여기에 표시됩니다.
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                                Text("대상 매치: $targetMatchName"),
                                SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        if (targetMatchId != 'N/A' &&
                                            requestingTeamId != 'N/A') {
                                          acceptChallenge(
                                            targetMatchId,
                                            requestingTeamId,
                                          );
                                        } else {
                                          _showSnackBar(
                                              "매치 또는 요청 팀 ID를 찾을 수 없습니다.");
                                        }
                                      },
                                      child: Text("수락"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        if (targetMatchId != 'N/A' &&
                                            requestingTeamId != 'N/A') {
                                          declineChallenge(
                                            targetMatchId,
                                            requestingTeamId,
                                          );
                                        } else {
                                          _showSnackBar(
                                              "매치 또는 요청 팀 ID를 찾을 수 없습니다.");
                                        }
                                      },
                                      child: Text("거절"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}