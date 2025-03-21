import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../appColors/app_colors.dart';
import '../app_style.dart';
import '../widgets/login_button.dart';

class Signup extends StatelessWidget {
  static String id = "/signup";
  final _formKey = GlobalKey<FormState>(); // Form 추적키

  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _nickName = '';
  String _tel = '';

  void submitForm() {
    if (_formKey.currentState!.validate()) {
      //필드 검증
      _formKey.currentState!.save(); //입력 데이터 저장
      print('Email: $_email, NickName : $_nickName, Password: $_password, ConfirmPassword : $_confirmPassword');
    }
  }

  Signup({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
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
                  "Sign Up",
                  style: Theme.of(context).textTheme.titleLarge, //appStyle
                ),
                SizedBox(height: size.height * 0.018),
                Text(
                  "Create a new Account",
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall!.copyWith(fontSize: 15), //appStyle
                ),

                SizedBox(height: size.height * 0.02, width: size.width * 0.9),
                Form(
                  key: _formKey, //
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //가입 폼
                      //이메일
                      RichText( //다양한 스타일의 텍스트를 적용하는 텍스트 위젯
                          text: TextSpan(
                            children: [
                              TextSpan( //RichText의 조각 -> 한 문장 내에서도 특정 부분만 색깔을 다르게 한다던지 가능
                                text : '이메일',
                                style: TextStyle(
                                  color: kBlackColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                              TextSpan(
                                text : ' *',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold
                                ),
                              )
                            ]
                          ),
                      )
                      ,
                      SizedBox(height: size.height*0.01,),
                      TextFormField(
                        style: TextStyle(color: kLightTextColor),
                        decoration: InputDecoration(
                          hintText: "이메일을 입력하세요",
                          prefixIcon: IconButton(
                            onPressed: null,
                            icon: SvgPicture.asset(userIcon),
                          ),
                        ),
                        validator: (value) {
                          _email = value!;
                          if (value.isEmpty) {
                            return '이메일을 입력하세요.';
                          }
                          else if(_email.contains(RegExp( //이메일 검증
                              r'^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z0-9-.]+$')
                          )
                          ) {
                            return "이메일의 형태가 올바르지 않습니다";
                          } else {
                            return null;
                          }
                        },
                        onSaved: (value) {
                          //폼 필드 값을 직접 변수에 저장하는 콜백 함수
                          _email = value!;
                        },
                      ),
                      SizedBox(height: size.height * 0.016,),
                      RichText( //다양한 스타일의 텍스트를 적용하는 텍스트 위젯
                        text: TextSpan(
                            children: [
                              TextSpan( //RichText의 조각 -> 한 문장 내에서도 특정 부분만 색깔을 다르게 한다던지 가능
                                text : '닉네임',
                                style: TextStyle(
                                    color: kBlackColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              TextSpan(
                                text : ' *',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold
                                ),
                              )
                            ]
                        ),
                      ),



                      SizedBox(height: size.height * 0.01),
                      TextFormField(
                        style: TextStyle(color: kLightTextColor),
                        decoration: InputDecoration(
                          hintText: "닉네임을 입력하세요",
                          prefixIcon: IconButton(
                            onPressed: null,
                            icon: SvgPicture.asset(userIcon),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.length < 1) {
                            return "닉네음은 최소 2자리 이상이어야 합니다.";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _nickName = value!;
                        },
                      ),

                      SizedBox(height: size.height * 0.016,),
                      RichText(
                        text: TextSpan(
                            children: [
                              TextSpan(
                                text : '비밀번호',
                                style: TextStyle(
                                    color: kBlackColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              TextSpan(
                                text : ' *',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold
                                ),
                              )
                            ]
                        ),
                      ),

                      SizedBox(height: size.height * 0.01),
                      TextFormField(
                        obscureText: true,
                        style: TextStyle(color: kLightTextColor),
                        decoration: InputDecoration(
                          hintText: "비밀번호를 입력해주세요",
                          prefixIcon: IconButton(
                            onPressed: null,
                            icon: SvgPicture.asset(userIcon),
                          ),
                        ),
                        validator: (value) {
                          _password = value!;
                          if (value.length < 6) {
                            return "비밀번호는 6자 이상이어야 합니다.";
                          }

                          return null;
                        },
                        onSaved: (value) {
                          _password = value!;
                        },
                      ),

                      SizedBox(height: size.height * 0.016,),
                      RichText(
                        text: TextSpan(
                            children: [
                              TextSpan(
                                text : '비밀번호 확인',
                                style: TextStyle(
                                    color: kBlackColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              TextSpan(
                                text : ' *',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold
                                ),
                              )
                            ]
                        ),
                      ),

                      SizedBox(height: size.height * 0.01),
                      TextFormField(
                        obscureText: true,
                        style: TextStyle(color: kLightTextColor),
                        decoration: InputDecoration(
                          hintText: "비밀번호를 한 번 더 입력해주세요.",
                          prefixIcon: IconButton(
                            onPressed: null,
                            icon: SvgPicture.asset(userIcon),
                          ),
                        ),
                        validator: (value) {
                          _confirmPassword = value!;
                          if (value.length < 6) {
                            return "비밀번호는 6자 이상이어야 합니다.";
                          }
                          if (value != _password) {
                            return "비밀번호가 일치하지 않습니다.";
                          }

                          return null;
                        },
                        onSaved: (value){
                          _confirmPassword = value!;
                        },
                      ),

                    ],
                  ),
                ),

                //Todo: 본인인증, 인증번호
                SizedBox(height: size.height * 0.03),
                ElevatedButton(
                  //누르면 뒤에 그림자가 생기는 버튼
                  onPressed: submitForm, //TODO : 로그인 버튼 누르면 데이터 전송
                  child: Text(
                    "회원가입",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
