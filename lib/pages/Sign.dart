import 'package:dio/dio.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:project/appStyle/app_colors.dart';
import 'package:project/appStyle/app_style.dart';
import 'package:project/pages/login.dart';
import 'package:project/widgets/login_button.dart';
import 'package:project/formatter/phoneformatter.dart';

class Sign extends StatefulWidget {
  static String id = "/signup";

  Sign({super.key});

  @override
  State<Sign> createState() => _SignState();
}

class _SignState extends State<Sign> {
  //드롭다운
  final _sex = ['남', '여'];
  String? _selectedSex;
  final _preferences = ['축구', '풋살', '야구', '농구', '테니스', '배드민턴', '볼링', '탁구'];
  String? _selectedPrefer;
  final List<String> _years = List.generate(
    100,
    (index) => (DateTime.now().year - index).toString(),
  );
  String? _selectedYear;
  final _regions = ['서울', '경기', '강원', '충청', '전라', '경상', '제주'];
  String? _selectedRegions;

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

  //유저 정보 전송(dio 활용)
  Future<void> registerUser(
    String email,
    String password,
    String nickname,
    String tel,
    String sex,
    String prefer,
    String year,
    String region,
  ) async {
    final dio = Dio();
    try {
      final response = await dio.post(
        //192.168.45.179, 10.30.3.43, 192.168.0.127

        // 192.168.0.73
        "http://192.168.0.73:0714/api/users/register",
       // "http://192.168.0.72:0714/api/users/register",
        // "https://05e11d7c-f01d-4fb4-aabd-7849216efc8c.mock.pstmn.io/auth/register", //spring boot로 전송할 주소
        data: {
          'email': email,
          'password': password,
          'name': nickname,
          'tel': tel,
          'gender': sex,
          'preferSports': prefer,
          'birthYear': year,
          'region': region,
        },
      );
      print('Response data : ${response.data}');
      if (response.statusCode == 200) {
        // String token =
        //     response.data['accesstoken']; //백엔드에서 받을 토큰 data['token']에서 token은
        //스프링에서 토큰을 저장한 변수명과 일치해야함
        print('회원가입 성공');
      }
    } catch (e) {
      print('회원가입 실패 : ${e}');
    }
  }

  

  // 전화번호 인증
  TextEditingController phoneController = TextEditingController(); //전화번호 컨트롤러
  TextEditingController confirmController =
      TextEditingController(); // 인증번호 컨트롤러

  FocusNode phoneNumber = FocusNode();
  FocusNode otpFocusNode = FocusNode();

  bool authOk = false;

  bool passwordHide = true;
  bool requestedAuth = false;
  String verificationId = "";
  bool showLoading = false;

  // late FirebaseAuth _auth = FirebaseAuth.instance;

  // void signInWithPhoneAuthCredential(
  //   PhoneAuthCredential phoneAuthCredential,
  // ) async {
  //   setState(() {
  //     showLoading = true;
  //   });
  //   try {
  //     final authCredential = await _auth.signInWithCredential(
  //       phoneAuthCredential,
  //     );
  //     setState(() {
  //       showLoading = false;
  //     });
  //     if (authCredential?.user != null) {
  //       setState(() {
  //         print("인증완료 및 로그인성공");
  //         authOk = true;
  //         requestedAuth = false;
  //       });
  //       if (_auth.currentUser != null) {
  //         await _auth.currentUser!.delete();
  //         print("Auth 정보 삭제");
  //       }
  //       _auth.signOut();
  //       print("로그아웃");
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     setState(() {
  //       print("인증 실패 ");
  //       showLoading = false;
  //     });

  //     await Fluttertoast.showToast(
  //       msg: e.message!,
  //       toastLength: Toast.LENGTH_SHORT,
  //       timeInSecForIosWeb: 1,
  //       backgroundColor: Colors.red,
  //       fontSize: 16.0,
  //     );
  //   }
  // }

  // void dispose() { //메모리 누수 방지?
  //   phoneController.dispose();
  //   confirmController.dispose();
  //   super.dispose();
  // }

  // 드롭다운메뉴 아이템 초기 값 설정
  @override
  void initState() {
    super.initState();
    _selectedSex = _sex[0];
    _selectedPrefer = _preferences[0];
    _selectedYear = _years[0];
    _selectedRegions = _regions[0];
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
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => Login()),
                        (route) => false,
                      );
                    },
                    icon: Icon(Icons.arrow_back), 
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter, //상단 중앙 정렬
                  child: Image.asset(logoImage, height: size.height * 0.1),
                ),
                SizedBox(height:  size.height * 0.023),
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
                      RichText(
                        //다양한 스타일의 텍스트를 적용하는 텍스트 위젯
                        text: TextSpan(
                          children: [
                            TextSpan(
                              //RichText의 조각 -> 한 문장 내에서도 특정 부분만 색깔을 다르게 한다던지 가능
                              text: '이메일',
                              style: TextStyle(
                                color: kBlackColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: ' *',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: size.height * 0.01),
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
                          } else if (!RegExp(
                            //이메일 검증
                            r'^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z0-9-.]+$',
                          ).hasMatch(_email)) {
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
                      SizedBox(height: size.height * 0.016),
                      RichText(
                        //다양한 스타일의 텍스트를 적용하는 텍스트 위젯
                        text: TextSpan(
                          children: [
                            TextSpan(
                              //RichText의 조각 -> 한 문장 내에서도 특정 부분만 색깔을 다르게 한다던지 가능
                              text: '닉네임',
                              style: TextStyle(
                                color: kBlackColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: ' *',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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
                          if (value == null || value.length < 4) {
                            return "닉네임은 최소 4자리 이상이어야 합니다.";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _nickName = value!;
                        },
                      ),

                      SizedBox(height: size.height * 0.016),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '비밀번호',
                              style: TextStyle(
                                color: kBlackColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: ' *',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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

                      SizedBox(height: size.height * 0.016),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '비밀번호 확인',
                              style: TextStyle(
                                color: kBlackColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: ' *',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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
                        onSaved: (value) {
                          _confirmPassword = value!;
                        },
                      ),

                      SizedBox(height: size.height * 0.016),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '전화번호 인증',
                              style: TextStyle(
                                color: kBlackColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: ' *',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: size.height * 0.01),
                      Row(
                        children: [
                          Flexible(
                            // 🚀 TextFormField의 크기를 유동적으로 변경
                            child: TextFormField(
                              controller: phoneController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                hintText: "010-0000-0000",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          SizedBox(
                            // 🚀 ElevatedButton 크기 제한 추가
                            width: 100, // 적절한 너비 설정
                            height: 50, // 적절한 높이 설정
                            child: ElevatedButton(
                              onPressed: () async {
                                // 인증번호 전송 로직
                                // await _auth.verifyPhoneNumber(
                                //   timeout: const Duration(seconds: 60),
                                //   codeAutoRetrievalTimeout: (String verificationId) {
                                //     // Auto-resolution timed out...
                                //   },
                                //   phoneNumber: phoneController.text,
                                //   verificationCompleted: (phoneAuthCredential) async {
                                //     print("otp 문자옴");
                                //   },
                                //   verificationFailed: (verificationFailed) async {
                                //     print(verificationFailed.code);

                                //     print("코드발송실패");
                                //     setState(() {
                                //       showLoading = false;
                                //     });
                                //   },
                                //   codeSent: (verificationId, resendingToken) async {
                                //     print("코드보냄");
                                //     Fluttertoast.showToast(
                                //         msg: "${phoneController.text}로 인증코드를 발송하였습니다..",
                                //         toastLength: Toast.LENGTH_SHORT,
                                //         timeInSecForIosWeb: 1,
                                //         backgroundColor: Colors.green,
                                //         fontSize: 12.0
                                //     );
                                //     setState(() {
                                //       requestedAuth=true;
                                //       FocusScope.of(context).requestFocus(otpFocusNode);
                                //       showLoading = false;
                                //       this.verificationId = verificationId;
                                //     });
                                //   },
                                // );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white, // 배경색을 빨간색으로 설정
                                foregroundColor: Colors.black, // 텍스트 색을 흰색으로 설정
                              ).copyWith(
                                side: WidgetStateProperty.all(
                                  //테두리
                                  BorderSide(color: Colors.black, width: 1),
                                ),
                              ),
                              child: Text("전송", style: TextStyle(fontSize: 18)),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: size.height * 0.03),
                      Row(
                        children: [
                          Flexible(
                            // 🚀 TextFormField의 크기를 유동적으로 변경
                            child: TextFormField(
                              controller: confirmController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                hintText: "인증번호 6자리를 입력해주세요.",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          SizedBox(
                            // 🚀 ElevatedButton 크기 제한 추가
                            width: 100, // 적절한 너비 설정
                            height: 50, // 적절한 높이 설정
                            child: ElevatedButton(
                              onPressed: () {
                                // 인증번호 확인 로직
                                // PhoneAuthCredential phoneAuthCredential =
                                //   PhoneAuthProvider.credential(
                                //       verificationId: verificationId, smsCode: confirmController.text);

                                //   signInWithPhoneAuthCredential(phoneAuthCredential);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white, // 배경색을 빨간색으로 설정
                                foregroundColor: Colors.black, // 텍스트 색을 흰색으로 설정
                              ).copyWith(
                                side: WidgetStateProperty.all(
                                  //테두리리
                                  BorderSide(color: Colors.black, width: 1),
                                ),
                              ),
                              child: Text("확인", style: TextStyle(fontSize: 18)),
                            ),
                          ),
                        ],
                      ),

                      //드롭다운
                      SizedBox(height: size.height * 0.03),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '성별',
                              style: TextStyle(
                                color: kBlackColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: size.height * 0.01),
                      Container(
                        width: 200,

                        child: DropdownButton<String>(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          borderRadius: BorderRadius.circular(10),
                          isExpanded: true,
                          value: _selectedSex,
                          dropdownColor: Colors.grey,
                          style: TextStyle(color: Colors.black87),
                          items:
                              _sex
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSex = value!;
                              print(_selectedSex);
                            });
                          },
                        ),
                      ),
                      SizedBox(height: size.height * 0.03),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '선호종목',
                              style: TextStyle(
                                color: kBlackColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: size.height * 0.01),
                      Container(
                        width: 200,

                        child: DropdownButton<String>(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          borderRadius: BorderRadius.circular(10),
                          isExpanded: true,
                          value: _selectedPrefer,
                          dropdownColor: Colors.grey,
                          style: TextStyle(color: Colors.black87),
                          items:
                              _preferences
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPrefer = value!;
                              print(_selectedPrefer);
                            });
                          },
                        ),
                      ),
                      SizedBox(height: size.height * 0.03),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '출생년도',
                              style: TextStyle(
                                color: kBlackColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: size.height * 0.01),
                      Container(
                        width: 200,

                        child: DropdownButton<String>(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          borderRadius: BorderRadius.circular(10),
                          isExpanded: true,
                          value: _selectedYear,
                          dropdownColor: Colors.grey,
                          style: TextStyle(color: Colors.black87),
                          items:
                              _years
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedYear = value!;
                              print(_selectedYear);
                            });
                          },
                        ),
                      ),
                      SizedBox(height: size.height * 0.03),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '지역',
                              style: TextStyle(
                                color: kBlackColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: size.height * 0.01),
                      Container(
                        width: 200,

                        child: DropdownButton<String>(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          borderRadius: BorderRadius.circular(10),
                          isExpanded: true,
                          value: _selectedRegions,
                          dropdownColor: Colors.grey,
                          style: TextStyle(color: Colors.black87),
                          items:
                              _regions
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedRegions = value!;
                              print(_selectedRegions);
                            });
                          },
                        ),
                      ),
                      SizedBox(height: size.height * 0.03),
                      Container(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: allCheck,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      allCheck = value ?? true;
                                      termCheck = value ?? true;
                                      regionInformation = value ?? true;
                                      personalInformation = value ?? true;
                                      marketingAlram = value ?? true;
                                    });
                                  },
                                ),
                                Text("이용약관 전체동의"),
                              ],
                            ),
                          ],
                        ),
                      ),

                      //이용약관 동의
                      SizedBox(height: size.height * 0.03),
                      Container(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: termCheck,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      termCheck = value ?? true;
                                    });
                                  },
                                ),
                                Text("이용약관 동의(필수)"),
                              ],
                            ),
                          ],
                        ),
                      ),

                      //개인정보
                      SizedBox(height: size.height * 0.03),
                      Container(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: personalInformation,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      personalInformation = value ?? true;
                                    });
                                  },
                                ),
                                Text("개인정보 처리방침 동의(필수)"),
                              ],
                            ),
                          ],
                        ),
                      ),

                      //위치정보
                      SizedBox(height: size.height * 0.03),
                      Container(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: regionInformation,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      regionInformation = value ?? true;
                                    });
                                  },
                                ),
                                Text("위치정보 이용 약관 동의(필수)"),
                              ],
                            ),
                          ],
                        ),
                      ),

                      //마케팅
                      SizedBox(height: size.height * 0.03),
                      Container(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: marketingAlram,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      marketingAlram = value ?? true;
                                    });
                                  },
                                ),
                                Text("마케팅 알람동의(선택)"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                //Todo: 본인인증, 인증번호
                SizedBox(height: size.height * 0.03),
                ElevatedButton(
                  //누르면 뒤에 그림자가 생기는 버튼
                  onPressed: () {
                    //TODO : 인증번호 확인도 하긴 해야함
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save(); //입력 데이터 저장

                      if (_password == _confirmPassword) {
                        //authOk
                        registerUser(
                          _email,
                          _password,
                          _nickName,
                          phoneController.text,
                          _selectedSex ?? '선택하지 않음',
                          _selectedPrefer ?? '선호종목 없음',
                          _selectedYear ?? '선택하지 않음',
                          _selectedRegions ?? '선택하지 않음',
                        );
                        print(
                          'Email: $_email\n' +
                              'NickName: $_nickName\n' +
                              'Password: $_password\n' +
                              'ConfirmPassword: $_confirmPassword\n' +
                              '성별: $_selectedSex\n' +
                              '선호종목: $_selectedPrefer\n' +
                              '출생년도: $_selectedYear\n' +
                              '지역: $_selectedRegions',
                        );
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => Login()),
                          (route) => false,
                        );
                      }
                    }
                  }, //TODO : 로그인 버튼 누르면 데이터 전송
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
