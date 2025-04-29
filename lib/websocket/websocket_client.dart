import 'package:project/contants/api_contants.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

late StompClient stompClient; // `late`로 선언

void connectWebSocket() {

  stompClient = StompClient( //Spring WebSocket에서 STOMP 엔드포인트를 등록할 때 사용하는 클래스
    config: StompConfig( //Flutter에서 사용하는 클래스로 StompClient를 초기화 할 때 사용
      url: 'ws://${ApiConstants.serverUrl}:714/ws',
      onConnect: (StompFrame frame) { //Stomp 프로토콜로 주고받는 메시지를 표현한 클래스
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