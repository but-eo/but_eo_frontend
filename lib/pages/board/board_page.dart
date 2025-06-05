// lib/pages/board/board_page.dart
import 'package:flutter/material.dart';
import 'package:project/model/board_model.dart';
import 'package:project/pages/board/board_detail_page.dart';
import 'package:project/pages/board/create_board_page.dart';
import 'package:project/service/board_api_get_service.dart';

class BoardPage extends StatefulWidget {
  final String event;
  final String category;

  const BoardPage({super.key, required this.event, required this.category});

  @override
  _BoardPageState createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  late Future<List<Board>> boardFuture;

  final Color _scaffoldBgColor = Colors.grey.shade200;
  final Color _appBarBgColor = Colors.white;
  final Color _primaryTextColor = Colors.black87;
  final Color _secondaryTextColor = Colors.grey.shade700;
  final Color _accentColor = Colors.blue.shade700;
  final Color _cardBgColor = Colors.white;

  @override
  void initState() {
    super.initState();
    boardFuture = _fetchBoardList();
  }

  Future<List<Board>> _fetchBoardList() {
    final eventEnumString = _convertSportToEventEnum(widget.event);
    final categoryEnumString = _convertCategoryToEnum(widget.category);
    return fetchBoards(eventEnumString, categoryEnumString);
  }

  Future<void> _refreshBoardList() async {
    if (mounted) {
      setState(() {
        boardFuture = _fetchBoardList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffoldBgColor,
      appBar: AppBar(
        title: Text('${widget.event} - ${widget.category}', style: TextStyle(color: _primaryTextColor, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: _appBarBgColor,
        elevation: 1.0,
        iconTheme: IconThemeData(color: _primaryTextColor),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<List<Board>>(
        future: boardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: _accentColor));
          }
          if (snapshot.hasError) {
            return _buildErrorState();
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final boards = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refreshBoardList,
            color: _accentColor,
            backgroundColor: _cardBgColor,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 80.0),
              itemCount: boards.length,
              itemBuilder: (context, index) {
                final board = boards[index];
                return _buildBoardListItem(context, board);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
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
          if (result == true && mounted) {
            _refreshBoardList();
          }
        },
        backgroundColor: _accentColor,
        icon: const Icon(Icons.edit_square, color: Colors.white, size: 20),
        label: const Text('새 글 작성', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildBoardListItem(BuildContext context, Board board) {
    final String contentPreview = board.content.length > 80
        ? '${board.content.substring(0, 80)}...'
        : board.content;

    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: _cardBgColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BoardDetailPage(boardId: board.boardId),
            ),
          );
          if (result == true && mounted) {
            _refreshBoardList();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                board.title,
                style: TextStyle(fontSize: 17.5, fontWeight: FontWeight.bold, color: _primaryTextColor),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                contentPreview,
                style: TextStyle(fontSize: 14.5, color: _secondaryTextColor, height: 1.45),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person_outline_rounded, size: 15, color: _secondaryTextColor),
                      const SizedBox(width: 5),
                      Text(
                        board.userName,
                        style: TextStyle(fontSize: 12.5, color: _secondaryTextColor),
                      ),
                      const Text(" · ", style: TextStyle(fontSize: 12.5, color: Colors.grey)),
                      Text(
                        _formatDate(board.createdAt),
                        style: TextStyle(fontSize: 12.5, color: _secondaryTextColor),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.thumb_up_alt_outlined, size: 14, color: Colors.red.shade300),
                      const SizedBox(width: 4),
                      Text(board.likeCount.toString(), style: TextStyle(fontSize: 13, color: _secondaryTextColor)),
                      const SizedBox(width: 12),
                      Icon(Icons.chat_bubble_outline_rounded, size: 14, color: Colors.blue.shade300),
                      const SizedBox(width: 4),
                      Text(board.commentCount.toString(), style: TextStyle(fontSize: 13, color: _secondaryTextColor)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.red.shade400, size: 60),
            const SizedBox(height: 16),
            Text('오류 발생', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryTextColor)),
            const SizedBox(height: 8),
            Text('게시글을 불러오는 중 문제가 발생했습니다.\n잠시 후 다시 시도해주세요.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: _secondaryTextColor, height: 1.5),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text("새로고침", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              onPressed: _refreshBoardList,
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentColor, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.forum_rounded, size: 70, color: _secondaryTextColor.withOpacity(0.5)),
              const SizedBox(height: 20),
              Text('게시글이 아직 없습니다.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryTextColor)),
              const SizedBox(height: 10),
              Text(
                '이 카테고리의 첫 번째 게시글을 작성하여\n다른 사용자들과 소통을 시작해보세요!',
                style: TextStyle(fontSize: 15, color: _secondaryTextColor, height: 1.5),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        )
    );
  }
}

// API Enum 변환 함수 (실제 API 명세에 맞게 Enum 값 확인 및 수정 필요)
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

String _formatDate(DateTime dateTime) {
  DateTime now = DateTime.now();
  Duration diff = now.difference(dateTime);

  if (diff.inDays >= 1) {
    if (diff.inDays > 365) { // 1년 이상 전이면 년도까지 표시
      return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')}';
    }
    return '${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')}';
  } else if (diff.inHours >= 1) {
    return '${diff.inHours}시간 전';
  } else if (diff.inMinutes >= 1) {
    return '${diff.inMinutes}분 전';
  } else {
    return '방금 전';
  }
}