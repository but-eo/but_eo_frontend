import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:project/appColors/app_colors.dart';
import 'package:project/app_style.dart';
import 'package:project/widgets/login_button.dart';


class Sign extends StatefulWidget {
  static String id = "/signup";

  Sign({super.key});

  @override
  State<Sign> createState() => _SignState();
}

class _SignState extends State<Sign> {

  //드롭다운
  int _sexValue = 1;
  int _perferValue = 1;
  int _birthValue = 1;
  int _regionValue = 1;

  //체크박스
  bool allCheck = false;
  bool termCheck = false;
  bool personalInformation = false;
  bool regionInformation = false;
  bool marketingAlram = false;


  final _formKey = GlobalKey<FormState>(); // Form 추적키

  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _nickName = '';

  void submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); //입력 데이터 저장
      print('Email: $_email, NickName: $_nickName, Password: $_password, ConfirmPassword: $_confirmPassword');
    }
  }

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
                          else if(
                          !RegExp( //이메일 검증
                              r'^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z0-9-.]+$')
                              .hasMatch(_email)
                          )
                          {
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

                      SizedBox(height: size.height * 0.016,),
                      RichText(
                        text: TextSpan(
                            children: [
                              TextSpan(
                                text : '전화번호 인증',
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

                      SizedBox(height: size.height * 0.01,),
                      Row(
                        children: [
                          Flexible( // 🚀 TextFormField의 크기를 유동적으로 변경
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                hintText: "010-0000-0000",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          SizedBox( // 🚀 ElevatedButton 크기 제한 추가
                            width: 200, // 적절한 너비 설정
                            height: 50, // 적절한 높이 설정
                            child: ElevatedButton(
                              onPressed: () {
                                // 인증번호 전송 로직
                              },
                              child: Text("인증번호 전송"),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: size.height * 0.03,),
                      Row(
                        children: [
                          Flexible( // 🚀 TextFormField의 크기를 유동적으로 변경
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                hintText: "인증번호 6자리를 입력해주세요.",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          SizedBox( // 🚀 ElevatedButton 크기 제한 추가
                            width: 200, // 적절한 너비 설정
                            height: 50, // 적절한 높이 설정
                            child: ElevatedButton(
                              onPressed: () {
                                // 인증번호 전송 로직
                              },
                              child: Text("인증번호 확인"),
                            ),
                          ),
                        ],
                      ),
                      //드롭다운
                      SizedBox(height: size.height * 0.03,),
                      RichText(
                        text: TextSpan(
                            children: [
                              TextSpan(
                                text : '성별',
                                style: TextStyle(
                                    color: kBlackColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ]
                        ),
                      ),
                      SizedBox(height: size.height * 0.01,),
                      Container(
                        width: 200,

                        child: DropdownButton<int>(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                            borderRadius: BorderRadius.circular(10),
                            isExpanded: true,
                            value : _sexValue,
                            dropdownColor: Colors.grey,
                            style: TextStyle(color : Colors.black87),
                            items: const[
                              DropdownMenuItem(
                                value: 1,
                                child: Text('남'),
                              ),
                              DropdownMenuItem(
                                value: 2,
                                child: Text('여'),

                              ),
                            ],
                            onChanged: (int? newValue){
                              setState(() {
                                _sexValue = newValue!;
                              });
                            }
                        ),
                      ),
                      SizedBox(height: size.height * 0.03,),
                      RichText(
                        text: TextSpan(
                            children: [
                              TextSpan(
                                text : '선호종목',
                                style: TextStyle(
                                    color: kBlackColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ]
                        ),
                      ),
                      SizedBox(height: size.height * 0.01,),
                      Container(
                        width: 200,

                        child: DropdownButton<int>(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            borderRadius: BorderRadius.circular(10),
                            isExpanded: true,
                            value : _perferValue,
                            dropdownColor: Colors.grey,
                            style: TextStyle(color : Colors.black87),
                            items: const[
                              DropdownMenuItem(
                                value: 1,
                                child: Text('축구'),
                              ),
                              DropdownMenuItem(
                                value: 2,
                                child: Text('야구'),

                              ),
                            ],
                            onChanged: (int? newValue){
                              setState(() {
                                _perferValue = newValue!;
                              });
                            }
                        ),
                      ),
                      SizedBox(height: size.height * 0.03,),
                      RichText(
                        text: TextSpan(
                            children: [
                              TextSpan(
                                text : '출생년도',
                                style: TextStyle(
                                    color: kBlackColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ]
                        ),
                      ),
                      SizedBox(height: size.height * 0.01,),
                      Container(
                        width: 200,

                        child: DropdownButton<int>(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            borderRadius: BorderRadius.circular(10),
                            isExpanded: true,
                            value : _birthValue,
                            dropdownColor: Colors.grey,
                            style: TextStyle(color : Colors.black87),
                            items: const[
                              DropdownMenuItem(
                                value: 1,
                                child: Text('1997'),
                              ),
                              DropdownMenuItem(
                                value: 2,
                                child: Text('1998'),

                              ),
                            ],
                            onChanged: (int? newValue){
                              setState(() {
                                _birthValue = newValue!;
                              });
                            }
                        ),
                      ),
                      SizedBox(height: size.height * 0.03,),
                      RichText(
                        text: TextSpan(
                            children: [
                              TextSpan(
                                text : '지역',
                                style: TextStyle(
                                    color: kBlackColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ]
                        ),
                      ),
                      SizedBox(height: size.height * 0.01,),
                      Container(
                        width: 200,

                        child: DropdownButton<int>(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            borderRadius: BorderRadius.circular(10),
                            isExpanded: true,
                            value : _regionValue,
                            dropdownColor: Colors.grey,
                            style: TextStyle(color : Colors.black87),
                            items: const[
                              DropdownMenuItem(
                                value: 1,
                                child: Text('대구'),
                              ),
                              DropdownMenuItem(
                                value: 2,
                                child: Text('서울'),

                              ),
                            ],
                            onChanged: (int? newValue){
                              setState(() {
                                _regionValue = newValue!;
                              });
                            }
                        ),
                      ),
                      SizedBox(height: size.height * 0.03,),
                      Container(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                    value: allCheck,
                                    onChanged:(bool? value) {
                                      setState(() {
                                        allCheck = value ?? true;
                                        termCheck = value ?? true;
                                        regionInformation = value ?? true;
                                        personalInformation = value ?? true;
                                        marketingAlram = value ?? true;
                                      });
                                    }

                                ),
                                Text("이용약관 전체동의")
                              ],
                            )
                          ],
                        ),
                      ),
                      
                      //이용약관 동의
                      SizedBox(height: size.height * 0.03,),
                      Container(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                    value: termCheck,
                                    onChanged:(bool? value) {
                                      setState(() {
                                        termCheck = value ?? true;
                                      });
                                    }

                                ),
                                Text("이용약관 동의(필수)")
                              ],
                            )
                          ],
                        ),
                      ),
                      
                      //개인정보
                      SizedBox(height: size.height * 0.03,),
                      Container(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                    value: personalInformation,
                                    onChanged:(bool? value) {
                                      setState(() {
                                        personalInformation = value ?? true;
                                      });
                                    }

                                ),
                                Text("개인정보 처리방침 동의(필수)")
                              ],
                            )
                          ],
                        ),
                      ),
                      
                      //위치정보 
                      SizedBox(height: size.height * 0.03,),
                      Container(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                    value: regionInformation,
                                    onChanged:(bool? value) {
                                      setState(() {
                                        regionInformation = value ?? true;
                                      });
                                    }

                                ),
                                Text("위치정보 이용 약관 동의(필수)")
                              ],
                            )
                          ],
                        ),
                      ),
                      
                      //마케팅
                      SizedBox(height: size.height * 0.03,),
                      Container(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                    value: marketingAlram,
                                    onChanged:(bool? value) {
                                      setState(() {
                                        marketingAlram = value ?? true;
                                      });
                                    }

                                ),
                                Text("마케팅 알람동의(선택)")
                              ],
                            )
                          ],
                        ),
                      )
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