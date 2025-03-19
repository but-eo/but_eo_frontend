import 'package:flutter/material.dart';
import 'package:project/app_style.dart';
import 'package:project/pages/login/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, //오른쪽 상단에 디버그 안뜨게 하는거
      title: 'But-eo Login Page',
      theme: appTheme,
      home: Login(),
    );
  }
}

