import 'package:flutter/material.dart';
import 'InquiryFormPage.dart';
import 'InquiryDetailPage.dart';
import 'inquiry_service.dart';

class InquiryMainPage extends StatefulWidget {
  const InquiryMainPage({super.key});

  @override
  State<InquiryMainPage> createState() => _InquiryMainPageState();
}

class _InquiryMainPageState extends State<InquiryMainPage> {
  List<Map<String, dynamic>> inquiries = [];

  @override
  void initState() {
    super.initState();
    fetchInquiries();
  }

  Future<void> fetchInquiries() async {
    final data = await InquiryService.getMyInquiries();
    setState(() {
      inquiries = data;
    });
  }

  Future<void> _goToFormPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const InquiryFormPage()),
    );
    if (result == true) fetchInquiries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('1:1 문의하기', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: inquiries.isEmpty
                ? const Center(child: Text('문의 내역이 없습니다'))
                : ListView.builder(
              itemCount: inquiries.length,
              itemBuilder: (context, index) {
                final item = inquiries[index];
                return ListTile(
                  title: Text(item['title'] ?? ''),
                  subtitle: Text(item['createdAt']?.substring(0, 10) ?? ''),
                  trailing: Text(
                    item['answerContent'] != null ? '답변 완료' : '대기 중',
                    style: TextStyle(
                      color: item['answerContent'] != null ? Colors.green : Colors.grey,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InquiryDetailPage(inquiryId: item['inquiryId']),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _goToFormPage,
              icon: const Icon(Icons.add),
              label: const Text('문의 작성하기'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: Colors.black,
              ),
            ),
          )
        ],
      ),
    );
  }
}
