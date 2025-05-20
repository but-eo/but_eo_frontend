import 'package:flutter/material.dart';
import 'inquiry_service.dart';

class InquiryDetailPage extends StatefulWidget {
  final String inquiryId;

  const InquiryDetailPage({super.key, required this.inquiryId});

  @override
  State<InquiryDetailPage> createState() => _InquiryDetailPageState();
}

class _InquiryDetailPageState extends State<InquiryDetailPage> {
  Map<String, dynamic>? inquiry;
  final _passwordController = TextEditingController();

  Future<void> loadDetail({String? password}) async {
    final result = await InquiryService.getInquiryDetail(widget.inquiryId, password: password);

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('비밀번호가 틀렸거나 조회 실패')));
    } else {
      setState(() => inquiry = result);
    }
  }

  @override
  void initState() {
    super.initState();
    loadDetail();
  }

  @override
  Widget build(BuildContext context) {
    if (inquiry == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('문의 상세')),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text('비공개 문의입니다. 비밀번호를 입력하세요.'),
              TextField(controller: _passwordController, obscureText: true),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => loadDetail(password: _passwordController.text),
                child: const Text('확인'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('문의 상세')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(inquiry!['title'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(inquiry!['content'] ?? ''),
            const Divider(height: 32),
            Text(
              inquiry!['answerContent'] != null
                  ? '🔔 관리자 답변:\n${inquiry!['answerContent']}'
                  : '⏳ 아직 답변이 등록되지 않았습니다.',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
