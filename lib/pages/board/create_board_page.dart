// lib/pages/board/create_board_page.dart

import 'package:flutter/material.dart';
import 'package:project/service/board_api_post_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateBoardPage extends StatefulWidget {
  final String initialEvent;
  final String initialCategory;

  CreateBoardPage({required this.initialEvent, required this.initialCategory});

  @override
  _CreateBoardPageState createState() => _CreateBoardPageState();
}

class _CreateBoardPageState extends State<CreateBoardPage> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String content = '';
  late String selectedEvent;
  late String selectedCategory;


  @override
  void initState() {
    super.initState();
    selectedEvent = widget.initialEvent;
    selectedCategory = widget.initialCategory;
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  void submitPost() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final userName = await getUserName();
      if (userName == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 정보가 없습니다.')),
        );
        return;
      }

      final success = await createBoardPost(
        title: title,
        content: content,
        event: convertSportToEventEnum(selectedEvent),
        category: convertCategoryToEnum(selectedCategory),
        userId: userName,
      );

      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('게시글 작성 실패')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('게시글 작성')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: '제목'),
                onSaved: (val) => title = val ?? '',
                validator: (val) => val == null || val.isEmpty ? '제목을 입력하세요' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(labelText: '내용'),
                maxLines: 5,
                onSaved: (val) => content = val ?? '',
                validator: (val) => val == null || val.isEmpty ? '내용을 입력하세요' : null,
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: submitPost,
                child: Text('작성 완료'),
              ),
            ],
          ),
        ),
      ),
    );
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
}
