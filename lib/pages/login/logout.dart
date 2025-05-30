import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';


Future<void> logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('accessToken'); // ✅ 키명 정확히 확인
  print('✅ 로그아웃: 토큰 삭제 완료');
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('accessToken');
}
