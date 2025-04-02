import 'package:http/http.dart';
import 'package:flutter/material.dart';
import 'package:project/http/http.dart';


void main() {
  runApp(const HttpRestAPI());
}

class HttpRestAPI extends StatelessWidget {
  const HttpRestAPI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nuridal Class',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HttpPackagePage(title: 'Nuridal Class: Http Rest API Demo'),
    );
  }
}

class HttpPackagePage extends StatefulWidget {
  const HttpPackagePage({super.key, required this.title});

  final String title;

  @override
  State<HttpPackagePage> createState() => _HttpPackagePageState();
}

Map<String, dynamic>? apiResult;

class _HttpPackagePageState extends State<HttpPackagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 20),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                onPressed: () async {
                  apiResult =
                  await httpGet(path: '/api/users?page=2').then((value) { //httpGet함수를 호출해 이 경로로 http get요청을 보내고 기다림
                  //http.dart에서 baseUrl+path로 정의해 /api/users?page=2 와 같은 걸 할 수 있음
                    if (value["statusCode"] == 200) {
                      debugPrint("${value['data'][0]}"); //http 응답에서 data 키의 첫번째 요소
                      return showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('API Result'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: CircleAvatar(
                                        radius: 30,
                                        backgroundImage: NetworkImage(
                                            value["data"][0]['avatar'])),
                                  ),
                                  Text('아이디: ${value["data"][0]['id']}'), //첫번째 회원의 id값
                                  Text('이메일: ${value["data"][0]['email']}'),
                                  Text('성: ${value["data"][0]['first_name']}'),
                                  Text('이름: ${value["data"][0]['last_name']}'),
                                ],
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('OK'))
                              ],
                            );
                          });
                    } else {
                      debugPrint('서버 에러입니다. 다시 시도해주세요');
                    }
                  });
                },
                child: const Text('API CALL'))
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}