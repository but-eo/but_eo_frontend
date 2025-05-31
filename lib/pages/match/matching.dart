import 'dart:convert';
import 'dart:ffi';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project/utils/token_storage.dart';
import '../../src/locations.dart' as locations;
import 'package:http/http.dart' as http;
import 'package:project/contants/api_contants.dart';
import 'package:intl/intl.dart';

class Matching extends StatefulWidget {
  final List<Map<String, dynamic>> userTeam;

  const Matching({super.key, required this.userTeam});

  @override
  State<Matching> createState() => _MatchingState();
}

class _MatchingState extends State<Matching> {
  // 예시 팀 데이터

  late List<Map<String, dynamic>> teamSports;
  final List<String> loan = ["예", "아니오"];

  @override
  void initState() {
    super.initState();

    teamSports =
        widget.userTeam.map((team) {
          return {'teamName': team['teamName'], 'event': team['event']};
        }).toList();
  }

  String? selectedTeam;
  String? selectedLoan;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? detailAddress;

  final dateFormatter = DateFormat('yyyy-MM-dd');
  String formatTimeOfDay(TimeOfDay tod) {
    final hour = tod.hour.toString().padLeft(2, '0');
    final minute = tod.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  //ENUM
  Map<String, String> sportTypeMapping = {
    '축구': 'SOCCER',
    '풋살': 'FUTSAL',
    '야구': 'BASEBALL',
    '농구': 'BASKETBALL',
    '배드민턴': 'BADMINTON',
    '테니스': 'TENNIS',
    '탁구': 'TABLE_TENNIS',
    '볼링': 'BOWLING',
  };

  TextEditingController addressController = TextEditingController();

  //주소 검색
  final TextEditingController etcController = TextEditingController();
  LatLng? searchedLatLng;

  bool isLoading = false;

  //항상 최신 정보를 유지하고 싶으면 Navigator를 써야함

  @override
  void dispose() {
    etcController.dispose();
    super.dispose();
  }

  final Map<String, Marker> _markers = {};
  Future<void> _onMapCreated(GoogleMapController controller) async {
    mapController = controller;

    final googleOffices = await locations.getGoogleOffices();
    setState(() {
      _markers.clear();
      for (final office in googleOffices.offices) {
        final marker = Marker(
          markerId: MarkerId(office.name),
          position: LatLng(office.lat, office.lng),
          infoWindow: InfoWindow(title: office.name, snippet: office.address),
        );
        _markers[office.name] = marker;
      }

      // 최근 검색 위치가 있다면 이동
      if (searchedLatLng != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(searchedLatLng!, 15),
        );

        final marker = Marker(
          markerId: MarkerId("검색된 장소"),
          position: searchedLatLng!,
          infoWindow: InfoWindow(title: addressController.text),
        );
        // _markers.clear(); // 🔁 여기에서 _markers를 직접 수정
        _markers["검색된 장소"] = marker;
      }
    });
  }

  //주소 -> LatLng 변환
  Future<Map<String, dynamic>?> getLatLngFromAddress(
    String address,
    String apiKey,
  ) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$apiKey&language=ko';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK' && data['results'].isNotEmpty) {
        final location = data['results'][0]['geometry']['location'];
        final formattedAddress = data['results'][0]['formatted_address'];
        detailAddress = formattedAddress;
        return {
          'latLng': LatLng(location['lat'], location['lng']),
          'formattedAddress': formattedAddress,
        };
      }
    }
    return null;
  }

  GoogleMapController? mapController;

  //마커 + 카메라 이동
  Future<void> searchAndMark(String address) async {
    final apiKey = ApiConstants.googleApiKey;
    final result = await getLatLngFromAddress(address, apiKey);

    if (result != null) {
      final latLng = result['latLng'] as LatLng;
      final formattedAddress = result['formattedAddress'] as String;

      searchedLatLng = latLng;

      if (mapController != null) {
        mapController!.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));

        final marker = Marker(
          markerId: MarkerId(address),
          position: latLng,
          infoWindow: InfoWindow(
            title: address, // 사용자가 입력한 값
            snippet: formattedAddress, // 상세 주소
          ),
        );

        setState(() {
          _markers.clear();
          _markers["검색된 장소"] = marker;
        });
      }
    }
  }

  //매치 생성(서버 요청)
  Future<void> createMatch(
    String teamName,
    String type,
    String matchDay,
    String matchTime,
    String loan,
    String region,
    String etc,
  ) async {
    final dio = Dio();
    final token = await TokenStorage.getAccessToken();
    try {
      final response = await dio.post(
        "${ApiConstants.baseUrl}/matchings/create",

        data: {
          'teamName': teamName,
          'matchType': type,
          'matchDay': matchDay,
          'matchTime': matchTime,
          'loan': loan,
          'region': region,
          'etc': etc,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            "Authorization": "Bearer $token",
          },
        ),
      );
      print('Response data : ${response.data}');
      if (response.statusCode == 200) {
        print('매치 생성 성공');
        Navigator.pop(context);
      }
    } catch (e) {
      if (e is DioException) {
        print('서버 응답 코드: ${e.response?.statusCode}');
        print('서버 응답 본문: ${e.response?.data}');
      }
      showFailSnackBar();
    }
  }

  void showFailSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('매치 생성에 실패했습니다. 다시 시도해주세요.'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: EdgeInsets.only(bottom: 30, left: 16, right: 16),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String? sport =
        selectedTeam != null
            ? teamSports.firstWhere(
                  (team) => team['teamName'] == selectedTeam,
                  orElse: () => {},
                )['event']
                as String?
            : null;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(title: Text("매치 등록")),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🟡 팀 선택
                Text("팀 선택", style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  isExpanded: true,
                  hint: Text("팀을 선택하세요"),
                  value: selectedTeam,
                  items:
                      teamSports.map((team) {
                        return DropdownMenuItem(
                          value: team['teamName'] as String,
                          child: Text(team['teamName']),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedTeam = value;
                    });
                  },
                ),
                SizedBox(height: 16),

                // 🔵 종목 (자동 표시)
                Text("종목", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(sport ?? "종목이 선택된 팀에서 자동으로 표시됩니다"),
                ),
                SizedBox(height: 16),

                //날짜 선택
                Text("날짜 선택", style: TextStyle(fontWeight: FontWeight.bold)),
                ElevatedButton(
                  onPressed: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                      });
                    }
                  },
                  child: Text(
                    selectedDate != null
                        ? dateFormatter.format(selectedDate!)
                        : "날짜 선택",
                  ),
                ),
                // 지도(위치 선택)
                SizedBox(height: 16.0),

                //시간 선택
                Text("시간 선택", style: TextStyle(fontWeight: FontWeight.bold)),
                ElevatedButton(
                  onPressed: () async {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: selectedTime ?? TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        selectedTime = pickedTime;
                      });
                    }
                  },
                  child: Text(
                    selectedTime != null
                        ? "${selectedTime!.format(context)}"
                        : "시간 선택",
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  "경기장 대여 여부",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  isExpanded: true,
                  hint: Text("경기장 대여 여부"),
                  value: selectedLoan,
                  items:
                      loan.map((loanOption) {
                        return DropdownMenuItem(
                          value: loanOption,
                          child: Text(loanOption),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedLoan = value;
                    });
                  },
                ),

                SizedBox(height: 16.0),

                //시간 선택
                Text("장소 선택", style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Flexible(
                      flex: 5,
                      child: TextField(
                        controller: addressController,
                        decoration: InputDecoration(
                          hintText: '주소를 입력하세요',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8), // 텍스트필드와 버튼 사이 여백
                    ElevatedButton(
                      onPressed: () => searchAndMark(addressController.text),
                      child: Text('검색'),
                    ),
                  ],
                ),
                SizedBox(height: 10.0),
                SizedBox(
                  width: size.width * 0.8,
                  height: 300,
                  child: Stack(
                    children: [
                      GoogleMap(
                        onMapCreated: (controller) {
                          mapController = controller;
                        },
                        initialCameraPosition: const CameraPosition(
                          target: LatLng(35.8722, 128.6025),
                          zoom: 15,
                        ),
                        markers: _markers.values.toSet(),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // 📝 기타 사항
                Text("기타 사항", style: TextStyle(fontWeight: FontWeight.bold)),
                TextField(
                  controller: etcController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "예: 유니폼 색상, 준비물 등",
                    border: OutlineInputBorder(),
                  ),
                ),

                SizedBox(height: 24),

                // ✅ 등록 버튼
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      // 등록 로직
                      if ([
                        selectedTeam,
                        selectedDate,
                        selectedTime,
                        selectedLoan,
                        detailAddress,
                        sport,
                      ].every((e) => e != null)) {
                        setState(() {
                          isLoading = true;
                        });

                        String dateStirng = dateFormatter.format(selectedDate!);
                        String timeString = formatTimeOfDay(selectedTime!);

                        await Future.delayed(Duration(seconds: 1));
                        // 예시 출력
                        print("팀: $selectedTeam");
                        print("종목: $sport");
                        print("날짜: ${dateStirng}");
                        print("시간: ${timeString}");
                        print("경기장 대여 여부: $selectedLoan");
                        print("장소: $detailAddress");
                        print("기타: ${etcController.text}");
                        String typeToSend =
                            sportTypeMapping[sport] ?? 'UNKNOWN';

                        await createMatch(
                          selectedTeam!,
                          typeToSend!,
                          dateStirng,
                          timeString,
                          selectedLoan!,
                          detailAddress!,
                          etcController.text,
                        );

                        setState(() {
                          isLoading = false;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("모든 필드를 입력해주세요.")),
                        );
                      }
                    },
                    child: Text("매치 등록"),
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      "매칭 생성 중입니다...",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
