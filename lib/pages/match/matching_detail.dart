import 'package:flutter/material.dart';
import 'package:project/service/matchService.dart';

class MatchingDetailPage extends StatefulWidget {
  final String matchId;

  const MatchingDetailPage({required this.matchId, Key? key}) : super(key: key);

  @override
  State<MatchingDetailPage> createState() => _MatchingDetailPageState();
}

class _MatchingDetailPageState extends State<MatchingDetailPage> {
  Map<String, dynamic>? matchData;
  bool isLoading = true;

  Future<void> _loadMatching(String matchId) async {
    try {
      final data = await Matchservice().fetchMatching(matchId);
      setState(() {
        matchData = data;
        isLoading = false;
      });
    } catch (e) {
      print("매칭 정보 불러오기 실패 : $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMatching(widget.matchId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("매치 신청하기"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : matchData == null
              ? const Center(child: Text("데이터를 불러오지 못했습니다."))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(Icons.group, "팀 이름", matchData!['teamName']),
                          const Divider(),
                          _buildInfoRow(Icons.star, "팀 레이팅", matchData!['teamRating'].toString()),
                          const Divider(),
                          _buildInfoRow(Icons.location_on, "매치 지역", matchData!['matchRegion']),
                          const Divider(),
                          _buildInfoRow(Icons.calendar_month, "경기 날짜", matchData!['matchDate']),
                          const Divider(),
                          _buildInfoRow(
                            Icons.stadium,
                            "경기장 대여 여부",
                            matchData!['loan'] == true ? "예" : "아니오",
                          ),
                          const Divider(),
                          _buildInfoRow(Icons.note, "기타 사항", matchData!['etc'] ?? "없음"),
                          const SizedBox(height: 24.0),
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // 도전 신청 기능 여기에
                              },
                              icon: const Icon(Icons.send),
                              label: const Text("매칭 신청"),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0, vertical: 12.0),
                                textStyle: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: Colors.blueGrey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text(value ?? '정보 없음',
                  style: const TextStyle(fontSize: 15, color: Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }
}
