// lib/pages/board/board_detail_page.dart
import 'package:flutter/material.dart';
import 'package:project/contants/api_contants.dart'; // imageBaseUrl 사용을 위해 import
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
  // ... (다른 변수 및 메소드들은 이전과 동일) ...
  String? currentUserId;
  late Future<BoardDetail> futureBoardDetail;
  final _commentController = TextEditingController();

  String? _editingCommentId;
  final _editingCommentController = TextEditingController();

  final Color _scaffoldBgColor = const Color(0xFFF4F6F8);
  final Color _appBarBgColor = Colors.white;
  final Color _cardBgColor = Colors.white;
  final Color _primaryTextColor = const Color(0xFF2C3E50);
  final Color _secondaryTextColor = const Color(0xFF7F8C8D);
  final Color _accentColor = const Color(0xFF3498DB);
  final Color _inputBorderColor = Colors.grey.shade300;
  final Color _iconColor = const Color(0xFF566573);

  bool _isBoardLiked = false;
  int _boardLikeCount = 0;


  @override
  void initState() {
    super.initState();
    _loadBoardData();
    _loadUserId();

  }

  void _loadBoardData() async {
    futureBoardDetail = fetchBoardDetail(widget.boardId);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    futureBoardDetail = fetchBoardDetail(widget.boardId).then((board) async {
      bool liked = false;
      if (token != null) {
        liked = await fetchIsBoardLiked(widget.boardId, token);
      }

      if (mounted) {
        setState(() {
          _isBoardLiked = liked;
          _boardLikeCount = board.likeCount;
        });
      }
      return board;
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _editingCommentController.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        currentUserId = prefs.getString('userId');
      });
    }
  }

  Future<void> _refreshData() async {
    if (mounted) {
      final refreshedBoard = await fetchBoardDetail(widget.boardId);
      setState(() {
        futureBoardDetail = Future.value(refreshedBoard);
        _boardLikeCount = refreshedBoard.likeCount;
      });
    }
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('댓글 내용을 입력해주세요.'), duration: Duration(seconds: 2)),
      );
      return;
    }
    final success = await createComment(
      boardId: widget.boardId,
      content: _commentController.text,
    );
    if (mounted) {
      if (success) {
        _commentController.clear();
        FocusScope.of(context).unfocus();
        _refreshData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('댓글이 등록되었습니다.'), duration: Duration(seconds: 2)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('댓글 등록에 실패했습니다.')));
      }
    }
  }

  void _startEditComment(Comment comment) {
    if (mounted) {
      setState(() {
        _editingCommentId = comment.commentId;
        _editingCommentController.text = comment.content;
      });
    }
  }

  Future<void> _submitEditComment() async {
    if (_editingCommentId == null || _editingCommentController.text.trim().isEmpty) return;
    final success = await updateComment(
      commentId: _editingCommentId!,
      content: _editingCommentController.text.trim(),
    );
    if (mounted) {
      if (success) {
        setState(() { _editingCommentId = null; _editingCommentController.clear(); });
        _refreshData();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('댓글이 수정되었습니다.')),);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('댓글 수정에 실패했습니다.')));
      }
    }
  }

  void _cancelEditComment() {
    if (mounted) setState(() { _editingCommentId = null; _editingCommentController.clear(); });
  }

  Future<void> _deleteComment(String commentId) async {
    final confirmed = await _showConfirmationDialog('댓글 삭제', '정말 이 댓글을 삭제하시겠습니까?');
    if (confirmed == true) {
      final success = await deleteComment(commentId);
      if (mounted) {
        if (success) {
          _refreshData();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('댓글이 삭제되었습니다.')),);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('댓글 삭제에 실패했습니다.')));
        }
      }
    }
  }

  Future<void> _deleteBoardDialog(String boardId) async {
    final confirmed = await _showConfirmationDialog(
        '게시글 삭제 확인',
        '정말 이 게시글을 삭제하시겠습니까?\n삭제된 게시글은 복구할 수 없습니다.'
    );

    if (confirmed == true) {
      final success = await deleteBoard(boardId);
      if (mounted) {
        if (success) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('게시글이 삭제되었습니다.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('게시글 삭제에 실패했습니다.')),
          );
        }
      }
    }
  }

  void _toggleBoardLike() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) return;

    try {
      await toggleBoardLike(widget.boardId, token);
      setState(() {
        _isBoardLiked = !_isBoardLiked;
        _isBoardLiked ? _boardLikeCount++ : _boardLikeCount--;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isBoardLiked ? '게시글을 좋아합니다.' : '게시글 좋아요를 취소했습니다.'),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('좋아요 처리 중 오류 발생')),
      );
    }
  }

  Future<bool?> _showConfirmationDialog(String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: _primaryTextColor, fontSize: 18)),
        content: Text(content, style: TextStyle(color: _secondaryTextColor, fontSize: 15, height: 1.4)),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('취소', style: TextStyle(color: _secondaryTextColor, fontSize: 14.5)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(title.contains("삭제") ? '삭제' : '확인', style: TextStyle(color: Colors.red.shade600, fontWeight: FontWeight.bold, fontSize: 14.5)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: _scaffoldBgColor,
      appBar: AppBar(
        title: Text("게시글", style: TextStyle(color: _primaryTextColor, fontWeight: FontWeight.bold, fontSize: 19)),
        backgroundColor: _appBarBgColor,
        elevation: 0.8,
        iconTheme: IconThemeData(color: _primaryTextColor),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<BoardDetail>(
              future: futureBoardDetail,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: _accentColor));
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return _buildErrorStateWidget(snapshot.error);
                }

                final board = snapshot.data!;
                final isAuthor = board.userId == currentUserId;

                return RefreshIndicator(
                  onRefresh: _refreshData,
                  color: _accentColor,
                  backgroundColor: _cardBgColor,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBoardContentSection(context, board, isAuthor),
                        Container(
                          color: _cardBgColor,
                          margin: const EdgeInsets.only(top:8.0),
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "댓글 ${board.comments.length}",
                                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: _primaryTextColor),
                              ),
                              const SizedBox(height: 12),
                              Divider(color: Colors.grey.shade200, height: 1),
                              _buildCommentListSection(context, board.comments),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          _buildCommentInputSection(),
        ],
      ),
    );
  }

  Widget _buildErrorStateWidget(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, color: _secondaryTextColor.withOpacity(0.6), size: 60),
            const SizedBox(height: 16),
            Text('게시글 정보를 불러오지 못했습니다.', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: _primaryTextColor)),
            const SizedBox(height: 8),
            Text(error?.toString() ?? '알 수 없는 오류가 발생했습니다.', style: TextStyle(fontSize: 14, color: _secondaryTextColor, height: 1.4), textAlign: TextAlign.center,),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text("다시 시도", style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: _refreshData,
              style: ElevatedButton.styleFrom(
                  backgroundColor: _accentColor, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
              ),
            )
          ],
        ),
      ),
    );
  }


  Widget _buildBoardContentSection(BuildContext context, BoardDetail board, bool isAuthor) {
    int displayLikeCount = _boardLikeCount;

    return Container(
      color: _cardBgColor,
      padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  board.title,
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: _primaryTextColor, height: 1.3),
                ),
              ),
              if (isAuthor)
                SizedBox(
                  height: 40, width: 40,
                  child: PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert_rounded, color: _secondaryTextColor, size: 24),
                    onSelected: (value) async {
                      if (value == 'edit') {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditBoardPage(
                              boardId: board.boardId, event: board.event,
                              category: board.category, userId: board.userId,
                            ),
                          ),
                        );
                        if (result == true && mounted) _refreshData();
                      } else if (value == 'delete') {
                        _deleteBoardDialog(board.boardId);
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(value: 'edit', height: 44, child: Row(children: [Icon(Icons.edit_note_rounded, size: 20, color: _iconColor), const SizedBox(width: 10), const Text('수정')])),
                      PopupMenuItem<String>(value: 'delete', height: 44, child: Row(children: [Icon(Icons.delete_forever_rounded, size: 20, color: Colors.red.shade600), const SizedBox(width: 10), Text('삭제', style: TextStyle(color: Colors.red.shade600))])),
                    ],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    tooltip: "게시글 옵션",
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              CircleAvatar(radius: 20, backgroundColor: _scaffoldBgColor, child: Icon(Icons.person_rounded, size: 22, color: _secondaryTextColor)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(board.userName, style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold, color: _primaryTextColor)),
                  Text(_formatDateTime(board.createdAt), style: TextStyle(fontSize: 13, color: _secondaryTextColor.withOpacity(0.9))),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Text(
              board.content,
              style: TextStyle(fontSize: 16, color: _primaryTextColor.withOpacity(0.95), height: 1.7, letterSpacing: 0.2),
            ),
          ),
          Divider(color: Colors.grey.shade200, thickness: 1),
          Padding(
            padding: const EdgeInsets.only(top: 14.0, bottom: 4.0),
            child: Row(
              children: [
                InkWell(
                  onTap: _toggleBoardLike,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Icon(
                          _isBoardLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          size: 22,
                          color: _isBoardLiked ? Colors.red.shade500 : _iconColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          displayLikeCount.toString(),
                          style: TextStyle(fontSize: 14.5, color: _secondaryTextColor, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    Icon(Icons.chat_bubble_outline_rounded, size: 20, color: _iconColor),
                    const SizedBox(width: 6),
                    Text(
                      board.comments.length.toString(),
                      style: TextStyle(fontSize: 14.5, color: _secondaryTextColor, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentListSection(BuildContext context, List<Comment> comments) {
    if (comments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 16.0),
        child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.forum_outlined, size: 50, color: _secondaryTextColor.withOpacity(0.5)),
                const SizedBox(height: 16),
                Text("아직 댓글이 없습니다.", style: TextStyle(fontSize: 16.5, color: _secondaryTextColor, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text("첫 댓글을 작성하여 대화를 시작해보세요!", style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
              ],
            )),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal:0),
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        return _buildCommentItem(context, comment);
      },
      separatorBuilder: (context, index) => Divider(color: Colors.grey.shade200, height: 0.5, indent: 16, endIndent: 16),
    );
  }

  // ***** 프로필 사진 표시 로직이 추가된 위젯 *****
  Widget _buildCommentItem(BuildContext context, Comment comment) {
    final bool isMyComment = comment.userId == currentUserId;
    final bool isCurrentlyEditing = _editingCommentId == comment.commentId;

    // 1. 프로필 이미지 URL 생성 로직 추가
    String? commentAuthorProfileUrl;
    if (comment.profileImageUrl != null && comment.profileImageUrl!.isNotEmpty) {
      // 서버에서 내려온 값이 전체 URL인지, 아니면 경로만인지에 따라 분기 처리
      if (comment.profileImageUrl!.startsWith("http")) {
        commentAuthorProfileUrl = comment.profileImageUrl;
      } else {
        // ApiConstants에 정의된 imageBaseUrl을 사용하여 전체 URL 생성
        commentAuthorProfileUrl = "${ApiConstants.imageBaseUrl}${comment.profileImageUrl}";
      }
    }

    return Container(
      color: _cardBgColor,
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 2. CircleAvatar 수정
          CircleAvatar(
            radius: 19,
            backgroundColor: _scaffoldBgColor,
            backgroundImage: commentAuthorProfileUrl != null ? NetworkImage(commentAuthorProfileUrl) : null,
            child: commentAuthorProfileUrl == null
                ? Icon(Icons.account_circle_rounded, size: 22, color: _secondaryTextColor)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        comment.userName,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: _primaryTextColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(_formatDateTime(comment.createdAt, short: true), style: TextStyle(fontSize: 12.5, color: _secondaryTextColor)),
                    const Spacer(),
                    if (isMyComment && !isCurrentlyEditing)
                      SizedBox(
                        height: 32, width: 32,
                        child: PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.more_vert_rounded, size: 20, color: _secondaryTextColor),
                          onSelected: (value) {
                            if (value == 'edit') _startEditComment(comment);
                            if (value == 'delete') _deleteComment(comment.commentId);
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(value: 'edit', height: 42, child: Row(children:[Icon(Icons.edit_rounded, size: 18, color: _iconColor), const SizedBox(width:10), const Text('수정')])),
                            PopupMenuItem(value: 'delete', height: 42, child: Row(children:[Icon(Icons.delete_rounded, size: 18, color: Colors.red.shade600), const SizedBox(width:10), Text('삭제', style: TextStyle(color: Colors.red.shade600))])),
                          ],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          tooltip: "댓글 관리",
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                isCurrentlyEditing
                    ? _buildEditCommentFieldWidget()
                    : Text(comment.content, style: TextStyle(fontSize: 15, color: _primaryTextColor.withOpacity(0.95), height: 1.6, letterSpacing: 0.1)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditCommentFieldWidget() {
    return Container(
      padding: const EdgeInsets.only(top: 6.0, bottom: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _editingCommentController,
            autofocus: true,
            maxLines: null,
            style: TextStyle(fontSize: 15, color: _primaryTextColor, height: 1.5),
            decoration: InputDecoration(
              hintText: "댓글 수정...",
              hintStyle: TextStyle(color: _secondaryTextColor.withOpacity(0.7), fontSize: 14.5),
              filled: true,
              fillColor: _scaffoldBgColor,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: _inputBorderColor.withOpacity(0.8)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: _inputBorderColor.withOpacity(0.8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: _accentColor, width: 1.5),
              ),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submitEditComment(),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _cancelEditComment,
                style: TextButton.styleFrom(
                  foregroundColor: _secondaryTextColor,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('취소', style: TextStyle(fontWeight: FontWeight.w500)),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: const Text('수정 완료'),
                onPressed: _submitEditComment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInputSection() {
    return Container(
      padding: EdgeInsets.only(
        left: 16, right: 10, top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: _appBarBgColor,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              style: TextStyle(fontSize: 15, color: _primaryTextColor),
              decoration: InputDecoration(
                hintText: '따뜻한 댓글을 남겨주세요 :)',
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(color: _accentColor, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                isDense: true,
                fillColor: _scaffoldBgColor,
                filled: true,
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _submitComment(),
              minLines: 1,
              maxLines: 5,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.send_rounded, color: _accentColor, size: 28),
            onPressed: _submitComment,
            splashRadius: 26,
            tooltip: "댓글 전송",
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String dateTimeString, {bool short = false}) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeString).toLocal();
      DateTime now = DateTime.now();
      Duration diff = now.difference(dateTime);

      if (diff.inMicroseconds < 0) return "방금 전";

      if (diff.inDays == 0) {
        if (diff.inHours < 1) {
          if (diff.inMinutes < 1) return '방금 전';
          return '${diff.inMinutes}분 전';
        }
        return '${diff.inHours}시간 전';
      } else if (diff.inDays == 1 || (diff.inHours < 24 && now.day != dateTime.day)) {
        return '어제';
      } else if (now.year == dateTime.year && short) {
        return '${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')}';
      }
      return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString;
    }
  }
}