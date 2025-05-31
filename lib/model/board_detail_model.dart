class BoardDetail {
  final String boardId;
  final String title;
  final String content;
  final String state;
  final String category;
  final String event;
  final String userName;
  final String userId;
  final List<String> fileUrls;
  final int likeCount;
  final int commentCount;
  final String createdAt;
  final String updatedAt;

  BoardDetail({
    required this.boardId,
    required this.title,
    required this.content,
    required this.state,
    required this.category,
    required this.event,
    required this.userName,
    required this.userId,
    required this.fileUrls,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BoardDetail.fromJson(Map<String, dynamic> json) {
    return BoardDetail(
      boardId: json['boardId'],
      title: json['title'],
      content: json['content'],
      state: json['state'],
      category: json['category'],
      event: json['event'],
      userName: json['userName'],
      userId: json['userHashId'] ?? '',
      fileUrls: List<String>.from(json['fileUrls']),
      likeCount: json['likeCount'],
      commentCount: json['commentCount'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

