import 'package:flutter/material.dart';
import 'package:project/service/board_api_post_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateBoardPage extends StatefulWidget {
  @override
  _CreateBoardPageState createState() => _CreateBoardPageState();
}

class _CreateBoardPageState extends State<CreateBoardPage> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String content = '';
  String selectedEvent = 'SOCCER';
  String selectedCategory = 'FREE';
  String? userName;

  final List<String> events = ['SOCCER', 'FUTSAL', 'BASKETBALL', 'BASEBALL'];
  final List<String> categories = ['FREE', 'REVIEW', 'TEAM', 'MEMBER'];

  @override
  void initState() {
    super.initState();
    loadUserName();
  }

  Future<void> loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('userId');
    setState(() {
      userName = name;
    });
  }

  void submitPost() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (userName == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 정보가 없습니다.')),
        );
        return;
      }

      final success = await createBoardPost(
        title: title,
        content: content,
        event: selectedEvent,
        category: selectedCategory,
        userId: userName!,
      );

      if (success) {
        Navigator.pop(context);
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
      body: userName == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: '제목'),
                onSaved: (val) => title = val ?? '',
                validator: (val) =>
                val == null || val.isEmpty ? '제목을 입력하세요' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(labelText: '내용'),
                maxLines: 5,
                onSaved: (val) => content = val ?? '',
                validator: (val) =>
                val == null || val.isEmpty ? '내용을 입력하세요' : null,
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedEvent,
                decoration: InputDecoration(labelText: '종목'),
                items: events
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => selectedEvent = val!),
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(labelText: '카테고리'),
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => setState(() => selectedCategory = val!),
              ),
              SizedBox(height: 20),
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
}
