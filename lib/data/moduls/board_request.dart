// 요청에 담을 데이터 모델

class BoardRequest {
  final String title;
  final String content;

  BoardRequest({
    required this.title,
    required this.content,
  });



  Map<String, dynamic> toJson() {
    return {
      'title' : title,
      'content' : content,
    };
  }
}