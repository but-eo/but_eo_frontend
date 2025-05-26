class MatchingData {
  final String teamImage;
  final String teamName;
  final int rating;
  final DateTime matchDay;
  final String sports; //매칭 하는 종목

  MatchingData({
    required this.teamImage,
    required this.teamName,
    required this.sports,
    required this.rating,
    required this.matchDay,
  });

  factory MatchingData.fromJson(Map<String, dynamic> json) {
    return MatchingData(
      teamImage: json['teamImage'],
      teamName: json['teamName'],
      sports: json['sports'],
      rating: json['rating'],
      matchDay: DateTime.parse(json['matchDay']),
    );
  }
}
