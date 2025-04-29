import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  static final Dio dio = Dio();

  // static 멤버로 정의해야 외부에서 접근 가능
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:714';
}
