import 'dart:convert';
import 'dart:io' show Platform; // Platform 클래스 (모바일 특정 플랫폼 감지용)
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:project/appStyle/app_colors.dart';
import 'package:project/appStyle/app_style.dart';
import 'package:project/contants/api_contants.dart';
import 'package:project/pages/login/Sign.dart';
import 'package:project/pages/mainpage.dart';
import 'package:project/utils/token_storage.dart';
import 'package:project/widgets/login_button.dart';
import 'package:project/widgets/scroll_to_top_button.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  static String id = "/login";

  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();

  bool loginAuth = false;

  Future<void> loginUser(String email, String password) async {
    final dio = Dio();
    try {
      final response = await dio.post(
        "${ApiConstants.baseUrl}/users/login",
        data: {'email': email, 'password': password},
      );
      print('Response data : ${response.data}');
      if (response.statusCode == 200) {
        String token = response.data['accessToken'];
        print('로그인 성공 $token');
        await TokenStorage.saveTokens(token);

        setState(() {
          loginAuth = true;
        });
      }
    } catch (e) {
      if (e is DioException) {
        print('로그인 실패: ${e.response?.statusCode} - ${e.response?.data}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '로그인 실패: ${e.response?.data['message'] ?? '알 수 없는 오류'}',
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: EdgeInsets.only(bottom: 30, left: 16, right: 16),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        print('로그인 실패 (예상치 못한 오류): $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인 실패: 예상치 못한 오류 발생'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: EdgeInsets.only(bottom: 30, left: 16, right: 16),
            duration: Duration(seconds: 3),
          ),
        );
      }
      setState(() {
        loginAuth = false;
      });
    }
  }

  String? email = "";
  String? password = "";

  bool always_login = false;
  bool id_remember = false;

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
    String tel,
  ) async {
    final url = Uri.parse("${ApiConstants.baseUrl}/users/kakao/login");
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
        "tel": tel,
      }),
    );
    if (response.statusCode == 200) {
      print("서버 전송 성공: ${response.body}");
      final Map<String, dynamic> data = jsonDecode(response.body);

      final jwt = data['accessToken'];
      if (jwt != null) {
        print("저장 jwt : $jwt");
        await TokenStorage.saveTokens(jwt);
      } else {
        print("access token 없음");
      }
    } else {
      print("서버 전송 실패: ${response.statusCode}");
      // 카카오 로그인 후 서버 전송 실패 시 스낵바 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('카카오 로그인 정보 서버 전송 실패. 다시 시도해주세요.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: EdgeInsets.only(bottom: 30, left: 16, right: 16),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> signInWithKakao() async {
    try {
      OAuthToken token;

      if (!Platform.isAndroid && await isKakaoTalkInstalled()) {
        // 모바일 (웹 아님) 이면서 카카오톡 설치 시도
        try {
          token = await UserApi.instance.loginWithKakaoTalk();
          print('카카오톡 로그인 성공');
        } catch (error) {
          print('카카오톡 로그인 실패 (앱): $error');
          // 앱 로그인 실패 시 계정 로그인 시도
          token = await UserApi.instance.loginWithKakaoAccount();
          print('카카오계정 로그인 성공 (앱 실패 후)');
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
      String tel = user.kakaoAccount?.phoneNumber ?? "";

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
        tel,
      );

      // 메인 페이지 이동
      navigateToMainPage();
    } catch (error) {
      print('로그인 실패: $error');
      // 카카오 로그인 자체 실패 시 스낵바 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '카카오 로그인 실패. ${error.toString().contains("REDIRECT_URI_MISMATCH") ? "리다이렉트 URI 설정 확인 필요." : "다시 시도해주세요."}',
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: EdgeInsets.only(bottom: 30, left: 16, right: 16),
          duration: Duration(seconds: 5), // 오류 메시지 좀 더 오래 표시
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.1,
                vertical: size.height * 0.035,
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Image.asset(logoImage, height: size.height * 0.1),
                  ),
                  SizedBox(height: size.height * 0.023),
                  SizedBox(height: size.height * 0.018),
                  Text(
                    "Sign Up in to Continue",
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall!.copyWith(fontSize: 15),
                  ),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
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
                              r'^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z0-9-.]+$',
                            ).hasMatch(email!)) {
                              // ScaffoldMessenger.of(context).showSnackBar(
                              //   const SnackBar(
                              //     content: Text('이메일의 형태가 올바르지 않습니다.'),
                              //   ),
                              // );
                              return "이메일의 형태가 올바르지 않습니다.";
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
                              icon: Icon(Icons.password_sharp),
                            ),
                          ),
                          validator: (String? value) {
                            password = value!;
                            if (value?.isEmpty ?? true) return '패스워드를 입력하세요';
                            if (value.length < 6) {
                              // ScaffoldMessenger.of(context).showSnackBar(
                              //   const SnackBar(
                              //     content: Text('비밀번호를 6자리 이상 입력해주세요.'),
                              //   ),
                              // );
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
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("아직 계정이 없으신가요?"),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                Sign.id,
                                (route) => false,
                              );
                            },
                            child: Text("회원가입"),
                          ),
                        ],
                      ),
                      // TextButton(onPressed: null, child: Text("아이디 찾기")),
                      // TextButton(onPressed: null, child: Text("비밀번호 찾기")),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Checkbox(
                      //   value: always_login,
                      //   activeColor: kLightTextColor,
                      //   onChanged: (bool? value) {
                      //     setState(() {
                      //       always_login = value!;
                      //     });
                      //   },
                      // ),
                      // Text("로그인 상태 유지"),
                      // SizedBox(width: 20),
                      // Checkbox(
                      //   value: id_remember,
                      //   activeColor: kLightTextColor,
                      //   onChanged: (bool? value) {
                      //     setState(() {
                      //       id_remember = value!;
                      //     });
                      //   },
                      // ),
                      // Text("아이디 기억"),
                    ],
                  ),
                  SizedBox(height: size.height * 0.03),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        print(email);
                        print(password);

                        await loginUser(email!, password!);
                        print(loginAuth);
                        if (loginAuth) {
                          navigateToMainPage();
                        }
                      }
                    },
                    child: Text(
                      "로그인",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                  if (isAndroid())
                    Row(
                      children: [
                        const Expanded(child: Divider(color: kLightTextColor)),
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
                  if (isAndroid()) SizedBox(height: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // GestureDetector(
                      //   onTap: () {},
                      //   child: loginButton(
                      //     context,
                      //     'assets/icons/naver_icon.png',
                      //     '네이버 로그인',
                      //     Colors.white,
                      //     AppColors.baseGreenColor,
                      //     AppColors.baseGreenColor,
                      //   ),
                      // ),
                      SizedBox(height: size.height * 0.01),

                      // 카카오 로그인 버튼: 웹 환경에서 숨기기
                      if (isAndroid())
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
}
