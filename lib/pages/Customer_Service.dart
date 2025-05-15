import 'package:flutter/material.dart';
import 'InquiryDetailPage.dart';
import 'InquiryFormPage.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerServicePage extends StatefulWidget {
  const CustomerServicePage({super.key});

  @override
  State<CustomerServicePage> createState() => _CustomerServicePageState();
}

class _CustomerServicePageState extends State<CustomerServicePage> {
  String selectedTag = "모두";
  String searchQuery = "";

  List<Map<String, String>> get filteredInquiries {
    return dummyInquiries.where((inquiry) {
      final title = inquiry['title'] ?? '';
      final content = inquiry['content'] ?? '';
      final matchesSearch = searchQuery.isEmpty || title.contains(searchQuery) || content.contains(searchQuery);
      final matchesTag = selectedTag == "모두" || title.contains(selectedTag) || content.contains(selectedTag);
      return matchesSearch && matchesTag;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('고객센터', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0.3,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("무엇이 궁금하세요?",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text("고객센터에서 알려드릴게요.",
                            style: TextStyle(fontSize: 16, color: Colors.black54)),
                      ],
                    ),
                  ),
                  const Icon(Icons.headset_mic, size: 48, color: Colors.lightBlue),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildMainButton(context, "챗봇상담 문의", Colors.black),
                  const SizedBox(width: 8),
                  _buildMainButton(
                    context,
                    "전화문의",
                    Colors.white,
                    textColor: Colors.black,
                    onTap: () => launchPhoneDialer("01027460094"),
                  ),
                  const SizedBox(width: 8),
                  _buildMainButton(context, "1:1 문의", Colors.white,
                      textColor: Colors.black,
                      onTap: () => Navigator.push(
                          context, MaterialPageRoute(builder: (_) => const InquiryFormPage()))),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '자주 묻는 질문',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (value) => setState(() => searchQuery = value),
                decoration: InputDecoration(
                  hintText: "궁금한 점을 검색해보세요",
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final tag in [
                    "모두",
                    "위치",
                    "매칭 시스템",
                    "MyTeam",
                    "Rating System",
                    "비매너 신고하기",
                    "경기장 예약",
                  ])
                    GestureDetector(
                      onTap: () => setState(() => selectedTag = tag),
                      child: _TagChip(
                        tag,
                        isSelected: selectedTag == tag,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: filteredInquiries.map((inquiry) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => InquiryDetailPage(inquiry: inquiry)),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.help_outline, color: Colors.blue),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              inquiry['title']!,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const Divider(height: 40),
            ListTile(
              leading: const Icon(Icons.campaign),
              title: const Text("[경기장 예약] 산불로 인한 경기장 예약 불가 안내"),
              onTap: () {},
            ),
            const Divider(),
            _BottomMenuItem(Icons.store_mall_directory, "경기장 찾기"),
            _BottomMenuItem(Icons.description, "이용약관"),
            _BottomMenuItem(Icons.info_outline, "경기장 관리자 가이드"),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMainButton(BuildContext context, String label, Color bgColor,
      {Color textColor = Colors.white, VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.black12),
          ),
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: textColor),
          ),
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  const _TagChip(this.label, {this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.lightBlue.shade100 : Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _BottomMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const _BottomMenuItem(this.icon, this.title);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {},
    );
  }
}

final List<Map<String, String>> dummyInquiries = [
  {
    'title': '매칭이 잡히지 않아요',
    'content': '3일째 매칭 요청했는데 응답이 없어요. 다른 방법 없을까요?',
    'answer': '일부 지역은 인원이 적어 시간이 소요될 수 있습니다. 계속 시도해 주세요!',
  },
  {
    'title': '결제했는데 경기장이 적용 안 돼요',
    'content': '광고 제거 옵션 결제했는데 여전히 광고가 나옵니다.',
    'answer': '앱을 재시작하거나 복원 버튼을 눌러주세요. 해결되지 않으면 문의 주세요.',
  },
];

void launchPhoneDialer(String phoneNumber) async {
  final Uri url = Uri(scheme: 'tel', path: phoneNumber);
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    throw '전화 앱을 열 수 없습니다.';
  }
}