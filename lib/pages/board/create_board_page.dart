// lib/pages/board/create_board_page.dart
import 'package:flutter/material.dart';
import 'package:project/service/board_api_post_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateBoardPage extends StatefulWidget {
  final String initialEvent;
  final String initialCategory;

  const CreateBoardPage({super.key, required this.initialEvent, required this.initialCategory});

  @override
  _CreateBoardPageState createState() => _CreateBoardPageState();
}

class _CreateBoardPageState extends State<CreateBoardPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _content = '';
  late String _selectedEventDisplay; // UI 표시용
  late String _selectedCategoryDisplay; // UI 표시용

  final Color _scaffoldBgColor = Colors.grey.shade200;
  final Color _appBarBgColor = Colors.white;
  final Color _primaryTextColor = Colors.black87;
  final Color _secondaryTextColor = Colors.grey.shade700;
  final Color _accentColor = Colors.blue.shade700;
  final Color _inputBorderColor = Colors.grey.shade300;
  final Color _inputFillColor = Colors.white;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedEventDisplay = widget.initialEvent;
    _selectedCategoryDisplay = widget.initialCategory;
  }

  Future<String?> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    if (mounted) setState(() => _isLoading = true);

    final currentUserId = await _getCurrentUserId();
    if (currentUserId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인 정보가 없습니다. 다시 로그인해주세요.')),
        );
        setState(() => _isLoading = false);
      }
      return;
    }

    final eventApiValue = _convertSportToEventEnum(_selectedEventDisplay);
    final categoryApiValue = _convertCategoryToEnum(_selectedCategoryDisplay);

    final success = await createBoardPost(
      title: _title,
      content: _content,
      event: eventApiValue,
      category: categoryApiValue,
      userId: currentUserId,
    );

    if (mounted) {
      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시글 작성에 실패했습니다. 다시 시도해주세요.')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffoldBgColor,
      appBar: AppBar(
        title: Text('새 게시글 작성', style: TextStyle(color: _primaryTextColor, fontWeight: FontWeight.bold)),
        backgroundColor: _appBarBgColor,
        elevation: 0.5,
        iconTheme: IconThemeData(color: _primaryTextColor),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded), // 닫기 아이콘으로 변경
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 90.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  _buildReadOnlyInfo("종목", _selectedEventDisplay),
                  const SizedBox(height: 12),
                  _buildReadOnlyInfo("게시판", _selectedCategoryDisplay),
                  const SizedBox(height: 20),
                  _buildStyledTextFormField(
                    label: '제목',
                    hint: '제목을 입력하세요 (최대 50자)',
                    onSaved: (val) => _title = val ?? '',
                    validator: (val) {
                      if (val == null || val.isEmpty) return '제목을 입력해주세요.';
                      if (val.length > 50) return '제목은 50자 이내로 작성해주세요.';
                      return null;
                    },
                    maxLength: 50,
                  ),
                  const SizedBox(height: 16),
                  _buildStyledTextFormField(
                    label: '내용',
                    hint: '내용을 작성해주세요 (최대 1000자)',
                    maxLines: 10,
                    minLines: 5, // 최소 높이 확보
                    onSaved: (val) => _content = val ?? '',
                    validator: (val) {
                      if (val == null || val.isEmpty) return '내용을 입력해주세요.';
                      if (val.length > 1000) return '내용은 1000자 이내로 작성해주세요.';
                      return null;
                    },
                    maxLength: 1000,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
              decoration: BoxDecoration(
                  color: _appBarBgColor, // 하단 버튼 영역 배경
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0,-2))]
              ),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                label: Text('작성 완료', style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold, color: Colors.white)),
                onPressed: _isLoading ? null : _submitPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentColor,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  elevation: 2.0,
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.25),
              child: Center(child: CircularProgressIndicator(color: _accentColor)),
            ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyInfo(String label, String value) {
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: _inputBorderColor.withOpacity(0.5))
        ),
        child: RichText(
            text: TextSpan(
                style: TextStyle(fontSize: 15, color: _secondaryTextColor),
                children: [
                  TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
                  TextSpan(text: value, style: TextStyle(color: _primaryTextColor, fontWeight: FontWeight.w500)),
                ]
            )
        )
    );
  }

  Widget _buildStyledTextFormField({
    required String label,
    required String hint,
    required Function(String?) onSaved,
    required String? Function(String?) validator,
    int maxLines = 1,
    int? minLines,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _secondaryTextColor)),
        const SizedBox(height: 8),
        TextFormField(
          style: TextStyle(color: _primaryTextColor, fontSize: 15.5, height: 1.4),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 15),
            filled: true,
            fillColor: _inputFillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: _inputBorderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: _inputBorderColor.withOpacity(0.7)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: _accentColor, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            counterText: "", // maxLength 카운터 숨기기 (필요시)
          ),
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          onSaved: onSaved,
          validator: validator,
          textInputAction: maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
        ),
      ],
    );
  }

  String _convertSportToEventEnum(String sport) {
    switch (sport) {
      case '축구': return 'SOCCER';
      case '풋살': return 'FUTSAL';
      case '야구': return 'BASEBALL';
      case '농구': return 'BASKETBALL';
      case '배드민턴': return 'BADMINTON';
      case '테니스': return 'TENNIS';
      case '탁구': return 'TABLE_TENNIS';
      case '볼링': return 'BOWLING';
      default: return sport.toUpperCase();
    }
  }

  String _convertCategoryToEnum(String category) {
    switch (category) {
      case '자유게시판': return 'FREE';
      case '후기게시판': return 'REVIEW';
      case '팀찾기게시판': return 'TEAM';
      case '팀원찾기게시판': return 'MEMBER';
      case '경기장게시판': return 'NOTIFICATION';
      default: return category.toUpperCase();
    }
  }
}