// lib/pages/board/Edit_Board_Page.dart
import 'package:flutter/material.dart';
import 'package:project/model/board_detail_model.dart';
import 'package:project/service/board_api_get_service.dart';
import 'package:project/service/board_api_post_service.dart';

class EditBoardPage extends StatefulWidget {
  final String boardId;
  final String event;
  final String category;
  final String userId;

  const EditBoardPage({
    super.key,
    required this.boardId,
    required this.event,
    required this.category,
    required this.userId,
  });

  @override
  State<EditBoardPage> createState() => _EditBoardPageState();
}

class _EditBoardPageState extends State<EditBoardPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  bool _pageLoading = true;
  bool _isSubmitting = false;

  final Color _scaffoldBgColor = Colors.grey.shade200;
  final Color _appBarBgColor = Colors.white;
  final Color _primaryTextColor = Colors.black87;
  final Color _secondaryTextColor = Colors.grey.shade700;
  final Color _accentColor = Colors.blue.shade700;
  final Color _inputBorderColor = Colors.grey.shade300;
  final Color _inputFillColor = Colors.white;

  String _displayEvent = '';   // UI 표시용 종목 이름
  String _displayCategory = '';// UI 표시용 카테고리 이름

  @override
  void initState() {
    super.initState();
    _displayEvent = _mapApiEventToDisplay(widget.event); // API enum 값을 표시용 문자열로 변환
    _displayCategory = _mapApiCategoryToDisplay(widget.category); // API enum 값을 표시용 문자열로 변환
    _loadBoardData();
  }

  Future<void> _loadBoardData() async {
    if (mounted) setState(() => _pageLoading = true);
    try {
      BoardDetail board = await fetchBoardDetail(widget.boardId);
      if (mounted) {
        _titleController.text = board.title;
        _contentController.text = board.content;
        // event, category는 widget에서 받은 API enum 값을 그대로 사용하므로,
        // 화면 표시용으로 변환된 _displayEvent, _displayCategory는 initState에서 설정.
      }
    } catch (e) {
      print('게시글 정보 로딩 실패 (EditBoardPage): $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('게시글 정보를 불러오지 못했습니다: ${e.toString()}')),
        );
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _pageLoading = false);
    }
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    if (mounted) setState(() => _isSubmitting = true);

    final success = await updateBoardPost(
      boardId: widget.boardId,
      title: _titleController.text,
      content: _contentController.text,
      event: widget.event,    // 생성 시 전달받은 API Enum 값 그대로 사용
      category: widget.category, // 생성 시 전달받은 API Enum 값 그대로 사용
      state: 'PUBLIC',
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시글이 성공적으로 수정되었습니다.')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시글 수정에 실패했습니다. 다시 시도해주세요.')),
        );
      }
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffoldBgColor,
      appBar: AppBar(
        title: Text('게시글 수정', style: TextStyle(color: _primaryTextColor, fontWeight: FontWeight.bold)),
        backgroundColor: _appBarBgColor,
        elevation: 0.5,
        iconTheme: IconThemeData(color: _primaryTextColor),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _pageLoading
          ? Center(child: CircularProgressIndicator(color: _accentColor))
          : Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 90.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  _buildReadOnlyInfo("종목", _displayEvent),
                  const SizedBox(height: 12),
                  _buildReadOnlyInfo("게시판", _displayCategory),
                  const SizedBox(height: 20),
                  _buildStyledTextFormField(
                    controller: _titleController,
                    label: '제목',
                    hint: '제목을 입력하세요 (최대 50자)',
                    validator: (value) {
                      if (value == null || value.isEmpty) return '제목을 입력해주세요.';
                      if (value.length > 50) return '제목은 50자 이내로 작성해주세요.';
                      return null;
                    },
                    maxLength: 50,
                  ),
                  const SizedBox(height: 16),
                  _buildStyledTextFormField(
                    controller: _contentController,
                    label: '내용',
                    hint: '내용을 작성해주세요 (최대 1000자)',
                    maxLines: 10,
                    minLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) return '내용을 입력해주세요.';
                      if (value.length > 1000) return '내용은 1000자 이내로 작성해주세요.';
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
            left: 16, right: 16, bottom: MediaQuery.of(context).padding.bottom + 16,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save_alt_rounded, color: Colors.white),
              label: Text('수정 완료', style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold, color: Colors.white)),
              onPressed: _isSubmitting ? null : _submitUpdate,
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentColor,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                elevation: 2.0,
              ),
            ),
          ),
          if (_isSubmitting)
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
    required TextEditingController controller,
    required String label,
    required String hint,
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
          controller: controller,
          style: TextStyle(color: _primaryTextColor, fontSize: 15.5, height: 1.4),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade500),
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
            counterText: "",
          ),
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          validator: validator,
          textInputAction: maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
        ),
      ],
    );
  }

  // API Enum 값을 UI 표시용 문자열로 변환 (CreateBoardPage와 반대)
  String _mapApiEventToDisplay(String apiEventValue) {
    switch (apiEventValue) {
      case 'SOCCER': return '축구';
      case 'FUTSAL': return '풋살';
      case 'BASEBALL': return '야구';
      case 'BASKETBALL': return '농구';
      case 'BADMINTON': return '배드민턴';
      case 'TENNIS': return '테니스';
      case 'TABLE_TENNIS': return '탁구';
      case 'BOWLING': return '볼링';
      default: return apiEventValue; // 알 수 없는 값은 그대로 표시
    }
  }

  String _mapApiCategoryToDisplay(String apiCategoryValue) {
    switch (apiCategoryValue) {
      case 'FREE': return '자유게시판';
      case 'REVIEW': return '후기게시판';
      case 'TEAM': return '팀찾기게시판';
      case 'MEMBER': return '팀원찾기게시판';
      case 'NOTIFICATION': return '경기장게시판';
      default: return apiCategoryValue; // 알 수 없는 값은 그대로 표시
    }
  }
}