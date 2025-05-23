import 'dart:convert';

import 'package:http/http.dart' as http;
class Networkhelper {
  static final Networkhelper _instance = Networkhelper._internal();
  factory Networkhelper() => _instance;
  Networkhelper._internal();

  Future getData(String url) async{
    http.Response response = await http.get(Uri.parse(url));

    if(response.statusCode == 200){
      return jsonDecode(response.body);
    }else{
      print(response.statusCode);
    }
  }
}