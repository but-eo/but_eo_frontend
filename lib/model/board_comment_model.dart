// lib/model/board_comment_model.dart

class Comment {
  final String commentId;
  final String userName; // 실제 사용자 이름이 담길 변수
  final String userId;   // 실제 사용자 ID(UUID)가 담길 변수
  final String content;
  final String createdAt;
  final int likeCount;

  Comment({
    required this.commentId,
    required this.userName,
    required this.userId,
    required this.content,
    required this.createdAt,
    required this.likeCount,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    // --- 중요: 임시 클라이언트 측 수정 ---
    // 서버에서 userName과 userHashId의 값이 바뀌어 내려오고 있으므로,
    // 클라이언트에서 임시로 이를 바로잡아 파싱합니다.
    // TODO: 서버에서 CommentResponse의 userName과 userHashId 필드 값을 올바르게 내려주도록 수정한 후,
    //       아래 userName과 userId의 json['...'] 부분을 원래대로 되돌려야 합니다.
    //       (원래: userName: json['userName'], userId: json['userHashId'])
    return Comment(
      commentId: json['commentId'] ?? '',
      userName: json['userHashId'] ?? '[이름 오류]', // 서버의 'userHashId' 키에 실제 이름이 담겨있음
      userId: json['userName'] ?? '',         // 서버의 'userName' 키에 실제 사용자 ID(UUID)가 담겨있음
      content: json['content'] ?? '',
      createdAt: json['createdAt'] ?? '',
      likeCount: json['likeCount'] ?? 0,
    );
  }
}