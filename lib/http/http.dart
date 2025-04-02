import 'package:/flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

Future<Map<String, dynamic>> httpGet({required String path}) async { //http get 요청을 보내는 함수 정의
  //매개변수는 요청할 경로 -> path
  String baseUrl = 'https://reqres.in$path'; //http 요청을 보낼 기본 url을 나타내는 문자열 변수
  try {
    //여기서 에러 발생하면 503 업데이트트
    http.Response response = await http.get( //http에 get 요청을 보냄
      Uri.parse(baseUrl), //baseUrl 문자열을 파싱해서 Uri 객체 생성 -> HTTP 요청 주소를 나타냄
      headers: { //요청에 추가할 헤더를 정의하는 부분 
        "accept": "application/json", //서버에 요청이 json 형식의 응답을 선호한다는 것을 알림
        "Content-Type": "application/json", //요청의 본문
      },
    );
    try {
      Map<String, dynamic> resBody = jsonDecode( //http 응답의 본문을 utf-8로 디코딩한 후 json 형식으로 디코딩
        utf8.decode(response.bodyBytes),
      );
      resBody['statusCode'] = response.statusCode; //http 응답 객체의 상태 코드를 가져와서, 디코딩된 json 데이터에 추가 (statusCode : key, statusCode(상태) -> Map에 저장장)
      return resBody;
    } catch (e) {
      return {'statusCode': 490}; //http490 -> 충돌
    }
  } catch (e) {
    debugPrint("httpGet error: $e");
    return {'statusCode': 503};
  }
}
