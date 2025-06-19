import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/contants/api_contants.dart';
import 'package:project/pages/match/matching_detail.dart';

class _TeamImage extends StatelessWidget {
  final String teamImageUrl;

  const _TeamImage({required this.teamImageUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String baseUrl = "http://${ApiConstants.serverUrl}:714";

    final fullImageUrl =
        teamImageUrl.startsWith('http')
            ? teamImageUrl
            : '$baseUrl${teamImageUrl.startsWith('/') ? '' : '/uploads/teams/'}$teamImageUrl';
    print("Full image URL: $fullImageUrl");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage:
              teamImageUrl.isNotEmpty
                  ? NetworkImage(fullImageUrl)
                  : const AssetImage("assets/images/default_team.png")
                      as ImageProvider,
        ),
      ],
    );
  }
}

class _TeamInfo extends StatelessWidget {
  final String teamName;
  final int rating;
  final String region;
  final DateTime matchDay;

  const _TeamInfo({
    required this.teamName,
    required this.rating,
    required this.region,
    required this.matchDay,
    Key? key,
  }) : super(key: key);

  String formatMatchDay(DateTime matchDay) {
    final year = DateFormat('yyyy').format(matchDay);
    final month = DateFormat('MM').format(matchDay);
    final day = DateFormat('dd').format(matchDay);
    final time = DateFormat('HH:mm').format(matchDay); // 24시간 형식

    return '$year년 $month월 $day일 $time';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(teamName),
        Text("레이팅: $rating"),
        Text("장소: $region", overflow: TextOverflow.ellipsis, maxLines: 2,),
        Text(formatMatchDay(matchDay)),
      ],
    );
  }
}

class Matchingcard extends StatelessWidget {
  final String matchId;
  final String teamImg;
  final String teamName;
  final int rating;
  final String region;
  final DateTime matchDay;
  final VoidCallback? onTap; // ← 추가

  const Matchingcard({
    required this.matchId,
    required this.teamImg,
    required this.teamName,
    required this.rating,
    required this.region,
    required this.matchDay,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (_) => MatchingDetailPage(matchId: matchId),
      //   ),
      // );
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          border: Border.all(width: 1.0),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TeamImage(teamImageUrl: teamImg),
                SizedBox(width: 10.0),
                Expanded(child: _TeamInfo(
                  teamName: teamName,
                  rating: rating,
                  region: region,
                  matchDay: matchDay,
                ),)

              ],
            ),
          ),
        ),
      ),
    );
  }
}
