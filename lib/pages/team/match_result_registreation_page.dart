import 'package:flutter/material.dart';

class MatchResultRegistrationPage extends StatefulWidget {
  final String matchId; // 결과를 등록할 매치의 ID
  final String requestingTeamName; // 요청 팀 이름 (표시용)
  final String targetMatchName; // 대상 매치 이름 (표시용)

  const MatchResultRegistrationPage({
    super.key,
    required this.matchId,
    required this.requestingTeamName,
    required this.targetMatchName,
  });

  @override
  State<MatchResultRegistrationPage> createState() => _MatchResultRegistrationPageState();
}

class _MatchResultRegistrationPageState extends State<MatchResultRegistrationPage> {
  // 여기에 매치 결과 (점수, 승패 등)를 입력받고 서버에 전송하는 로직을 구현합니다.
  // 예시: TextEditingController scoreController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('매치 결과 등록')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('매치 ID: ${widget.matchId}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('요청 팀: ${widget.requestingTeamName}', style: TextStyle(fontSize: 16)),
            Text('대상 매치: ${widget.targetMatchName}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            // 여기에 점수 입력 필드, 승패 선택 등 결과 등록 UI를 추가합니다.
            Text('여기에 결과 입력 필드와 등록 버튼이 들어갑니다.'),
            // 예시: TextField(controller: scoreController, decoration: InputDecoration(labelText: '점수 입력')),
            // ElevatedButton(onPressed: () { /* 결과 서버 전송 로직 */ }, child: Text('결과 등록')),
          ],
        ),
      ),
    );
  }
}