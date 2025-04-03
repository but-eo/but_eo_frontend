import 'package:stomp_dart_client/stomp_dart_client.dart';

late StompClient stompClient; // `late`로 선언

void connectWebSocket() {
  stompClient = StompClient( // 여기서 초기화
    config: StompConfig(
      url: 'ws://192.168.45.179:714/ws',
      onConnect: (StompFrame frame) {
        print('WebSocket 연결 성공!');

        // 메시지 구독
        stompClient.subscribe(
          destination: '/all',
          callback: (frame) {
            print('받은 메시지: ${frame.body}');
          },
        );
      },
      onWebSocketError: (dynamic error) => print('WebSocket 에러: $error'),
    ),
  );

  stompClient.activate(); // WebSocket 연결 시작
}

// 메시지 보내기
void sendMessage(String sender, String content) {
  stompClient.send(
    destination: '/app/chat',
    body: '{"sender": "$sender", "content": "$content"}',
  );
}