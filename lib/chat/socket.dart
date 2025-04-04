import 'dart:convert';
import 'dart:io';
 
class FlutterWebSocket {
  List messageList = [];
  String SERVER = "ws://192.168.0.111:3000";
 
  // 웹 소켓 서버 연결
  Future<WebSocket> getSocket()  async {
    WebSocket socket = await WebSocket.connect(SERVER);
    return socket;
  }
 
  // 소켓 서버에 데이터 송신
  addMessage(socket, username, message, type) {
    Map<String, dynamic> data = {
      'username': username,
      'message': message,
      'type': type,
      // [type]
      //    - init    :   클라이언트 접속 정보 초기화
      //    - all     :   모든 클라이언트에게 메시지 전송
      //    - whisper|username :   특정 클라이언트에게 메시지 전송
    };
    print("[socket.dart] 메시지 전송 : $username : $message");
    socket?.add(jsonEncode(data));
  }
}