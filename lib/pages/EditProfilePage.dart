import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/contants/api_contants.dart';
import 'package:project/utils/token_storage.dart';

class EditProfilePage extends StatefulWidget {
  final String? initialProfileImageUrl;
  const EditProfilePage({super.key, this.initialProfileImageUrl});

  @override
  State createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final nicknameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? selectedSport;
  String? selectedBirthYear;
  String? selectedRegion;

  XFile? profileImage;
  String? _profileImageUrl;

  final sports = ['축구', '풋살', '테니스', '배드민턴', '탁구', '볼링'];
  final years = List.generate(50, (index) => (DateTime.now().year - index).toString());
  final regions = ['서울', '경기', '부산', '대구', '광주', '제주'];

  @override
  void initState() {
    super.initState();
    _profileImageUrl = widget.initialProfileImageUrl;
    fetchUserInfo();
  }

  Future fetchUserInfo() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) return;
    final dio = Dio();
    final res = await dio.get(
      "${ApiConstants.baseUrl}/users/my-info",
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    if (res.statusCode == 200) {
      final data = res.data;
      setState(() {
        nicknameController.text = data['nickname']?.toString() ?? '';
        selectedSport = data['preferSports']?.toString();
        selectedBirthYear = data['birthYear']?.toString();
        selectedRegion = data['region']?.toString();
        // 서버에서 최신 프로필 이미지가 내려오면 갱신
        if (data['profile'] != null && data['profile'].toString().isNotEmpty) {
          _profileImageUrl = data['profile'];
        }
      });
    }
  }

  Future pickProfileImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => profileImage = picked);
    }
  }

  Future updateUserInfo() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("비밀번호가 일치하지 않습니다.")),
      );
      return;
    }
    final token = await TokenStorage.getAccessToken();
    if (token == null) return;

    final formData = FormData.fromMap({
      "name": nicknameController.text,
      "password": passwordController.text,
      "birthYear": selectedBirthYear,
      "preferSports": selectedSport,
      "region": selectedRegion,
      if (profileImage != null)
        "profile": await MultipartFile.fromFile(profileImage!.path, filename: profileImage!.name),
    });

    final dio = Dio();
    final response = await dio.patch(
      "${ApiConstants.baseUrl}/users/update",
      data: formData,
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("회원정보가 수정되었습니다.")),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String baseUrl = "http://${ApiConstants.serverUrl}:714";
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("내 정보 수정", style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickProfileImage,
              child: ClipOval(
                child: Container(
                  width: 120,
                  height: 120,
                  color: Colors.grey.shade200,
                  child: profileImage != null
                      ? Image.file(File(profileImage!.path), fit: BoxFit.cover)
                      : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty
                      ? Image.network(
                    _profileImageUrl!.startsWith("http")
                        ? _profileImageUrl!
                        : "$baseUrl${_profileImageUrl!}",
                    fit: BoxFit.cover,
                  )
                      : const Icon(Icons.camera_alt, size: 50, color: Colors.grey)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField("닉네임", nicknameController),
            _buildTextField("비밀번호", passwordController, obscure: true),
            _buildTextField("비밀번호 확인", confirmPasswordController, obscure: true),
            _buildDropdown("선호 종목", selectedSport, sports, (val) => setState(() => selectedSport = val)),
            _buildDropdown("출생년도", selectedBirthYear, years, (val) => setState(() => selectedBirthYear = val)),
            _buildDropdown("지역", selectedRegion, regions, (val) => setState(() => selectedRegion = val)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateUserInfo,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent.shade100,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text("수정하기"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool obscure = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        ),
      );

  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
          items: items.map((e) => DropdownMenuItem<String>(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      );
}
