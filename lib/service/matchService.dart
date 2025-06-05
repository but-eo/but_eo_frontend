import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:project/contants/api_contants.dart';
import 'package:project/pages/match/matching_data.dart';
import 'package:project/utils/token_storage.dart';

class Matchservice {
  static final Dio dio = Dio();

  Future<bool> challengeMatch(String matchId) async {
    try {
      final response = await dio.post(
        "${ApiConstants.baseUrl}/matchings/$matchId/challenge",
      );

      if (response.statusCode == 200) {
        print("도전 신청이 완료되었습니다");
        return true;
      } else {
        print("도전 신청이 실패했습니다");
        return false;
      }
    } catch (e) {
      throw Exception("도전 신청 실패: $e");
    }
  }

  Future<Map<String, dynamic>> fetchMatching(String matchId) async {
    final response = await dio.get(
      "${ApiConstants.baseUrl}/matchings/$matchId",
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(response.data);
    } else {
      throw Exception("오류 발생");
    }
  }
}
