import 'package:project/data/teamEnum.dart';

class MatchingData {
  final String matchId;
  final String teamName;
  final String matchRegion;
  final String stadiumName;
  final String stadiumRegion;
  final Region teamRegion;
  final DateTime matchDay;
  final String matchType;
  final bool loan;
  final String teamImage; // 여기가 문제
  final int rating; // 여기도 문제

  MatchingData({
    required this.matchId,
    required this.teamName,
    required this.matchRegion,
    required this.stadiumName,
    required this.stadiumRegion,
    required this.teamRegion,
    required this.matchDay,
    required this.matchType,
    required this.loan,
    required this.teamImage,
    required this.rating,
  });

  factory MatchingData.fromJson(Map<String, dynamic> json) {
    return MatchingData(
      matchId: json['matchId']?.toString() ?? '',
      teamName: json['teamName']?.toString() ?? '',
      matchRegion: json['matchRegion']?.toString() ?? '',
      stadiumName: json['stadiumName']?.toString() ?? '미정',
      stadiumRegion: json['stadiumRegion']?.toString() ?? '미정',
      teamRegion: parseRegion(json['teamRegion']?.toString()),
      matchDay:
          DateTime.tryParse(json['matchDate']?.toString() ?? '') ??
          DateTime.now(),
      matchType: json['matchType']?.toString() ?? '기타',
      loan: json['loan'] is bool ? json['loan'] : false,
      teamImage: json['teamImg']?.toString() ?? '',
      rating:
          (json['teamRating'] is int)
              ? json['teamRating']
              : int.tryParse(json['teamRating']?.toString() ?? '0') ?? 0,
    );
  }
}
