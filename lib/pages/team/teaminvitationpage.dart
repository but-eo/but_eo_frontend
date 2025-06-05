import 'package:flutter/material.dart';
import 'package:project/appStyle/app_colors.dart';
import 'package:project/data/time_formatter.dart';
import 'package:project/service/teamInvitaionService.dart';

class Teaminvitationpage extends StatefulWidget {
  final String teamId;

  const Teaminvitationpage({super.key, required this.teamId});

  @override
  State<Teaminvitationpage> createState() => _TeaminvitationpageState();
}

class _TeaminvitationpageState extends State<Teaminvitationpage> {
  List<Map<String, dynamic>> requests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJoinRequests();
  }

  Future<void> _loadJoinRequests() async {
    try {
      final result = await TeamInvitaionService.getJoinRequests(widget.teamId);
      setState(() {
        requests = result;
        isLoading = false;
      });
    } catch (e) {
      print("❌ 팀 가입 요청 불러오기 실패: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.baseGrey10Color,
      appBar: AppBar(
        title: const Text("팀 초대 요청", style: TextStyle(color: AppColors.textPrimary)),
        centerTitle: true,
        backgroundColor: AppColors.baseWhiteColor,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : requests.isEmpty
          ? const Center(child: Text("초대 요청이 없습니다."))
          : ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return _buildRow(
            username: request['userName'] ?? '알 수 없음',
            userId: request['userId'] ?? '',
            invitationId: request['invitationId'] ?? '',
            profileImg: request['profileImg'],
            date: formatRelativeTime(request['requestedAt'] ?? ''),
          );
        },
      ),
    );
  }

  Widget _buildRow({
    required String username,
    required String userId,
    required String invitationId,
    required String? profileImg,
    required String date,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          ClipOval(
            child: profileImg != null && profileImg.isNotEmpty
                ? Image.network(
              profileImg,
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.asset(
                "assets/images/whitedog.png",
                width: 44,
                height: 44,
                fit: BoxFit.cover,
              ),
            )
                : Image.asset(
              "assets/images/whitedog.png",
              width: 44,
              height: 44,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    children: [
                      TextSpan(
                          text: username,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: "님이 초대를 받았습니다."),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(date, style: const TextStyle(fontSize: 12, color: AppColors.brandBlack)),
              ],
            ),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () async {
                  await TeamInvitaionService.acceptInvitation(invitationId, userId);
                  _loadJoinRequests(); // 새로고침
                },
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.brandBlue,
                  foregroundColor: AppColors.baseWhiteColor,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: const Text("확인"),
              ),
              const SizedBox(width: 6),
              TextButton(
                onPressed: () async {
                  await TeamInvitaionService.declineInvitation(invitationId, userId);
                  _loadJoinRequests(); // 새로고침
                },
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.lightGrey,
                  foregroundColor: AppColors.baseBlackColor,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  side: const BorderSide(color: AppColors.baseBlackColor, width: 0.7),
                ),
                child: const Text("삭제"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
