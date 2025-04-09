import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> logoutKakao() async {
  try {
    await UserApi.instance.unlink(); // 또는 logout()
    print('✅ 카카오 로그아웃 성공');
  } catch (error) {
    print('❌ 카카오 로그아웃 실패: $error');
  }
}

Future<void> logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('accessToken'); // ✅ 키명 정확히 확인
  print('✅ 일반 로그아웃: 토큰 삭제 완료');
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('accessToken');
}
