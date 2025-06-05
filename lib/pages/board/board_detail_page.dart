// lib/pages/board/board_detail_page.dart

import 'package:flutter/material.dart';
import 'package:project/model/board_detail_model.dart';
import 'package:project/model/board_comment_model.dart';
import 'package:project/pages/board/Edit_Board_Page.dart';
import 'package:project/service/board_api_get_service.dart';
import 'package:project/service/board_api_post_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BoardDetailPage extends StatefulWidget {
  final String boardId;

  const BoardDetailPage({super.key, required this.boardId});

  @override
  State<BoardDetailPage> createState() => _BoardDetailPageState();
}

class _BoardDetailPageState extends State<BoardDetailPage> {
  String? currentUserId;
  late Future<BoardDetail> futureBoardDetail;
  final _commentController = TextEditingController();
  String? editingCommentId;
  final TextEditingController _editingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureBoardDetail = fetchBoardDetail(widget.boardId);
    _loadUserId();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _editingController.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getString('userId');
    });
  }

  void _refreshData() {
    setState(() {
      futureBoardDetail = fetchBoardDetail(widget.boardId);
    });
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    // 수정된 createComment 함수 호출 (userId 불필요)
    final success = await createComment(
      boardId: widget.boardId,
      content: _commentController.text,
    );

    if (mounted) {
      if (success) {
        _commentController.clear();
        FocusScope.of(context).unfocus();
        _refreshData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('댓글 등록 실패')));
      }
    }
  }

  Future<void> _updateComment(String commentId) async {
    String updatedContent = _editingController.text.trim();
    print('Updating commentId: $commentId with content: $updatedContent');
    if (updatedContent.isEmpty) return;

    bool success = await updateComment(
      commentId: commentId,
      content: updatedContent,
    );

    if (success) {
      setState(() {
        editingCommentId = null;
        _editingController.clear();
      });
      _refreshData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('댓글 수정 실패')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("게시글")),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<BoardDetail>(
                future: futureBoardDetail,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return Center(child: Text("데이터 로딩 실패: ${snapshot.error}"));
                  }

                  final board = snapshot.data!;
                  final isAuthor = board.userId == currentUserId;

                  return RefreshIndicator(
                    onRefresh: () async => _refreshData(),
                    child: ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: [
                        Text(board.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Text(board.content, style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('작성자: ${board.userName}', style: TextStyle(color: Colors.grey[700])),
                            Text(board.createdAt.split('T')[0], style: TextStyle(color: Colors.grey[700])),
                          ],
                        ),
                        const Divider(height: 30),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text('❤️ ${board.likeCount}  💬 ${board.commentCount}'),
                        ),
                        const SizedBox(height: 20),
                        _buildCommentList(board.comments),
                        const SizedBox(height: 30),
                        if (isAuthor) _buildAuthorButtons(board),
                      ],
                    ),
                  );
                },
              ),
            ),
            _buildCommentInputField(),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentList(List<Comment> comments) {
    if (comments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: Center(child: Text("아직 댓글이 없습니다.")),
      );
    }
    return Column(
      children: comments.map((comment) => _buildCommentItem(comment)).toList(),
    );
  }

  Widget _buildCommentItem(Comment comment) {
    bool isEditing = editingCommentId == comment.commentId;
    bool isMyComment = comment.userName == currentUserId;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(comment.userId, style: const TextStyle(fontWeight: FontWeight.bold)),
              if (isMyComment)
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () {
                        setState(() {
                          editingCommentId = comment.commentId;
                          _editingController.text = comment.content;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('댓글 삭제'),
                            content: const Text('댓글을 삭제하시겠습니까?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
                              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('삭제')),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          final success = await deleteComment(comment.commentId);
                          if (success && mounted) {
                            _refreshData();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('댓글이 삭제되었습니다.')));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('댓글 삭제 실패')));
                          }
                        }
                      },
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 4),
          isEditing
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _editingController,
                autofocus: true,
                maxLines: null,
                onSubmitted: (_) => _updateComment(comment.commentId),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _updateComment(comment.commentId),
                child: const Text('수정 완료'),
              ),
            ],
          )
              : Text(comment.content),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.favorite_border, size: 16, color: Colors.red),
              const SizedBox(width: 4),
              Text('${comment.likeCount}'),
            ],
          ),
        ],
      ),
    );
  }




  Widget _buildAuthorButtons(BoardDetail board) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditBoardPage(
                  boardId: board.boardId,
                  event: board.event,
                  category: board.category,
                  userId: board.userId,
                ),
              ),
            );
            if (result == true) _refreshData();
          },
          child: const Text('수정'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('게시글 삭제'),
                content: const Text('정말 삭제하시겠습니까?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
                  TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('삭제')),
                ],
              ),
            );
            if (confirmed == true) {
              final success = await deleteBoard(widget.boardId);
              if (mounted && success) {
                Navigator.pop(context, true);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('게시글이 삭제되었습니다.')));
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('삭제 실패')));
              }
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('삭제'),
        ),
      ],
    );
  }

  Widget _buildCommentInputField() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: const InputDecoration(hintText: '댓글 추가...', border: InputBorder.none),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _submitComment(),
            ),
          ),
          IconButton(icon: const Icon(Icons.send), onPressed: _submitComment),
        ],
      ),
    );
  }
}