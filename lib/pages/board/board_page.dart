import 'package:flutter/material.dart';
import 'package:project/model/board_model.dart';
import 'package:project/pages/board/board_detail_page.dart';
import 'package:project/pages/board/create_board_page.dart';
import 'package:project/service/board_api_get_service.dart';

class BoardPage extends StatefulWidget {
  final String event;
  final String category;

  BoardPage({required this.event, required this.category});

  @override
  _BoardPageState createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  late Future<List<Board>> boardFuture;

  @override
  void initState() {
    super.initState();
    boardFuture = fetchBoardList();
  }

  Future<List<Board>> fetchBoardList() {
    final eventEnum = convertSportToEventEnum(widget.event);
    final categoryEnum = convertCategoryToEnum(widget.category);
    return fetchBoards(eventEnum, categoryEnum);
  }

  void refreshBoardList() async {
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      boardFuture = fetchBoardList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.event} ${widget.category}')),
      body: FutureBuilder<List<Board>>(
        future: boardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('에러: ${snapshot.error}'));
          }
          final boards = snapshot.data!;
          return ListView.builder(
            itemCount: boards.length,
            itemBuilder: (context, index) {
              final board = boards[index];
              return GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BoardDetailPage(boardId: board.boardId),
                    ),
                  );

                  if (result == true) {
                    refreshBoardList(); // 🔥 핵심
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(board.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(board.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('작성자: ${board.userName}', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                              Text(_formatDate(board.createdAt), style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('❤️ ${board.likeCount}  💬 ${board.commentCount}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateBoardPage(
                initialEvent: widget.event,
                initialCategory: widget.category,
              ),
            ),
          );

          if (result == true) {
            refreshBoardList(); // 작성 성공 시 목록 새로고침
          }
        },
        child: Icon(Icons.edit),
        tooltip: '게시글 작성',
      ),
    );
  }
}

String convertSportToEventEnum(String sport) {
  switch (sport) {
    case '축구': return 'SOCCER';
    case '풋살': return 'FUTSAL';
    case '야구': return 'BASEBALL';
    case '농구': return 'BASKETBALL';
    case '배드민턴': return 'BADMINTON';
    case '테니스': return 'TENNIS';
    case '탁구': return 'TABLE_TENNIS';
    case '볼링': return 'BOWLING';
    default: throw Exception('Unknown sport: $sport');
  }
}

String convertCategoryToEnum(String category) {
  switch (category) {
    case '자유게시판': return 'FREE';
    case '후기게시판': return 'REVIEW';
    case '팀찾기게시판': return 'TEAM';
    case '팀원찾기게시판': return 'MEMBER';
    case '경기장게시판': return 'NOTIFICATION';
    default: throw Exception('Unknown category: $category');
  }
}

String _formatDate(DateTime dateTime) {
  return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')}';
}
