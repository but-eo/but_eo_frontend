import 'package:flutter/material.dart';
import 'package:project/model/board_detail_model.dart';
import 'package:project/model/board_comment_model.dart';
import 'package:project/service/board_api_service.dart';


class BoardDetailPage extends StatelessWidget {
  final String boardId;

  const BoardDetailPage({super.key, required this.boardId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("게시글 상세보기")),
      body: FutureBuilder<BoardDetail>(
        future: fetchBoardDetail(boardId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("에러 발생: ${snapshot.error}"));
          }

          final board = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                /// 제목
                Text(
                  board.title,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                /// 내용
                Text(
                  board.content,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),

                /// 작성자 & 날짜
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('작성자: ${board.userName}', style: TextStyle(color: Colors.grey[700])),
                    Text(board.createdAt.split('T')[0], style: TextStyle(color: Colors.grey[700])),
                  ],
                ),

                const Divider(height: 30),

                /// 좋아요 및 댓글 수
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('❤️ ${board.likeCount}  💬 ${board.commentCount}'),
                ),

                const SizedBox(height: 20),

                /// 댓글 목록
                FutureBuilder<List<Comment>>(
                  future: fetchComments(boardId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text("댓글을 불러오는 중 오류 발생: ${snapshot.error}");
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
                                Text(
                                  comment.content ?? '',
                                  style: TextStyle(fontSize: 13),
                                ),
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
                )
              ],
            ),
          );
        },
      ),
    );
  }
}