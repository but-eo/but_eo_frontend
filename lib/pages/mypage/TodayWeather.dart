import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project/pages/mypage/MapSelectPage.dart'; // 지도 선택 페이지

class TodayWeatherPage extends StatefulWidget {
  const TodayWeatherPage({super.key});

  @override
  State<TodayWeatherPage> createState() => _TodayWeatherPageState();
}

class _TodayWeatherPageState extends State<TodayWeatherPage> {
  Map<String, dynamic>? weatherData;
  bool isLoading = false;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    // ✅ 날씨별 그라데이션
    final bgGradient = _getBackgroundGradient(weatherData);

    return Scaffold(
      appBar: AppBar(
        title: const Text("오늘의 날씨"),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black87,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: bgGradient,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () async {
                  final selectedLatLng = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MapSelectPage()),
                  );

                  if (selectedLatLng != null) {
                    fetchWeatherByLatLng(selectedLatLng);
                  }
                },
                child: const Text("지역 선택"),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage != null
                    ? Center(
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.white),
                  ),
                )
                    : weatherData != null
                    ? _buildWeatherCard(weatherData!)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> fetchWeatherByLatLng(dynamic latLng) async {
    const apiKey = "1a481eee596ec14c3a587e505a5ff6c9";
    final url =
        "https://api.openweathermap.org/data/2.5/weather?lat=${latLng.latitude}&lon=${latLng.longitude}&appid=$apiKey&units=metric&lang=kr";

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          weatherData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          weatherData = null;
          errorMessage = "API 오류: ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        weatherData = null;
        errorMessage = "네트워크 오류: $e";
        isLoading = false;
      });
    }
  }

  Widget _buildWeatherCard(Map<String, dynamic> data) {
    final cityName = data['name'];
    final description = data['weather'][0]['description'];
    final iconCode = data['weather'][0]['icon'];
    final temp = data['main']['temp'];
    final feelsLike = data['main']['feels_like'];
    final humidity = data['main']['humidity'];
    final windSpeed = data['wind']['speed'];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          cityName,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Image.network(
          "https://openweathermap.org/img/wn/$iconCode@2x.png",
          width: 120,
          height: 120,
        ),
        const SizedBox(height: 10),
        Text(
          description,
          style: const TextStyle(fontSize: 22, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          "${temp.toStringAsFixed(1)} ℃ (체감 ${feelsLike.toStringAsFixed(1)} ℃)",
          style: const TextStyle(fontSize: 18, color: Colors.white70),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildInfoTile(Icons.water_drop, "습도", "$humidity%"),
            _buildInfoTile(Icons.air, "바람", "${windSpeed} m/s"),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.white)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // ✅ 날씨별 그라데이션 색상
  LinearGradient _getBackgroundGradient(Map<String, dynamic>? data) {
    if (data == null) {
      return const LinearGradient(
        colors: [Colors.blueGrey, Colors.lightBlueAccent],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    }

    final weatherMain = data['weather'][0]['main'].toString().toLowerCase();

    if (weatherMain.contains("clear")) {
      // 맑음: 연한 주황
      return const LinearGradient(
        colors: [Color(0xFFFFE0B2), Color(0xFFFFCC80)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else if (weatherMain.contains("cloud")) {
      // 구름: 연한 회색
      return const LinearGradient(
        colors: [Color(0xFFB0BEC5), Color(0xFFCFD8DC)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else if (weatherMain.contains("rain")) {
      // 비: 회색
      return const LinearGradient(
        colors: [Color(0xFF90A4AE), Color(0xFF607D8B)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else if (weatherMain.contains("snow")) {
      // 눈: 흰색
      return const LinearGradient(
        colors: [Colors.white, Color(0xFFE0F7FA)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else {
      // 기타
      return const LinearGradient(
        colors: [Colors.blueGrey, Colors.lightBlueAccent],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    }
  }
}
