import 'package:flutter/material.dart';

import 'inquiry_service.dart';

class InquiryFormPage extends StatefulWidget {
  const InquiryFormPage({super.key});

  @override
  State<InquiryFormPage> createState() => _InquiryFormPageState();
}

class _InquiryFormPageState extends State<InquiryFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isPrivate = false;
  bool isSubmitting = false;

  Future<void> _submitInquiry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSubmitting = true);

    final success = await InquiryService.createInquiry(
      _titleController.text,
      _contentController.text,
      password: isPrivate ? _passwordController.text : null,
      visibility: isPrivate ? 'PRIVATE' : 'PUBLIC',
    );

    setState(() => isSubmitting = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('문의가 등록되었습니다.')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('문의 등록에 실패했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('1:1 문의하기', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: '제목'),
                validator: (value) => value == null || value.isEmpty ? '제목을 입력해주세요' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                maxLines: 6,
                decoration: const InputDecoration(labelText: '내용', alignLabelWithHint: true),
                validator: (value) => value == null || value.isEmpty ? '내용을 입력해주세요' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: isPrivate,
                    onChanged: (value) => setState(() => isPrivate = value!),
                  ),
                  const Text('비공개 문의')
                ],
              ),
              if (isPrivate)
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: '비밀번호 (비공개용)'),
                  obscureText: true,
                  validator: (value) => isPrivate && (value == null || value.isEmpty)
                      ? '비밀번호를 입력해주세요'
                      : null,
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _submitInquiry,
                  child: isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('문의 등록하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
