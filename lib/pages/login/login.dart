import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:project/app_style.dart';

class Login extends StatefulWidget {
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
                  "Sign in to Continue",
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
                        r'^[a-zA-Z0-9_+&*-]+(?:\\.[a-zA-Z0-9_+&*-]+)*@(?:[a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,7}$')
                    )
                    ) return '이메일의 형태가 올바르지 않습니다';
                    else return null;
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
                    TextButton(onPressed: null, child: Text("회원가입")),
                    TextButton(onPressed: null, child: Text("아이디 찾기")),
                    TextButton(onPressed: null, child: Text("비밀번호 찾기")),
                  ],
                ),
                //체크박스
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: always_login,
                      activeColor: kLightTextColor,
                      onChanged: (bool? value) {
                        setState(() {
                          always_login = value!;
                        });
                      },
                    ),
                    Text("로그인 상태 유지"),
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
                  onPressed: () {},
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
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, //요소 간 간격 조절
                  children: [
                    //facebook button
                    MaterialButton(
                      shape: OutlineInputBorder(
                        borderSide: BorderSide(width: 0.5, color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      onPressed: null,

                      child: SvgPicture.asset(
                        facebook,
                        color: Colors.black12,
                        width: 45,
                      ),
                    ),
                    //google button
                    SizedBox(width: size.width * 0.08),
                    MaterialButton(
                      shape: OutlineInputBorder(
                        borderSide: BorderSide(width: 0.5, color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      onPressed: null,

                      child: SvgPicture.asset(
                        google,
                        color: Colors.black12,
                        width: 45,
                      ),
                    ),
                    //kakao button
                    SizedBox(width: size.width * 0.08),
                    MaterialButton(
                      shape: OutlineInputBorder(
                        borderSide: BorderSide(width: 0.5, color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      onPressed: null,

                      child: SvgPicture.asset(
                        kakao,
                        color: Colors.black12,
                        width: 45,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
