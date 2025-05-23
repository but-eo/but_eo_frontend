class Comment {
  final String commentId;
  final String userName;
  final String content;
  final String createdAt;
  final int likeCount;

  Comment({
    required this.commentId,
    required this.userName,
    required this.content,
    required this.createdAt,
    required this.likeCount,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      commentId: json['commentId'] ?? '',
      userName: json['userName'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] ?? '',
      likeCount: json['likeCount'] ?? 0,
    );
  }
}