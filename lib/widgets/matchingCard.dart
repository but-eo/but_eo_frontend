import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/contants/api_contants.dart';

class _TeamImage extends StatelessWidget {
  final String teamImageUrl;
  final String baseUrl = "http://${ApiConstants.serverUrl}:714";

  const _TeamImage({required this.teamImageUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: const AssetImage("assets/images/default_team.png"),
        ),
      ],
    );
  }
}

class _TeamInfo extends StatelessWidget {
  final String teamName;
  final int rating;
  final DateTime matchDay;

  const _TeamInfo({
    required this.teamName,
    required this.rating,
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
        Text("레이팅 : $rating"),
        Text(formatMatchDay(matchDay)),
      ],
    );
  }
}

class Matchingcard extends StatelessWidget {
  final String teamImage;
  final String teamName;
  final int rating;
  final DateTime matchDay;

  const Matchingcard({
    required this.teamImage,
    required this.teamName,
    required this.rating,
    required this.matchDay,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.98,
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
              _TeamImage(teamImageUrl: teamImage),
              SizedBox(width: 16.0),
              _TeamInfo(teamName: teamName, rating: rating, matchDay: matchDay),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: 40, // 원하는 높이로 조절
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        side: BorderSide(color: Colors.black, width: 1),
                        padding: EdgeInsets.symmetric(horizontal: 16), // 내부 여백
                        textStyle: TextStyle(fontSize: 12),
                      ),
                      child: Text("매칭 신청"),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
