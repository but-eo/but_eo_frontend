import 'dart:convert';

import 'package:dio/dio.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:project/appStyle/app_colors.dart';
import 'package:project/appStyle/app_style.dart';
import 'package:project/contants/api_contants.dart';
import 'package:project/pages/login/login.dart';
import 'package:project/widgets/login_button.dart';
import 'package:project/formatter/phoneformatter.dart';
import 'package:http/http.dart' as http;
import 'package:project/widgets/scroll_to_top_button.dart';

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

  final _divisions = ['USER', 'BUSINESS'];
  String? _selectedDivision;

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

  final ScrollController _scrollController = ScrollController();
  bool _showButton = false;

  Future<void> registerUser(
    String email,
    String password,
    String nickname,
    String tel,
    String sex,
    String prefer,
    String division,
    String year,
    String region,
  ) async {
    final dio = Dio();
    try {
      final response = await dio.post(
        "${ApiConstants.baseUrl}/users/register",
        data: {
          'email': email,
          'password': password,
          'name': nickname,
          'tel': tel,
          'gender': sex,
          'preferSports': prefer,
          'division': division,
          'birthYear': year,
          'region': region,
        },
        options: Options(
          validateStatus: (status) => status! < 500, // 400번대도 에러 던지지 않고 반환
        ),
      );

      print('Status code: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        print('회원가입 성공');
      } else {
        print('회원가입 실패: ${response.data}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("회원가입에 실패했습니다"),
            backgroundColor: Colors.red, // 이 부분을 추가하세요!
            behavior: SnackBarBehavior.floating, // (선택 사항) 화면 하단에 둥둥 떠다니게 함
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ), // (선택 사항) 모서리를 둥글게 함
            margin: EdgeInsets.only(
              bottom: 30,
              left: 16,
              right: 16,
            ), // (선택 사항) 여백 추가
            duration: Duration(seconds: 3), // (선택 사항) 3초 후 사라짐
          ),
        );
      }
    } on DioException catch (e) {
      print('DioException 발생: ${e.response?.data ?? e.message}');
    } catch (e) {
      print('회원가입 실패 (기타 에러): $e');
    }
  }

  //이메일 검증
  Future<bool> checkEmail(String email) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/users/check_email"),
        headers: {'Content-Type': 'application/json'},

        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        // 서버 응답이 정상일 때
        final data = jsonDecode(response.body);
        if (data['exist'] != null) {
          return data['exist'] == true;
        } else {
          throw Exception('잘못된 응답 형식');
        }
      } else {
        throw Exception('이메일 중복 확인 실패: 서버 응답 코드 ${response.statusCode}');
      }
    } catch (e) {
      // 예외 처리: 네트워크 오류나 JSON 파싱 오류 등
      print("Error checking email: $e");
      throw Exception('이메일 중복 확인 실패: $e');
    }
  }

  //이메일 인증번호 요청
  bool requestCode = false;
  Future<void> requestEmail(String email) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/users/send-verification"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        // 서버 응답이 정상일 때
        setState(() {
          requestCode = true;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('인증번호가 이메일로 전송되었습니다.')));
      } else {
        print("서버 오류: ${response.statusCode}");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('서버 오류가 발생했습니다. 다시 시도해주세요.')));
      }
    } catch (e) {
      throw Exception('인증번호 요청 실패: $e');
    }
  }

  //인증번호 확인
  bool verifyCheck = false;
  Future<void> verifyCode(String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/users/verify-code"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': code}),
      );

      if (response.statusCode == 200) {
        // 서버 응답이 정상일 때
        setState(() {
          verifyCheck = true;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('인증번호가 확인되었습니다.')));
      } else {
        print("서버 오류: ${response.statusCode}");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('인증번호가 일치하지 않습니다.')));
      }
    } catch (e) {
      throw Exception('인증번호 확인 실패: $e');
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

  // 드롭다운메뉴 아이템 초기 값 설정
  @override
  void initState() {
    super.initState();
    _selectedSex = _sex[0];
    _selectedPrefer = _preferences[0];
    _selectedYear = _years[0];
    _selectedRegions = _regions[0];
    _selectedDivision = _divisions[0];

    _scrollController.addListener(() {
      if (_scrollController.offset > 50) {
        if (!_showButton) {
          setState(() => _showButton = true);
        }
      } else {
        if (_showButton) {
          setState(() => _showButton = false);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      floatingActionButton:
          _showButton
              ? ScrollToTopButton(scrollController: _scrollController)
              : null,
      body: SingleChildScrollView(
        controller: _scrollController,
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
                  child: Image.asset(logoImage, height: size.height * 0.15),
                ),

                SizedBox(height: size.height * 0.023),
                Text(
                  "Sign Up",
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall!.copyWith(fontSize: 20), //appStyle
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
                      Row(
                        children: [
                          Flexible(
                            child: TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              style: TextStyle(color: kLightTextColor),
                              decoration: InputDecoration(
                                hintText: "이메일을 입력하세요",
                                prefixIcon: IconButton(
                                  onPressed: null,
                                  icon: Icon(Icons.email),
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
                              onChanged: (value) {
                                //폼 필드 값을 직접 변수에 저장하는 콜백 함수
                                _email = value!;
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          SizedBox(
                            // 🚀 ElevatedButton 크기 제한 추가
                            width: 100, // 적절한 너비 설정
                            height: 60, // 적절한 높이 설정
                            child: ElevatedButton(
                              onPressed: () async {
                                //TODO : 인증번호 전송 메소드 호출
                                print("전송할 이메일 : $_email");
                                bool check = await checkEmail(_email);
                                if (!check)
                                  await requestEmail(_email);
                                else {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (_) => AlertDialog(
                                          title: Text("중복된 이메일"),
                                          content: Text("이미 등록된 이메일입니다."),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(context),
                                              child: Text("확인"),
                                            ),
                                          ],
                                        ),
                                  );
                                }
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
                                // 인증번호 확인 메소드 호출 및 응답
                                verifyCode(_email, confirmController.text);
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
                            icon: Icon(Icons.face),
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
                            icon: Icon(Icons.lock),
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
                            icon: Icon(Icons.lock),
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
                              text: '휴대전화번호',
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
                          // SizedBox(width: 10),
                          // SizedBox(
                          //   // 🚀 ElevatedButton 크기 제한 추가
                          //   width: 100, // 적절한 너비 설정
                          //   height: 50, // 적절한 높이 설정
                          //   child: ElevatedButton(
                          //     onPressed: () async {
                          //       //TODO : 인증번호 전송
                          //     },
                          //     style: ElevatedButton.styleFrom(
                          //       backgroundColor: Colors.white, // 배경색을 빨간색으로 설정
                          //       foregroundColor: Colors.black, // 텍스트 색을 흰색으로 설정
                          //     ).copyWith(
                          //       side: WidgetStateProperty.all(
                          //         //테두리
                          //         BorderSide(color: Colors.black, width: 1),
                          //       ),
                          //     ),
                          //     child: Text("전송", style: TextStyle(fontSize: 18)),
                          //   ),
                          // ),
                        ],
                      ),

                      // SizedBox(height: size.height * 0.03),
                      // Row(
                      //   children: [
                      //     Flexible(
                      //       // 🚀 TextFormField의 크기를 유동적으로 변경
                      //       child: TextFormField(
                      //         controller: confirmController,
                      //         keyboardType: TextInputType.number,
                      //         decoration: InputDecoration(
                      //           contentPadding: EdgeInsets.symmetric(
                      //             horizontal: 10,
                      //           ),
                      //           hintText: "인증번호 6자리를 입력해주세요.",
                      //           border: OutlineInputBorder(),
                      //         ),
                      //       ),
                      //     ),
                      //     SizedBox(width: 10),
                      //     SizedBox(
                      //       // 🚀 ElevatedButton 크기 제한 추가
                      //       width: 100, // 적절한 너비 설정
                      //       height: 50, // 적절한 높이 설정
                      //       child: ElevatedButton(
                      //         onPressed: () {
                      //           // 인증번호 확인 로직
                      //           // PhoneAuthCredential phoneAuthCredential =
                      //           //   PhoneAuthProvider.credential(
                      //           //       verificationId: verificationId, smsCode: confirmController.text);

                      //           //   signInWithPhoneAuthCredential(phoneAuthCredential);
                      //         },
                      //         style: ElevatedButton.styleFrom(
                      //           backgroundColor: Colors.white, // 배경색을 빨간색으로 설정
                      //           foregroundColor: Colors.black, // 텍스트 색을 흰색으로 설정
                      //         ).copyWith(
                      //           side: WidgetStateProperty.all(
                      //             //테두리리
                      //             BorderSide(color: Colors.black, width: 1),
                      //           ),
                      //         ),
                      //         child: Text("확인", style: TextStyle(fontSize: 18)),
                      //       ),
                      //     ),
                      //   ],
                      // ),

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
                              text: '계정 유형',
                              style: TextStyle(
                                color: kBlackColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      //Division
                      SizedBox(height: size.height * 0.01),
                      Container(
                        width: 200,

                        child: DropdownButton<String>(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          borderRadius: BorderRadius.circular(10),
                          isExpanded: true,
                          value: _selectedDivision,
                          dropdownColor: Colors.grey,
                          style: TextStyle(color: Colors.black87),
                          items:
                              _divisions
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedDivision = value!;
                              print(_selectedDivision);
                            });
                          },
                        ),
                      ),
                      SizedBox(height: size.height * 0.03),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '선호 종목',
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
                  onPressed: () async {
                    //TODO : 인증번호 확인도 하긴 해야함
                    if (_formKey.currentState!.validate() &&
                        requestCode == true &&
                        verifyCheck == true) {
                      _formKey.currentState!.save(); //입력 데이터 저장

                      if (_password != _confirmPassword) {
                        showDialog(
                          context: context,
                          builder:
                              (_) => AlertDialog(
                                title: Text("비밀번호 불일치"),
                                content: Text("비밀번호가 일치하지 않습니다."),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("확인"),
                                  ),
                                ],
                              ),
                        );
                        return; // 비밀번호 불일치 시 더 이상 진행하지 않음
                      }

                      try {
                        bool exists = await checkEmail(_email);
                        if (exists) {
                          showDialog(
                            context: context,
                            builder:
                                (_) => AlertDialog(
                                  title: Text("중복된 이메일"),
                                  content: Text("이미 등록된 이메일입니다."),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text("확인"),
                                    ),
                                  ],
                                ),
                          );
                        } else {
                          // 이메일이 중복되지 않으면 회원가입 진행
                          registerUser(
                            _email,
                            _password,
                            _nickName,
                            phoneController.text,
                            _selectedSex ?? '선택하지 않음',
                            _selectedPrefer ?? '선호종목 없음',
                            _selectedDivision ?? '유저',
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
                                '계정유형: $_selectedDivision\n' +
                                '출생년도: $_selectedYear\n' +
                                '지역: $_selectedRegions',
                          );
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => Login()),
                            (route) => false,
                          );
                        }
                      } catch (e) {
                        // 예외 처리: 네트워크 오류나 서버 오류 시 처리
                        showDialog(
                          context: context,
                          builder:
                              (_) => AlertDialog(
                                title: Text("오류 발생"),
                                content: Text(
                                  "이메일 중복 확인 중 오류가 발생했습니다. 다시 시도해주세요.",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("확인"),
                                  ),
                                ],
                              ),
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
