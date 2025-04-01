import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> logoutKakao() async {
  try {
    await UserApi.instance.logout();
    print('로그아웃 성공, SDK에서 토큰 폐기');
  } catch (error) {
    print('로그아웃 실패, SDK에서 토큰 폐기 $error');
  }
}

Future<void> logout() async{
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('accesstoken');
  print('로그아웃 완료, 토큰 삭제');
}

//토큰 가져오기
Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('accesstoken');
}