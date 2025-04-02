import 'package:flutter/material.dart';
import 'package:project/chat/chat_main.dart';


class MainPage extends StatelessWidget {
  const MainPage({super.key});
 
  @override
  Widget build(BuildContext context) {
    // 텍스트필드 컨트롤러
    TextEditingController textEditingController = TextEditingController();
 
    return Scaffold(
      body: Center(
        child: Container(
          width: 250,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.grey,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 유저 이름 입력
              SizedBox(
                width: 200,
                child: TextField(
                  controller: textEditingController,
                  decoration: const InputDecoration(
                    label: Center(child: Text("사용자 이름 입력")),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  String txtValue = textEditingController.text;
                  txtValue = txtValue.trim();
                  if (txtValue != "") {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return ChatMainPage(
                        username: txtValue,
                      );
                    }));
                  }
                },
                child: const Text("확인"),
              )
            ],
          ),
        ),
      ),
    );
  }
}