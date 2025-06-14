class Board {
  final String boardId;
  final String title;
  final String userName;
  final String content;
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;
  final bool isLiked;

  Board({
    required this.boardId,
    required this.title,
    required this.userName,
    required this.content,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
    required this.isLiked,
  });

  factory Board.fromJson(Map<String, dynamic> json) {
    print(json['liked']);

    return Board(
      boardId: json['boardId'].toString(),
      title: json['title'] ?? '',
      userName: json['userName'],
      content: json['content'] ?? '',
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      isLiked: json['liked'] ?? false,
    );
  }
}