import 'package:flutter/material.dart';
import 'package:project/model/board_detail_model.dart';
import 'package:project/service/board_api_get_service.dart';
import 'package:project/service/board_api_post_service.dart';

class EditBoardPage extends StatefulWidget {
  final String boardId;
  final String event;
  final String category;
  final String userId;

  const EditBoardPage({super.key, required this.boardId, required this.event, required this.category, required this.userId});

  @override
  State<EditBoardPage> createState() => _EditBoardPageState();
}

class _EditBoardPageState extends State<EditBoardPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();


  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBoardData();
  }

  Future<void> _loadBoardData() async {
    try {
      BoardDetail board = await fetchBoardDetail(widget.boardId);
      _titleController.text = board.title;
      _contentController.text = board.content;
    } catch (e) {
      print('게시글 로딩 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('게시글 정보를 불러오지 못했습니다')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
      appBar: AppBar(title: Text('게시글 수정')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: '제목'),
                validator: (value) => value!.isEmpty ? '제목을 입력해주세요' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(labelText: '내용'),
                maxLines: 10,
                validator: (value) => value!.isEmpty ? '내용을 입력해주세요' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  print("유저 아이디" + widget.userId);
                  if (_formKey.currentState!.validate()) {
                    final success = await updateBoardPost(
                      boardId: widget.boardId,
                      title: _titleController.text,
                      content: _contentController.text,
                      event: widget.event,       // 사용자가 선택한 값 (예: 'SOCCER')
                      category: widget.category, // 사용자가 선택한 값 (예: 'FREE')
                      state: 'PUBLIC',
                      // files: [], // 파일 추가 예정이면 여기에 전달
                    );

                    if (success) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('게시글이 성공적으로 수정되었습니다.')),
                      );
                      Navigator.pop(context, true); // 이전 화면으로 이동 (예: 상세 페이지 또는 목록 페이지)
                    } else {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('게시글 수정에 실패했습니다. 다시 시도해주세요.')),
                      );
                    }
                  }
                },
                child: Text('수정 완료'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
