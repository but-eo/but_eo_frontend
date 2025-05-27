import 'package:flutter/material.dart';

class TeamInvitation extends StatelessWidget {
  final bool isRequested;

  const TeamInvitation({super.key, required this.isRequested});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('팀 가입'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _buildJoinButton(context),
          ),
        ],
      ),
      body: const Center(
        child: Text('팀 정보를 확인하고 가입을 요청할 수 있습니다.'),
      ),
    );
  }

  Widget _buildJoinButton(BuildContext context) {
    if (isRequested) {
      return OutlinedButton(
        onPressed: () {
          // 가입 요청 취소 로직
        },
        child: const Text('가입 대기중... 취소'),
      );
    } else {
      return ElevatedButton(
        onPressed: () async {
          final result = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('팀 가입'),
              content: const Text('이 팀에 가입하시겠습니까?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('확인'),
                ),
              ],
            ),
          );
          if (result == true) {
            // 가입 요청 로직 실행
          }
        },
        child: const Text('팀 가입하기'),
      );
    }
  }
}