
class Comment {
  final String commentId;
  final String userName; // 실제 사용자 이름이 담길 변수
  final String userId;   // 실제 사용자 ID(UUID)가 담길 변수
  final String content;
  final String createdAt;
  final int likeCount;
  final String? profileImageUrl; // ✨ 1. 프로필 이미지 URL을 위한 필드 추가

  Comment({
    required this.commentId,
    required this.userName,
    required this.userId,
    required this.content,
    required this.createdAt,
    required this.likeCount,
    this.profileImageUrl, // ✨ 2. 생성자에 추가
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    // 💡 참고: 서버의 `BoardService.java`를 보면 아직 userName과 userHashId가 바뀌어 전달되고 있습니다.
    // 따라서 클라이언트에서 이를 바로잡는 임시 로직을 유지합니다.
    // 만약 서버에서 이 부분이 함께 수정되었다면, 아래 userName과 userId 할당 부분을 원래대로 되돌려야 합니다.
    // (원래 예상: userName: json['userName'], userId: json['userHashId'])
    return Comment(
      commentId: json['commentId'] ?? '',
      userName: json['userHashId'] ?? '[이름 오류]', // 서버의 'userHashId' 키에 실제 이름이 담겨있음
      userId: json['userName'] ?? '',                // 서버의 'userName' 키에 실제 사용자 ID(UUID)가 담겨있음
      content: json['content'] ?? '',
      createdAt: json['createdAt'] ?? '',
      likeCount: json['likeCount'] ?? 0,
      // ✨ 3. 새로 추가된 프로필 이미지 필드 매핑
      profileImageUrl: json['profileImg'],
    );
  }
}