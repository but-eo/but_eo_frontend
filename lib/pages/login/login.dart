import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:project/appColors/app_colors.dart';
import 'package:project/app_style.dart';
import 'package:project/pages/Sign.dart';
import 'package:project/widgets/login_button.dart';

class Login extends StatefulWidget {
  static String id = "/login";
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  //체크박스 변수
  bool always_login = false;
  bool id_remember = false;



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


                  //로그인 필드
                  SizedBox(height: size.height * 0.02, width: size.width * 0.9),
                  TextFormField(
                    style: TextStyle(color: kLightTextColor),
                    decoration: InputDecoration(
                      hintText: "이메일을 입력하세요",
                      prefixIcon: IconButton(
                        onPressed: null,
                        icon: SvgPicture.asset(userIcon),
                      ),
                    ),
                    validator: (String? value){
                      if(value?.isEmpty ?? true) return '이메일을 입력하세요';
                      if(value!.contains(RegExp( //이메일 검증
                          r'^[a-zA-Z0-9+-_.]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$')
                      )
                      ) {
                        return "이메일의 형태가 올바르지 않습니다";
                      } else {
                        return null;
                      }
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
                  ),
                  SizedBox(height: size.height * 0.021),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly, //요소 간 간격 조절
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil( //특정화면으로 이동하면서 이전 모든 화면을 스택에서 제거 (새 화면을 띄우고 뒤로가기 버튼을 눌러도 이전 화면으로 돌아갈 수 없음)
                              Sign.id, //이동할 경로의 이름
                                  (route) => false //스택의 모든 화면 제거
                          );
                        },
                        child: Text("회원가입"),
                      ), //회원가입 폼으로 이동
                      TextButton(onPressed: null, child: Text("아이디 찾기")), //아이디 찾기 폼으로 이동
                      TextButton(onPressed: null, child: Text("비밀번호 찾기")), //비밀번호 찾기 폼으로 이동
                    ],
                  ),
                  //체크박스
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox( //항상 로그인
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
                    onPressed: () {}, //TODO : 로그인 버튼 누르면 데이터 전송
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
                  SizedBox(
                    height: 20,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly, //요소 간 간격 조절
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: (){

                        },
                        child : loginButton(
                            context,
                            'assets/icons/naver_icon.png',
                            '네이버 로그인',
                            Colors.white,
                            AppColors.baseGreenColor,
                            AppColors.baseGreenColor
                        ),
                      ),

                      //카카오 button
                      SizedBox(height: size.height * 0.01),


                      GestureDetector(
                        onTap: (){

                        },
                        child : loginButton(
                            context,
                            'assets/icons/kakao_icon.png',
                            '카카오 로그인',
                            Colors.black87,
                            Colors.yellow.withOpacity(0.7),
                            Colors.yellow
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
