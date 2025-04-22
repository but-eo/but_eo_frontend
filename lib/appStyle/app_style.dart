import 'package:flutter/material.dart';



const String userIcon = "assets/icons/userIcon.svg";
const String lockIcon = "assets/icons/lock.svg";
const String emailIcon = "assets/icons/email.svg";

//AppColors
const Color bgColor = Color(0xfff4f4f4);
const Color kTextColor = Color(0xff1C1939);
const Color kInputBorderColor = Color(0xff1F363D);
const Color kLightTextColor = Color(0xff8A8F99);
const Color kBlackColor = Colors.black;
const Color kWhiteColor = Colors.white;

//app Images

const String logoImage = "assets/images/butteoLogo.png";

//App Theme Data

ThemeData? appTheme = ThemeData(
  fontFamily: "Montserrat",
  scaffoldBackgroundColor: bgColor,
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
  //elevatedButtonTheme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      shadowColor: kBlackColor,
      minimumSize: const Size.fromHeight(64),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      backgroundColor: kBlackColor,
    ),
  ),
  //TextFiled Theme
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
      fontWeight:  FontWeight.w600,
    ),
  ),
);
