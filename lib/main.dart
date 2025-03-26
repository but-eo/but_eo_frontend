import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:project/app_style.dart';
import 'package:project/pages/Sign.dart';
import 'package:project/pages/login/login.dart';
import 'package:project/pages/signup.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // await dotenv.load(fileName: "key.env");
  //
  // KakaoSdk.init(
  //   nativeAppKey: dotenv.get('KAKAO_NATIVE_APP_KEY'),
  //   javaScriptAppKey: dotenv.get('KAKAO_JAVASCRIPT_APP_KEY'),
  // );

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
