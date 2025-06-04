// lib/model/board_detail_model.dart

import 'package:project/model/board_comment_model.dart';

class BoardDetail {
  final String boardId;
  final String title;
  final String content;
  final String userId;
  final String userName;
  final String event;
  final String category;
  final int likeCount;
  final int commentCount;
  final String createdAt;
  final List<Comment> comments; // 서버 응답에 맞춰 댓글 목록 추가

  BoardDetail({
    required this.boardId,
    required this.title,
    required this.content,
    required this.userId,
    required this.userName,
    required this.event,
    required this.category,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
    required this.comments,
  });

  factory BoardDetail.fromJson(Map<String, dynamic> json) {
    // JSON의 'comments' 리스트를 Comment 객체 리스트로 변환
    var commentList = json['comments'] as List;
    List<Comment> comments = commentList.map((i) => Comment.fromJson(i)).toList();

    return BoardDetail(
      boardId: json['boardId'],
      title: json['title'],
      content: json['content'],
      userId: json['userHashId'], // 서버 DTO의 'userHashId' 필드 사용
      userName: json['userName'],
      event: json['event'],
      category: json['category'],
      likeCount: json['likeCount'],
      commentCount: json['commentCount'],
      createdAt: json['createdAt'],
      comments: comments, // 변환된 댓글 리스트 할당
    );
  }
}