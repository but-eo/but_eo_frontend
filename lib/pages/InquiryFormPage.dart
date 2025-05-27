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

  final Color _scaffoldBgColor = Colors.grey.shade200;
  final Color _cardBgColor = Colors.white;
  final Color _appBarBgColor = Colors.white;
  final Color _primaryTextColor = Colors.black87;
  final Color _secondaryTextColor = Colors.grey.shade700;
  final Color _accentColor = Colors.blue.shade700;
  final Color _inputBorderColor = Colors.grey.shade400;
  final Color _inputFillColor = Colors.white;

  final InquiryApiService _inquiryApiService = InquiryApiService(); // 서비스 객체 생성

  Future<void> _submitInquiry() async {
    if (!_formKey.currentState!.validate()) return;

    if(mounted) setState(() => isSubmitting = true);

    final success = await _inquiryApiService.createInquiry( // 실제 서비스 호출
      title: _titleController.text,
      content: _contentController.text,
      // 비공개(isPrivate)일 때만 password를 전달, 공개면 null을 전달하여 서버에서 PUBLIC으로 처리하도록 유도
      password: isPrivate ? _passwordController.text : null,
    );

    if(mounted) setState(() => isSubmitting = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('문의가 성공적으로 등록되었습니다.')),
      );
      Navigator.pop(context, true); // true를 반환하여 이전 페이지에서 새로고침 유도
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('문의 등록에 실패했습니다. 다시 시도해주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffoldBgColor,
      appBar: AppBar(
        title: Text('1:1 문의하기', style: TextStyle(color: _primaryTextColor, fontWeight: FontWeight.bold)),
        backgroundColor: _appBarBgColor,
        elevation: 0.5,
        iconTheme: IconThemeData(color: _primaryTextColor),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: _cardBgColor,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 0.5,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextFormField(
                      controller: _titleController,
                      label: '제목',
                      hint: '문의하실 내용의 제목을 입력해주세요.',
                      validator: (value) => value == null || value.isEmpty ? '제목을 입력해주세요' : null
                  ),
                  const SizedBox(height: 20),
                  _buildTextFormField(
                      controller: _contentController,
                      label: '내용',
                      hint: '문의 내용을 자세하게 작성해주세요.',
                      maxLines: 6,
                      validator: (value) => value == null || value.isEmpty ? '내용을 입력해주세요' : null
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: isPrivate,
                        onChanged: (value) {
                          if(mounted) setState(() => isPrivate = value!);
                        },
                        activeColor: _accentColor,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // 체크박스 주변 탭 영역 최소화
                      ),
                      GestureDetector(
                        onTap: () {
                          if(mounted) setState(() => isPrivate = !isPrivate);
                        },
                        child: Text('비공개 문의', style: TextStyle(color: _primaryTextColor, fontSize: 15)),
                      )
                    ],
                  ),
                  if (isPrivate)
                    _buildTextFormField(
                        controller: _passwordController,
                        label: '비밀번호 (비공개 설정 시)',
                        hint: '확인 시 사용할 비밀번호 4자리 이상', // 서버 제약에 맞게 수정 필요
                        obscureText: true,
                        keyboardType: TextInputType.visiblePassword, // 키보드 타입
                        // 서버에서 비밀번호 유효성 검사를 하므로, Flutter에서는 간단한 null 체크만.
                        // 서버 DTO에서 password 제약이 없다면 여기서도 필수 입력으로 안해도 됨.
                        // 단, 비공개인데 비밀번호가 없으면 서버에서 PUBLIC으로 처리될 수 있음.
                        validator: (value) => isPrivate && (value == null || value.isEmpty)
                            ? '비공개 문의 시 비밀번호를 입력해주세요.'
                            : null
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : _submitInquiry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: isSubmitting
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : const Text('문의 등록하기'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    bool obscureText = false,
    TextInputType? keyboardType,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _secondaryTextColor)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLength: maxLength,
          style: TextStyle(color: _primaryTextColor, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: _inputFillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _inputBorderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _inputBorderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _accentColor, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            counterText: "",
          ),
          validator: validator,
        ),
      ],
    );
  }
}