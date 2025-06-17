import 'package:flutter/material.dart';
import 'package:project/pages/team/teamReviewPage.dart';
import 'package:project/service/teamService.dart';

class TeamProfile extends StatelessWidget {
  final Map<String, dynamic> team;

  const TeamProfile({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    final String teamName = team['teamName'] ?? '팀 이름 없음';
    final int wins = team['winCount'] ?? 0;
    final int draws = team['drawCount'] ?? 0;
    final int losses = team['loseCount'] ?? 0;
    final int rating = team['rating'] ?? 0;
    final double avgReviewRating = team['avgReviewRating'] ?? 0;
    final teamId = team['teamId'].toString();

    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey[300],
          backgroundImage: team['teamImg'] != null && team['teamImg'].toString().isNotEmpty
              ? NetworkImage("${TeamService.getFullTeamImageUrl(team['teamImg'])}?v=${DateTime.now().millisecondsSinceEpoch}")
              : null,
          child: team['teamImg'] == null || team['teamImg'].toString().isEmpty
              ? const Icon(Icons.group, size: 40, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 16),
        Text(teamName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text("$wins승 $draws무 $losses패", style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star, size: 16, color: Colors.amber),
            const SizedBox(width: 4),
            Text("현재 점수: $rating점", style: const TextStyle(fontSize: 13, color: Colors.black87)),
            const SizedBox(width: 12),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TeamReviewPage(teamId: team['teamId'].toString()),
                  ),
                );
              },
              child: Padding( // 탭 영역을 조금 더 넓히기 위해 Padding 추가
                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.rate_review_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      "매너 점수  $avgReviewRating점",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),


          ],
        )

      ],
    );
  }
}
