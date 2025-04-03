import 'package:flutter/material.dart';
import 'package:project/pages/chatroompage.dart';
import 'package:project/widgets/image_slider_widgets.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(20.0), // ✅ 네모에서 둥근 모서리 설정
              child: Image.asset(
                'assets/images/Logo.png',
                width: 50.0, // 원하는 크기 조절
                height: 50.0,
                fit: BoxFit.cover, // 이미지를 잘 맞게 조정
              ),
            ),
            title: Text(
              '친구 ${index + 1}',
              style: TextStyle(fontWeight: FontWeight.w600),
            ), //채팅방에 포함된 유저 이름들
            subtitle: Text(
              '마지막 메시지 내용',
              style: TextStyle(color: Colors.grey),
            ), //채팅방 마지막 전송 메세지
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(height: 5.0),
                Text('오후 2:30', style: TextStyle(color: Colors.grey)),
                SizedBox(height: 5.0),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100.0),
                  child: Container(
                    //안읽은 수 넣고
                    child: Text(
                      '5',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                    height: 18.0,
                    width: 18.0,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ChatRoomPage(userName: '친구 ${index + 1}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
