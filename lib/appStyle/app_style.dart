import 'package:flutter/material.dart';

// 아이콘 경로
const String userIcon = "assets/icons/userIcon.svg";
const String lockIcon = "assets/icons/lock.svg";
const String emailIcon = "assets/icons/email.svg";

// App Colors
const Color bgColor = Colors.white;
const Color kTextColor = Color(0xff1C1939);
const Color kInputBorderColor = Color(0xff1F363D);
const Color kLightTextColor = Color(0xff8A8F99);
const Color kBlackColor = Colors.black;
const Color kWhiteColor = Colors.white;

// 앱 이미지
const String logoImage = "assets/images/butteoLogo.png";

// App Theme Data
ThemeData? appTheme = ThemeData(
  fontFamily: "Montserrat",
  scaffoldBackgroundColor: bgColor,

  // ✅ AppBar 테마 (상단 헤더 흰색, 검정 텍스트)
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0.3,
    iconTheme: IconThemeData(color: Colors.black),
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),

  // ✅ BottomNavigationBar 테마 (하단 바 흰색)
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: Colors.black,
    unselectedItemColor: Colors.grey,
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
  ),

  // ✅ PopupMenu 테마 (드롭다운 배경 흰색)
  popupMenuTheme: const PopupMenuThemeData(
    color: Colors.white,
    textStyle: TextStyle(color: Colors.black),
    elevation: 4,
  ),

  // ✅ 텍스트 테마
  textTheme: const TextTheme(
    titleLarge: TextStyle(
      fontSize: 32,
      color: kTextColor,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      color: kWhiteColor,
      fontWeight: FontWeight.w700,
    ),
    titleSmall: TextStyle(
      fontSize: 12,
      color: kLightTextColor,
      fontWeight: FontWeight.w600,
    ),
  ),

  // ✅ ElevatedButton 테마
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      shadowColor: kBlackColor,
      minimumSize: const Size.fromHeight(64),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      backgroundColor: kBlackColor,
    ),
  ),

  // ✅ TextField 테마
  inputDecorationTheme: InputDecorationTheme(
    contentPadding: const EdgeInsets.symmetric(vertical: 22.0),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: kInputBorderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: kInputBorderColor),
      borderRadius: BorderRadius.circular(10),
    ),
    hintStyle: const TextStyle(
      fontSize: 16,
      color: kLightTextColor,
      fontWeight: FontWeight.w600,
    ),
  ),
);
