import 'package:flutter/material.dart';
import 'package:project/model/board_detail_model.dart';
import 'package:project/model/board_comment_model.dart';
import 'package:project/pages/board/Edit_Board_Page.dart';
import 'package:project/service/board_api_get_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BoardDetailPage extends StatefulWidget {
  final String boardId;

  const BoardDetailPage({super.key, required this.boardId});

  @override
  State<BoardDetailPage> createState() => _BoardDetailPageState();
}

class _BoardDetailPageState extends State<BoardDetailPage> {
  String? currentUserId;
  late Future<BoardDetail> futureBoard;

  @override
  void initState() {
    super.initState();
    futureBoard = fetchBoardDetail(widget.boardId);
    loadUserId();
  }

  Future<void> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    setState(() {
      currentUserId = userId;
    });
  }

  void refreshBoard() {
    setState(() {
      futureBoard = fetchBoardDetail(widget.boardId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("게시글")),
      body: FutureBuilder<BoardDetail>(
        future: futureBoard,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("에러 발생: ${snapshot.error}"));
          }

          final board = snapshot.data!;
          final isAuthor = board.userId == currentUserId;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Text(
                  board.title,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  board.content,
                  style: const TextStyle(fontSize: 16),
                ),
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
                FutureBuilder<List<Comment>>(
                  future: fetchComments(widget.boardId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text("댓글을 불러오는 중 오류 발생: \${snapshot.error}");
                    }

                    final comments = snapshot.data!;
                    if (comments.isEmpty) return Text("아직 댓글이 없습니다.");

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: comments.map((comment) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white70,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  comment.userName ?? '알 수 없음',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                SizedBox(height: 4),
                                Text(comment.content ?? '', style: TextStyle(fontSize: 13)),
                                SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      comment.createdAt?.split('T').first ?? '',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                    Text(
                                      '❤️ ${comment.likeCount}',
                                      style: TextStyle(fontSize: 12, color: Colors.redAccent),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 30),
                if (isAuthor)
                  Row(
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
                          if (result == true) {
                            Navigator.pop(context, true);
                          }

                        },
                        child: Text('수정'),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('게시글 삭제'),
                              content: Text('정말 삭제하시겠습니까?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text('취소'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text('삭제'),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            final success = await deleteBoard(widget.boardId);
                            if (success) {
                              Navigator.pop(context, true); // 리스트 페이지로 돌아가기
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('게시글이 삭제되었습니다.')),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('삭제 실패')),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: Text('삭제'),
                      ),
                    ],
                  )
              ],
            ),
          );
        },
      ),
    );
  }
}
