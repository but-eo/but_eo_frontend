import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart'; // MediaType을 위해 추가
// 프로젝트의 실제 경로에 맞게 아래 import 경로를 수정해주세요.
import 'package:project/contants/api_contants.dart';
import 'package:project/utils/token_storage.dart';

class EditProfilePage extends StatefulWidget {
  final String? initialProfileImageUrl;
  const EditProfilePage({super.key, this.initialProfileImageUrl});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final nicknameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? selectedSport;
  String? selectedBirthYear;
  String? selectedRegion;

  XFile? profileImage; // image_picker로 선택된 파일
  String? _profileImageUrl; // 서버에서 받아온 기존 프로필 이미지 URL

  // 앱에서 실제로 사용하는 목록으로 채워주세요.
  final sports = ['축구', '풋살', '테니스', '배드민턴', '탁구', '볼링'];
  final years = List.generate(50, (index) => (DateTime.now().year - 7 - index).toString()); // 만 7세부터 선택 가능하도록 조정
  final regions = ['서울', '경기', '인천', '부산', '대구', '광주', '대전', '울산', '세종', '강원', '충북', '충남', '전북', '전남', '경북', '경남', '제주'];

  final String defaultProfilePath = "/uploads/profiles/default_profile.png";
  final String baseUrl = "http://${ApiConstants.serverUrl}:714"; // baseUrl 추가

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 초기 프로필 이미지 URL 설정 시 baseUrl을 사용하도록 수정 (mypage.dart와 통일)
    if (widget.initialProfileImageUrl != null && widget.initialProfileImageUrl!.isNotEmpty) {
      if (widget.initialProfileImageUrl!.startsWith("http")) {
        _profileImageUrl = widget.initialProfileImageUrl;
      } else {
        _profileImageUrl = "$baseUrl${widget.initialProfileImageUrl}";
      }
    } else {
      _profileImageUrl = "$baseUrl$defaultProfilePath";
    }
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("로그인이 필요합니다.")),
        );
      }
      return;
    }

    final dio = Dio();
    try {
      final res = await dio.get(
        "$baseUrl/api/users/my-info", // ApiConstants.baseUrl 대신 baseUrl 사용 또는 ApiConstants.baseUrl 확인
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      print("✅ [전체 JSON] 사용자 정보 응답 (EditProfile): ${res.data}");

      if (res.statusCode == 200) {
        final data = res.data;
        if (data is Map<String, dynamic>) {
          String? birthYearString;
          if (data['birth'] != null) {
            birthYearString = data['birth'].toString();
          } else if (data['birthYear'] != null) {
            birthYearString = data['birthYear'].toString();
          }

          String? nickname = (data['name'] ?? data['nickname'])?.toString();
          String? preferSports = data['preferSports']?.toString();
          String? region = data['region']?.toString();
          final profilePathFromServer = data['profile'];
          final timestamp = DateTime.now().millisecondsSinceEpoch;

          if (mounted) {
            setState(() {
              nicknameController.text = nickname ?? '';
              selectedSport = (preferSports != null && sports.contains(preferSports)) ? preferSports : null;
              selectedBirthYear = (birthYearString != null && years.contains(birthYearString)) ? birthYearString : null;
              selectedRegion = (region != null && regions.contains(region)) ? region : null;

              // 프로필 이미지 URL 설정 (mypage.dart와 동일한 로직 적용)
              if (profilePathFromServer != null && profilePathFromServer is String && profilePathFromServer.isNotEmpty) {
                if (profilePathFromServer.startsWith("http")) {
                  _profileImageUrl = "$profilePathFromServer?v=$timestamp";
                } else {
                  // 상대 경로인 경우 ApiConstants.imageBaseUrl 또는 baseUrl 사용
                  _profileImageUrl = "$baseUrl$profilePathFromServer?v=$timestamp";
                }
              } else {
                _profileImageUrl = "$baseUrl$defaultProfilePath?v=$timestamp";
              }
            });
          }
        } else {
          print("❗ [에러] 서버에서 Map<String, dynamic>이 아닌 다른 타입(${data.runtimeType})이 옴: $data");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('서버에서 올바른 사용자 정보 형식이 오지 않았습니다.')),
            );
          }
        }
      } else {
        print("❌ 사용자 정보 가져오기 실패 (EditProfile): ${res.statusCode}, ${res.data}");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('사용자 정보 로딩에 실패했습니다: ${res.data?['message'] ?? res.statusMessage}')),
          );
        }
      }
    } catch (e) {
      print("❗ 사용자 정보 요청 중 오류 (EditProfile): $e");
      if (e is DioException && e.response != null) {
        print("❗ 서버 응답 데이터 (EditProfile fetchUserInfo): ${e.response!.data}");
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("사용자 정보 로딩 중 오류가 발생했습니다.")),
        );
      }
    }
  }

  Future<void> pickProfileImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        if (mounted) {
          setState(() {
            profileImage = pickedFile;
          });
        }
      }
    } catch (e) {
      print("❗ 이미지 선택 중 오류: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("이미지를 가져오는 데 실패했습니다.")),
        );
      }
    }
  }

  Future<void> updateUserInfo() async {
    if (passwordController.text.isNotEmpty && passwordController.text != confirmPasswordController.text) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("비밀번호가 일치하지 않습니다.")),
        );
      }
      return;
    }

    final token = await TokenStorage.getAccessToken();
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("로그인이 필요합니다.")),
        );
      }
      return;
    }

    if (mounted) {
      setState(() => _isLoading = true);
    }

    final Map<String, dynamic> dataMap = {
      "name": nicknameController.text,
      if (passwordController.text.isNotEmpty) "password": passwordController.text,
      "birthYear": selectedBirthYear,
      "preferSports": selectedSport,
      "region": selectedRegion,
    };

    if (profileImage != null) {
      String? guessedMimeType = profileImage!.mimeType;
      MediaType? mediaType;
      if (guessedMimeType != null) {
        try {
          mediaType = MediaType.parse(guessedMimeType);
        } catch (e) {
          print("❗ MimeType 파싱 오류: $guessedMimeType. 오류: $e");
        }
      } else {
        String extension = profileImage!.name.split('.').last.toLowerCase();
        if (extension == 'jpg' || extension == 'jpeg') {
          mediaType = MediaType('image', 'jpeg');
        } else if (extension == 'png') {
          mediaType = MediaType('image', 'png');
        }
      }
      print("ℹ️ 선택된 프로필 이미지 정보 (EditProfile): name='${profileImage!.name}', path='${profileImage!.path}', XFile mimeType='${profileImage!.mimeType}', Parsed MediaType='${mediaType?.toString()}'");
      dataMap["profile"] = await MultipartFile.fromFile(
        profileImage!.path,
        filename: profileImage!.name,
        contentType: mediaType,
      );
    }

    final formData = FormData.fromMap(dataMap);
    final dio = Dio();
    try {
      final response = await dio.patch(
        "$baseUrl/api/users/update", // ApiConstants.baseUrl 대신 baseUrl 사용 또는 ApiConstants.baseUrl 확인
        data: formData,
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      print("🔄 프로필 업데이트 응답 (EditProfile): ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("회원정보가 수정되었습니다.")),
          );
          Navigator.pop(context, true);
        }
      } else {
        print("❗ 회원정보 수정 실패 (상태 코드 ${response.statusCode}, EditProfile): ${response.data}");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("회원정보 수정에 실패했습니다: ${response.data?['message'] ?? response.statusMessage}")),
          );
        }
      }
    } catch (e) {
      print("❗ 회원정보 수정 실패 (EditProfile): $e");
      String errorMessage = "회원정보 수정 중 오류가 발생했습니다.";
      if (e is DioException && e.response != null) {
        print("❗ 서버 응답 데이터 (EditProfile updateUserInfo): ${e.response!.data}");
        final responseData = e.response!.data;
        if (responseData is Map && responseData.containsKey('message')) {
          errorMessage = responseData['message'].toString();
        } else if (responseData is String && responseData.isNotEmpty) {
          errorMessage = responseData;
        } else if (e.response!.statusMessage != null && e.response!.statusMessage!.isNotEmpty) {
          errorMessage = e.response!.statusMessage!;
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("내 정보 수정", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          ListView( // SingleChildScrollView 대신 ListView 사용 (카드 그룹핑 시 더 적합)
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100), // 하단 버튼 높이 고려
            children: [
              _buildProfileImagePicker(),
              const SizedBox(height: 24),
              _buildSectionCard(
                title: "기본 정보",
                children: [
                  _buildTextField("닉네임", nicknameController, hint: "2~10자 이내로 입력해주세요"),
                ],
              ),
              const SizedBox(height: 20),
              _buildSectionCard(
                title: "계정 정보 (선택)",
                children: [
                  _buildTextField("비밀번호", passwordController, obscure: true, hint: "변경시에만 입력 (8자 이상 권장)"),
                  _buildTextField("비밀번호 확인", confirmPasswordController, obscure: true, hint: "변경시에만 비밀번호 재입력"),
                ],
              ),
              const SizedBox(height: 20),
              _buildSectionCard(
                title: "추가 정보",
                children: [
                  _buildDropdown("선호 종목", selectedSport, sports, (val) {
                    if (mounted) setState(() => selectedSport = val);
                  }),
                  const SizedBox(height: 10), // 드롭다운 간 간격
                  _buildDropdown("출생년도", selectedBirthYear, years, (val) {
                    if (mounted) setState(() => selectedBirthYear = val);
                  }),
                  const SizedBox(height: 10), // 드롭다운 간 간격
                  _buildDropdown("지역", selectedRegion, regions, (val) {
                    if (mounted) setState(() => selectedRegion = val);
                  }),
                ],
              ),
              const SizedBox(height: 20), // 수정 버튼 위 여백
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.grey.shade100, // 배경과 자연스럽게
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: SafeArea(
                top: false,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : updateUserInfo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent.shade100, // 앱 테마 색상으로 변경 가능
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Text("내 정보 수정", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImagePicker() {
    return Center(
      child: GestureDetector(
        onTap: pickProfileImage,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade300,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: profileImage != null
                      ? FileImage(File(profileImage!.path)) as ImageProvider
                      : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty && Uri.tryParse(_profileImageUrl!)?.isAbsolute == true
                      ? NetworkImage(_profileImageUrl!)
                      : (_profileImageUrl !=null && _profileImageUrl!.isNotEmpty) // 기본 Asset 경로로 설정한 경우
                      ? NetworkImage("$baseUrl$defaultProfilePath") // 기본 프로필 이미지 (서버)
                      : const AssetImage('assets/images/default_profile.png') // 로컬 에셋 기본 이미지
                  ) as ImageProvider,

                ),
              ),
              // child: (profileImage == null && (_profileImageUrl == null || _profileImageUrl!.isEmpty || Uri.tryParse(_profileImageUrl!)?.isAbsolute != true))
              //     ? Icon(Icons.person, size: 70, color: Colors.white70) // 기본 아이콘 (이미지 없을 때)
              //     : null,
            ),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade200, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(1, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(7),
              child: Icon(Icons.camera_alt, color: Colors.pinkAccent.shade100, size: 24),
            )
          ],
        ),
      ),
    );
  }

  // mypage.dart의 _buildSectionCard 와 유사한 위젯 (재사용 또는 별도 구현)
  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.symmetric(vertical: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      color: Colors.white,
      child: Padding( // Card 내부에 패딩을 주어 자식 위젯들이 카드 경계에 붙지 않도록 함
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12), // 타이틀과 첫번째 자식 위젯 사이 간격
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscure = false, String? hint}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0), // 위젯 간 상하 간격
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54)),
            const SizedBox(height: 6),
            TextField(
              controller: controller,
              obscureText: obscure,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.pinkAccent.shade100, width: 1.5),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ],
        ),
      );

  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged) =>
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0), // 위젯 간 상하 간격
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: value,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.pinkAccent.shade100, width: 1.5),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                ),
                items: items.map((e) => DropdownMenuItem<String>(value: e, child: Text(e, style: const TextStyle(fontSize: 16)))).toList(),
                onChanged: onChanged,
                hint: Text("선택하세요", style: TextStyle(color: Colors.grey.shade400, fontSize: 15)),
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down_rounded, color: Colors.grey.shade700, size: 28),
                itemHeight: 50,
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ],
          )
      );
}