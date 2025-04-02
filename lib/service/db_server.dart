import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:project/model/user_model.dart';

Future<void> saveUser(User user) async{
  try{
    final response = await http.post(
      Uri.parse("http://"),
      headers: <String, String>{
        'Content-Type' : 'application/json; charset=UTF-8',
      },
      body: jsonEncode(user.toJson()),
    );
    if(response.statusCode != 201){
      throw Exception("데이터 전송에 실패하였습니다.");
    }
    else{
      print("유저 데이터 전송에 성공하였습니다.");
    }
  }
  catch (e){
    print("유저 데이터 전송에 실패하였습니다 . ${e}");
  }
}