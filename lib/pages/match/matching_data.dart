class MatchingData {
  final String matchId;
  final String teamName;
  final String region;
  final String stadiumName;
  final DateTime matchDay;
  final String matchType;
  final bool loan;
  final String teamImage; // 여기가 문제
  final int rating; // 여기도 문제

  MatchingData({
    required this.matchId,
    required this.teamName,
    required this.region,
    required this.stadiumName,
    required this.matchDay,
    required this.matchType,
    required this.loan,
    required this.teamImage,
    required this.rating,
  });

  factory MatchingData.fromJson(Map<String, dynamic> json) {
    return MatchingData(
      matchId: json['matchId'] ?? '',
      teamName: json['teamName'] ?? '',
      region: json['region'] ?? '',
      stadiumName: json['stadiumName'] ?? '미정',
      matchDay: DateTime.tryParse(json['matchDate'] ?? '') ?? DateTime.now(),
      matchType: json['matchType'] ?? '기타',
      loan: json['loan'] ?? false,
      teamImage: json['teamImage'] ?? '', // 기본값 주기
      rating: (json['rating'] ?? 0), // null 또는 int 방지
    );
  }
}
