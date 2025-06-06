// lib/pages/mypage/EditProfilePage.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;
import 'package:project/contants/api_contants.dart';
import 'package:project/utils/token_storage.dart';

class EditProfilePage extends StatefulWidget {
  final String? initialProfileImageUrl;
  final Map<String, dynamic>? userInfo;

  const EditProfilePage({
    super.key,
    this.initialProfileImageUrl,
    this.userInfo,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // ... (다른 컨트롤러 및 변수 선언은 이전과 동일) ...
  final nicknameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final telController = TextEditingController();

  String? selectedSport;
  String? selectedBirthYear;
  String? selectedRegion;
  String? selectedGender;

  XFile? profileImageFile;
  String? currentProfileImageUrlForDisplay;

  final sports = ['축구', '풋살', '농구', '테니스', '배드민턴', '탁구', '볼링'];
  final years = List.generate(80, (index) => (DateTime.now().year - 15 - index).toString());
  final regions = ['서울', '경기', '인천', '부산', '대구', '광주', '대전', '울산', '세종', '강원', '충북', '충남', '전북', '전남', '경북', '경남', '제주'];
  final genders = ['남', '여'];

  final String serverDefaultProfilePath = "/uploads/profiles/DefaultProfileImage.png";
  final String imageBaseUrl = ApiConstants.imageBaseUrl;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeProfileData();
  }

  void _initializeProfileData() {
    // ... (이전과 동일한 초기화 로직) ...
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    if (widget.initialProfileImageUrl != null && widget.initialProfileImageUrl!.isNotEmpty) {
      currentProfileImageUrlForDisplay = widget.initialProfileImageUrl!.startsWith("http")
          ? "${widget.initialProfileImageUrl}?v=$timestamp"
          : "$imageBaseUrl${widget.initialProfileImageUrl}?v=$timestamp";
    } else {
      currentProfileImageUrlForDisplay = "$imageBaseUrl$serverDefaultProfilePath?v=$timestamp";
    }
    if (widget.userInfo != null) {
      nicknameController.text = widget.userInfo!['name'] ?? '';
      telController.text = widget.userInfo!['tel'] ?? '';
      selectedSport = (widget.userInfo!['preferSports'] != null && sports.contains(widget.userInfo!['preferSports'])) ? widget.userInfo!['preferSports'] : null;
      selectedBirthYear = (widget.userInfo!['birth'] != null && years.contains(widget.userInfo!['birth'].toString())) ? widget.userInfo!['birth'].toString() : null;
      selectedRegion = (widget.userInfo!['region'] != null && regions.contains(widget.userInfo!['region'])) ? widget.userInfo!['region'] : null;
      selectedGender = (widget.userInfo!['gender'] != null && genders.contains(widget.userInfo!['gender'])) ? widget.userInfo!['gender'] : null;
    } else {
      print("EditProfilePage: 초기 사용자 정보가 전달되지 않았습니다.");
    }
  }

  // ✨ 2. 파일 확장자를 보고 MIME 타입을 결정하는 헬퍼 함수 추가
  MediaType? _getMimeType(String filePath) {
    final extension = p.extension(filePath).toLowerCase();
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return MediaType('image', 'jpeg');
      case '.png':
        return MediaType('image', 'png');
      case '.gif':
        return MediaType('image', 'gif');
      case '.heic': // iOS에서 흔한 포맷
        return MediaType('image', 'heic');
      case '.heif':
        return MediaType('image', 'heif');
      default:
      // 알 수 없는 경우, 일반적인 이미지 타입 또는 null 반환
        return MediaType('image', 'jpeg'); // 기본값으로 jpeg 제공
    }
  }

  Future<void> pickProfileImage() async {
    // ... (이전과 동일한 이미지 선택 로직) ...
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (pickedFile != null && mounted) {
        setState(() {
          profileImageFile = pickedFile;
        });
      }
    } catch (e) {
      print("이미지 선택 오류: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("이미지를 가져오는 데 실패했습니다.")));
      }
    }
  }

  Future<void> updateUserInfo() async {
    if (passwordController.text.isNotEmpty && passwordController.text != confirmPasswordController.text) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("비밀번호가 일치하지 않습니다.")));
      return;
    }
    final token = await TokenStorage.getAccessToken();
    if (token == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("로그인이 필요합니다.")));
      return;
    }
    if (mounted) setState(() => _isLoading = true);

    final Map<String, dynamic> dataMap = {
      "name": nicknameController.text,
      "tel": telController.text,
      if (passwordController.text.isNotEmpty) "password": passwordController.text,
      "birth": selectedBirthYear,
      "preferSports": selectedSport,
      "region": selectedRegion,
      "gender": selectedGender,
    };

    if (profileImageFile != null) {
      // ✨ 3. MIME 타입 결정 로직 강화
      MediaType? contentType;
      if (profileImageFile!.mimeType != null) {
        try {
          contentType = MediaType.parse(profileImageFile!.mimeType!);
        } catch(e) {
          print("Warning: Could not parse mimeType '${profileImageFile!.mimeType}', falling back to extension check.");
          contentType = _getMimeType(profileImageFile!.path);
        }
      } else {
        // mimeType이 null인 경우, 파일 경로(확장자)로 추정
        contentType = _getMimeType(profileImageFile!.path);
      }

      dataMap["profile"] = await MultipartFile.fromFile(
        profileImageFile!.path,
        filename: profileImageFile!.name,
        contentType: contentType, // 강화된 로직으로 결정된 contentType 사용
      );
    }

    final formData = FormData.fromMap(dataMap);
    final dio = Dio();
    try {
      final response = await dio.patch(
        "${ApiConstants.baseUrl}/users/update",
        data: formData,
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      if ((response.statusCode == 200 || response.statusCode == 201) && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("회원정보가 수정되었습니다.")));
        Navigator.pop(context, true); // 성공 시 true 반환
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("수정 실패: ${response.data?['message'] ?? response.statusMessage}")));
      }
    } catch (e) {
      String errorMessage = "회원정보 수정 중 오류가 발생했습니다.";
      if (e is DioException && e.response != null) {
        final responseData = e.response!.data;
        if (responseData is Map && responseData.containsKey('message')) errorMessage = responseData['message'].toString();
        else if (responseData is String && responseData.isNotEmpty) errorMessage = responseData;
        else if (e.response!.statusMessage != null && e.response!.statusMessage!.isNotEmpty) errorMessage = e.response!.statusMessage!;
      }
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (build 메소드 내부는 이전과 동일) ...
    final Color scaffoldBgColor = Colors.grey.shade200;
    final Color cardBgColor = Colors.white;
    final Color appBarBgColor = Colors.white;
    final Color primaryTextColor = Colors.black87;
    final Color secondaryTextColor = Colors.grey.shade700;
    final Color accentColor = Colors.blue.shade700;
    final Color inputFillColor = Colors.white;
    final Color inputBorderColor = Colors.grey.shade400;

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: appBarBgColor,
        title: Text("내 정보 수정", style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: primaryTextColor),
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            children: [
              _buildProfileImagePicker(context, cardBgColor, accentColor),
              const SizedBox(height: 24),
              _buildSectionCard(
                title: "기본 정보",
                cardBgColor: cardBgColor,
                secondaryTextColor: secondaryTextColor,
                children: [
                  _buildTextField("닉네임", nicknameController, hint: "2~10자 이내로 입력해주세요",
                      primaryTextColor: primaryTextColor, secondaryTextColor: secondaryTextColor, inputBorderColor: inputBorderColor, inputFillColor: inputFillColor, accentColor: accentColor),
                  _buildTextField("전화번호", telController, hint: "010-0000-0000", keyboardType: TextInputType.phone,
                      primaryTextColor: primaryTextColor, secondaryTextColor: secondaryTextColor, inputBorderColor: inputBorderColor, inputFillColor: inputFillColor, accentColor: accentColor),
                ],
              ),
              const SizedBox(height: 20),
              _buildSectionCard(
                title: "계정 정보 (선택)",
                cardBgColor: cardBgColor,
                secondaryTextColor: secondaryTextColor,
                children: [
                  _buildTextField("비밀번호", passwordController, obscure: true, hint: "변경시에만 입력 (8자 이상 권장)",
                      primaryTextColor: primaryTextColor, secondaryTextColor: secondaryTextColor, inputBorderColor: inputBorderColor, inputFillColor: inputFillColor, accentColor: accentColor),
                  _buildTextField("비밀번호 확인", confirmPasswordController, obscure: true, hint: "변경시에만 비밀번호 재입력",
                      primaryTextColor: primaryTextColor, secondaryTextColor: secondaryTextColor, inputBorderColor: inputBorderColor, inputFillColor: inputFillColor, accentColor: accentColor),
                ],
              ),
              const SizedBox(height: 20),
              _buildSectionCard(
                title: "추가 정보",
                cardBgColor: cardBgColor,
                secondaryTextColor: secondaryTextColor,
                children: [
                  _buildDropdown("성별", selectedGender, genders, (val) { if (mounted) setState(() => selectedGender = val); },
                      primaryTextColor: primaryTextColor, secondaryTextColor: secondaryTextColor, inputBorderColor: inputBorderColor, inputFillColor: inputFillColor, accentColor: accentColor),
                  const SizedBox(height: 10),
                  _buildDropdown("선호 종목", selectedSport, sports, (val) { if (mounted) setState(() => selectedSport = val); },
                      primaryTextColor: primaryTextColor, secondaryTextColor: secondaryTextColor, inputBorderColor: inputBorderColor, inputFillColor: inputFillColor, accentColor: accentColor),
                  const SizedBox(height: 10),
                  _buildDropdown("출생년도", selectedBirthYear, years, (val) { if (mounted) setState(() => selectedBirthYear = val); },
                      primaryTextColor: primaryTextColor, secondaryTextColor: secondaryTextColor, inputBorderColor: inputBorderColor, inputFillColor: inputFillColor, accentColor: accentColor),
                  const SizedBox(height: 10),
                  _buildDropdown("지역", selectedRegion, regions, (val) { if (mounted) setState(() => selectedRegion = val); },
                      primaryTextColor: primaryTextColor, secondaryTextColor: secondaryTextColor, inputBorderColor: inputBorderColor, inputFillColor: inputFillColor, accentColor: accentColor),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Container(
              color: scaffoldBgColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12).copyWith(bottom: MediaQuery.of(context).padding.bottom + 8),
              child: ElevatedButton(
                onPressed: _isLoading ? null : updateUserInfo,
                style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2
                ),
                child: _isLoading
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                    : const Text("내 정보 수정", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ... (_buildProfileImagePicker, _buildSectionCard, _buildTextField, _buildDropdown 위젯들은 이전과 동일) ...
  Widget _buildProfileImagePicker(BuildContext context, Color cardBgColor, Color accentColor) {
    ImageProvider? displayImageProvider;
    if (profileImageFile != null) {
      displayImageProvider = FileImage(File(profileImageFile!.path));
    }
    else if (currentProfileImageUrlForDisplay != null && currentProfileImageUrlForDisplay!.isNotEmpty) {
      displayImageProvider = NetworkImage(currentProfileImageUrlForDisplay!);
    }
    return Center(
      child: GestureDetector(
        onTap: pickProfileImage,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade300,
                border: Border.all(color: cardBgColor, width: 3),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                image: displayImageProvider != null ? DecorationImage(image: displayImageProvider, fit: BoxFit.cover) : null,
              ),
              child: (displayImageProvider == null) ? Icon(Icons.person, size: 70, color: Colors.grey.shade500) : null,
            ),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle, color: cardBgColor,
                border: Border.all(color: Colors.grey.shade200, width: 1),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(1, 2))],
              ),
              padding: const EdgeInsets.all(7),
              child: Icon(Icons.camera_alt, color: accentColor, size: 24),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
    required Color cardBgColor,
    required Color secondaryTextColor,
  }) {
    return Container(
      decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
          ]
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: secondaryTextColor),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscure = false, String? hint, TextInputType? keyboardType,
        required Color primaryTextColor,
        required Color secondaryTextColor,
        required Color inputBorderColor,
        required Color inputFillColor,
        required Color accentColor,
      }) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: secondaryTextColor)),
            const SizedBox(height: 6),
            TextField(
              controller: controller,
              obscureText: obscure,
              keyboardType: keyboardType,
              style: TextStyle(fontSize: 16, color: primaryTextColor),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: inputBorderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: inputBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: accentColor, width: 1.5),
                ),
                filled: true,
                fillColor: inputFillColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ],
        ),
      );

  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged,
      {
        required Color primaryTextColor,
        required Color secondaryTextColor,
        required Color inputBorderColor,
        required Color inputFillColor,
        required Color accentColor,
      }) =>
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: secondaryTextColor)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: value,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: inputBorderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: inputBorderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: accentColor, width: 1.5),
                  ),
                  filled: true,
                  fillColor: inputFillColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                ),
                items: items.map((e) => DropdownMenuItem<String>(value: e, child: Text(e, style: TextStyle(fontSize: 16, color: primaryTextColor)))).toList(),
                onChanged: onChanged,
                hint: Text("선택하세요", style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down_rounded, color: secondaryTextColor, size: 28),
                itemHeight: 50,
                style: TextStyle(fontSize: 16, color: primaryTextColor),
              ),
            ],
          )
      );
}