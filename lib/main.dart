import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:project/appStyle/app_style.dart';
import 'package:project/contants/api_contants.dart';
import 'package:project/pages/login/Sign.dart';
import 'package:project/pages/mainpage.dart';
import 'package:project/pages/login/login.dart';
import 'package:project/pages/mypage/myteam.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting().then((_) => runApp(MyApp()));
  // await Firebase.initializeApp();
  WebViewPlatform.instance = AndroidWebViewPlatform();

  KakaoSdk.init(
    nativeAppKey: '43571ff25dd7d58c93282d1029654bd9',
    javaScriptAppKey: '4f8d5998dff250032e60538ceeb1a2ac',
  );

  getKeyHash();

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
        Sign.id: (context) => Sign(), Login.id: (context) => Login(),
        Main.id: (context) => Main(),
        '/myteam': (context) => MyTeamPage(), // 이 부분 추가
      },
      home: Login(),
    );
  }
}

void getKeyHash() async {
  final keyHash = await KakaoSdk.origin;
  print('카카오 키 해시: $keyHash');
}
