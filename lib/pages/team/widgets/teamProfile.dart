import 'package:flutter/material.dart';
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
    final int totalReview = team['totalReview'] ?? 0;

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
            Text("평점: $rating점", style: const TextStyle(fontSize: 13, color: Colors.black87)),
            const SizedBox(width: 12),
            const Icon(Icons.rate_review_outlined, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text("리뷰 $totalReview건", style: const TextStyle(fontSize: 13, color: Colors.black54)),
          ],
        ),
      ],
    );
  }
}
