// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';

import 'package:project/appStyle/app_colors.dart';
import 'package:project/appStyle/app_style.dart';
import 'package:project/main.dart';
import 'package:project/pages/sign.dart';
import 'package:project/pages/mainpage.dart';
import 'package:project/widgets/login_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  static String id = "/login";

  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();

  String? email = "";
  String? password = "";

  bool loginAuth = false;
  bool always_login = false;
  bool id_remember = false;

  // 일반 로그인
  Future<void> loginUser(String email, String password) async {
    final dio = Dio();
    try {
      final response = await dio.post(
        "http://172.29.0.102:0714/api/users/login",
        data: {'email': email, 'password': password, 'loginType': 'BUTEO'},
      );
      print('Response data : ${response.data}');
      if (response.statusCode == 200) {
        final token = response.data['accessToken'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', token);
        print('🔑 [Login - BUTEO] 저장된 accessToken: $token');

        setState(() => loginAuth = true);
        navigateToMainPage();
      }
    } catch (e) {
      print('❌ 일반 로그인 실패: $e');
      setState(() => loginAuth = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            // decoration: BoxDecoration(
            //   gradient: LinearGradient(
            //       colors: [AppColors.g1, AppColors.g2],
            //   ),
            // ),
            //로고 영역
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.1, // <->
                vertical: size.height * 0.035, //^v
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topCenter, //상단 중앙 정렬
                    child: Image.asset(logoImage, height: size.height * 0.1),
                  ),
                  SizedBox(height: size.height * 0.023),
                  Text(
                    "Welcome",
                    style: Theme.of(context).textTheme.titleLarge, //appStyle
                  ),
                  SizedBox(height: size.height * 0.018),
                  Text(
                    "Sign Up in to Continue",
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall!.copyWith(fontSize: 15), //appStyle
                  ),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        //로그인 필드
                        SizedBox(
                          height: size.height * 0.02,
                          width: size.width * 0.9,
                        ),
                        TextFormField(
                          style: TextStyle(color: kLightTextColor),
                          decoration: InputDecoration(
                            hintText: "이메일을 입력하세요",
                            prefixIcon: IconButton(
                              onPressed: null,
                              icon: SvgPicture.asset(userIcon),
                            ),
                          ),
                          validator: (String? value) {
                            email = value!;
                            if (value?.isEmpty ?? true) return '이메일을 입력하세요';
                            if (!RegExp(
                              //이메일 검증
                              r'^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z0-9-.]+$',
                            ).hasMatch(email!)) {
                              return "이메일의 형태가 올바르지 않습니다";
                            } else {
                              return null;
                            }
                          },
                          onSaved: (value) {
                            email = value!;
                            print("현재 이메일 : $email");
                          },
                        ),
                        SizedBox(height: size.height * 0.016),
                        TextFormField(
                          obscureText: true,
                          style: TextStyle(color: kLightTextColor),
                          decoration: InputDecoration(
                            hintText: "비밀번호를 입력하세요",
                            prefixIcon: IconButton(
                              onPressed: null,
                              icon: SvgPicture.asset(userIcon),
                            ),
                          ),
                          validator: (String? value) {
                            password = value!;
                            if (value?.isEmpty ?? true) return '패스워드를 입력하세요';
                            if (value.length < 6) {
                              return "비밀번호 6자리 이상 입력해주세요.";
                            } else {
                              return null;
                            }
                          },
                          onSaved: (value) {
                            password = value!;
                            print("현재 패스워드 : $password");
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 0.021),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //요소 간 간격 조절
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            //특정화면으로 이동하면서 이전 모든 화면을 스택에서 제거 (새 화면을 띄우고 뒤로가기 버튼을 눌러도 이전 화면으로 돌아갈 수 없음)
                            Sign.id, //이동할 경로의 이름
                            (route) => false, //스택의 모든 화면 제거
                          );
                        },
                        child: Text("회원가입"),
                      ),
                      //회원가입 폼으로 이동
                      TextButton(onPressed: null, child: Text("아이디 찾기")),
                      //아이디 찾기 폼으로 이동
                      TextButton(onPressed: null, child: Text("비밀번호 찾기")),
                      //비밀번호 찾기 폼으로 이동
                    ],
                  ),
                  //체크박스
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        //항상 로그인
                        value: always_login,
                        activeColor: kLightTextColor,
                        onChanged: (bool? value) {
                          setState(() {
                            always_login = value!;
                          });
                        },
                      ),
                      Text("로그인 상태 유지"),

                      //아이디 기억하기
                      SizedBox(width: 20),
                      Checkbox(
                        value: id_remember,
                        activeColor: kLightTextColor,
                        onChanged: (bool? value) {
                          setState(() {
                            id_remember = value!;
                          });
                        },
                      ),
                      Text("아이디 기억"),
                    ],
                  ),
                  SizedBox(height: size.height * 0.03),
                  ElevatedButton(
                    //누르면 뒤에 그림자가 생기는 버튼
                    onPressed: () async {
                      // if (_formKey.currentState!.validate()) {
                      //   _formKey.currentState!.save(); // onSaved 호출
                      //   print(email); // 저장된 이메일 출력
                      //   print(password);

                      //   // await loginUser(email!, password!);
                      //   // print(loginAuth);
                      //   // if (loginAuth) {
                      //   //   navigateToMainPage();
                      //   // }
                      //   navigateToMainPage();
                      // }
                      navigateToMainPage();
                    },
                    child: Text(
                      "로그인",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                  Row(
                    children: [
                      const Expanded(child: Divider(color: kLightTextColor)),
                      //수직 또는 수평 구분선
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "or Signin in with Others",
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      const Expanded(child: Divider(color: kLightTextColor)),
                    ],
                  ),

                  //로그인 버튼
                  SizedBox(height: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //요소 간 간격 조절
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          loginWithNaver();
                        },
                        child: loginButton(
                          context,
                          'assets/icons/naver_icon.png',
                          '네이버 로그인',
                          Colors.white,
                          AppColors.baseGreenColor,
                          AppColors.baseGreenColor,
                        ),
                      ),

                      //카카오 button
                      SizedBox(height: size.height * 0.01),

                      GestureDetector(
                        onTap: () {
                          signInWithKakao();
                          print('카카오톡 로그인 시도중');
                        },
                        child: loginButton(
                          context,
                          'assets/icons/kakao_icon.png',
                          '카카오 로그인',
                          Colors.black87,
                          Colors.yellow.withOpacity(0.7),
                          Colors.yellow,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //홈으로 이동
  void navigateToMainPage() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => Main()));
  }

  Future<void> sendDataToServer(
    String refreshToken,
    String email,
    String nickname,
    String profileimage,
    String gender,
    String birthyear,
  ) async {
    final url = Uri.parse("http://172.29.0.102:0714/api/users/kakao/login");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "refreshToken": refreshToken,
        "email": email,
        "nickName": nickname,
        "gender": gender,
        "birthYear": birthyear,
        "profileImage": profileimage,
      }),
    );
    if (response.statusCode == 200) {
      print("서버 전송 성공: ${response.body}");

      // ✅ 응답에서 accessToken 꺼내기
      final responseData = jsonDecode(response.body);
      final serverAccessToken = responseData['accessToken'];

      if (serverAccessToken != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', serverAccessToken); // ✅ 저장
        print("서버 accessToken 저장 완료: $serverAccessToken");
      } else {
        print("서버에서 accessToken이 누락됨");
      }
    } else {
      print("서버 전송 실패: ${response.statusCode}");
    }
  }

  Future<void> signInWithKakao() async {
    try {
      OAuthToken token;

      // 카카오톡 실행 가능 여부 확인
      if (await isKakaoTalkInstalled()) {
        try {
          token = await UserApi.instance.loginWithKakaoTalk();
          print('카카오톡 로그인 성공');
        } catch (error) {
          print('카카오톡 로그인 실패: $error');
          token = await UserApi.instance.loginWithKakaoAccount();
          print('카카오계정 로그인 성공');
        }
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
        print('카카오계정 로그인 성공');
      }

      // 로그인 성공 후 사용자 정보 가져오기
      User user = await UserApi.instance.me();

      String accessToken = token.accessToken;
      String refreshToken = token.refreshToken ?? "";
      String email = user.kakaoAccount?.email ?? "이메일 없음";
      String nickname = user.kakaoAccount?.profile?.nickname ?? "닉네임 없음";
      String profileImage = user.kakaoAccount?.profile?.profileImageUrl ?? "";
      String gender = user.kakaoAccount?.gender?.name ?? "";
      String birthYear = user.kakaoAccount?.birthyear ?? "";

      print("accessToken : " + accessToken);
      print("refreshToken : " + refreshToken);
      print("email : " + email);
      // 서버로 사용자 데이터 전송
      await sendDataToServer(
        refreshToken,
        email,
        nickname,
        profileImage,
        gender,
        birthYear,
      );

      // 메인 페이지 이동
      navigateToMainPage();
    } catch (error) {
      print('로그인 실패: $error');
    }
  }

  Future<void> loginWithNaver() async {
    final url = Uri.parse("https://nid.naver.com/nidlogin.logout");
    final response = await http.get(url); // http 패키지 사용

    try {
      print("네이버 로그인 시도중");
      var accessToken;
      var tokenType;
      final result = await FlutterNaverLogin.logIn();

      print("로그인 상태 : ${result.status}");
      NaverAccessToken res = await FlutterNaverLogin.currentAccessToken;
      final tempAccessToken = res.accessToken;
      final tempTokenType = res.tokenType;

      print('accessToken : $tempAccessToken');
      print('tokenType : $tempTokenType');

      if (tempAccessToken != null && tempAccessToken.isNotEmpty) {
        setState(() {
          accessToken = tempAccessToken;
          tokenType = tempTokenType;
        });
        navigateToMainPage();
      } else {
        print("네이버 로그인 실패 사유: ${result.errorMessage}");
      }
    } catch (e) {
      print("에러 : ${e}");
    }
  }
  // //네이버 회원 정보 가져오기
  // Future<void> fetchNaverUserDetail(String accessToken) async {
  //   const String url = "https://openapi.naver.com/v1/nid/me";

  //   final response = await http.get(
  //     Uri.parse(url),
  //     headers: {'Authorization': 'Bearer $accessToken'},
  //   );

  //   if (response.statusCode == 200) {
  //     var data = json.decode(response.body);
  //     var userInfo = data['response'];

  //     String id = userInfo['id'];
  //     String name = userInfo['name'];
  //     String email = userInfo['email'];

  //     print("Naver ID: $id");
  //     print("Name: $name");
  //     print("Email: $email");

  //     // TODO: 이 정보를 서버로 보내거나 앱 내 사용자 상태 저장 등에 활용
  //   } else {
  //     print("Failed to fetch user info. status: ${response.statusCode}");
  //   }
  // }
}
