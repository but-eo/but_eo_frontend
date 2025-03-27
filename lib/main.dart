import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:project/app_style.dart';
import 'package:project/pages/Sign.dart';
import 'package:project/pages/login/login.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await dotenv.load(fileName: "key.env");

  KakaoSdk.init(
    nativeAppKey: 'd91548ab43a2e8cd79ab5957765cd8ee',
    javaScriptAppKey: '3c64fa2eecc2196abe34620a62aba475',
  );

  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {


    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //오른쪽 상단에 디버그 안뜨게 하는거
      title: 'But-eo Login Page',
      theme: appTheme,
      routes: {
        Sign.id: (context) => Sign(),
        Login.id: (context) => Login(),
      },
      home: Login(),
    );
  }
}
