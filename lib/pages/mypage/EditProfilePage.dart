import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart'; // MediaType을 위해 추가
import 'package:project/contants/api_contants.dart';
import 'package:project/utils/token_storage.dart';

class EditProfilePage extends StatefulWidget {
  final String? initialProfileImageUrl;
  final Map<String, dynamic>? userInfo; // myteam.dart에서 전달받는 사용자 정보

  const EditProfilePage({
    super.key,
    this.initialProfileImageUrl,
    this.userInfo,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final nicknameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final telController = TextEditingController();

  String? selectedSport;
  String? selectedBirthYear;
  String? selectedRegion;
  String? selectedGender;

  XFile? profileImageFile;
  String? currentProfileImageUrlForDisplay; // 화면 표시용 (초기값 + 로컬 선택 이미지 반영)

  final sports = ['축구', '풋살', '농구', '테니스', '배드민턴', '탁구', '볼링'];
  final years = List.generate(80, (index) => (DateTime.now().year - 15 - index).toString());
  final regions = ['서울', '경기', '인천', '부산', '대구', '광주', '대전', '울산', '세종', '강원', '충북', '충남', '전북', '전남', '경북', '경남', '제주'];
  final genders = ['남', '여']; // 서버와 값 일치 필요 (예: "MALE", "FEMALE" 또는 "남", "여")

  final String serverDefaultProfilePath = "/uploads/profiles/DefaultProfileImage.png";
  final String imageBaseUrl = ApiConstants.imageBaseUrl;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeProfileData();
  }

  void _initializeProfileData() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // 초기 프로필 이미지 설정 (MyTeamPage 또는 MyPageScreen에서 전달받은 URL 사용)
    if (widget.initialProfileImageUrl != null && widget.initialProfileImageUrl!.isNotEmpty) {
      currentProfileImageUrlForDisplay = widget.initialProfileImageUrl!.startsWith("http")
          ? "${widget.initialProfileImageUrl}?v=$timestamp" // 이미 NetworkImage URL이라면 그대로 사용 (캐시 방지)
          : "$imageBaseUrl${widget.initialProfileImageUrl}?v=$timestamp";
    } else {
      currentProfileImageUrlForDisplay = "$imageBaseUrl$serverDefaultProfilePath?v=$timestamp";
    }

    // 전달받은 userInfo로 컨트롤러 및 상태 변수 초기값 설정
    if (widget.userInfo != null) {
      nicknameController.text = widget.userInfo!['name'] ?? '';
      telController.text = widget.userInfo!['tel'] ?? '';
      selectedSport = (widget.userInfo!['preferSports'] != null && sports.contains(widget.userInfo!['preferSports']))
          ? widget.userInfo!['preferSports']
          : null;
      selectedBirthYear = (widget.userInfo!['birth'] != null && years.contains(widget.userInfo!['birth'].toString()))
          ? widget.userInfo!['birth'].toString()
          : null;
      selectedRegion = (widget.userInfo!['region'] != null && regions.contains(widget.userInfo!['region']))
          ? widget.userInfo!['region']
          : null;
      // 서버에서 오는 gender 값이 "남", "여" 또는 "MALE", "FEMALE" 등인지 확인 필요
      // 여기서는 "남", "여"로 가정
      selectedGender = (widget.userInfo!['gender'] != null && genders.contains(widget.userInfo!['gender']))
          ? widget.userInfo!['gender']
          : null;
    } else {
      // 만약 userInfo가 null로 전달되었다면 (예: 직접 페이지 접근 시),
      // 여기서 fetchUserInfo() 같은 함수를 호출하여 사용자 정보를 다시 로드할 수 있습니다.
      // 지금은 myteam.dart에서 정보를 받아오는 것을 기본으로 합니다.
      print("EditProfilePage: 초기 사용자 정보가 전달되지 않았습니다. MyTeamPage에서 userInfo를 전달해야 합니다.");
    }
  }


  Future<void> pickProfileImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (pickedFile != null && mounted) {
        setState(() {
          profileImageFile = pickedFile;
          // 로컬 이미지를 선택했으므로 currentProfileImageUrlForDisplay는 사용하지 않음 (FileImage로 직접 표시)
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
      // 백엔드 UserUpdateRequestDto 필드명 확인 필요 (birth or birthYear)
      "birth": selectedBirthYear, // 또는 "birthYear": selectedBirthYear,
      "preferSports": selectedSport,
      "region": selectedRegion,
      "gender": selectedGender, // 서버에서 받는 enum 값과 일치해야 함 (예: "MALE", "FEMALE" 또는 "남", "여")
    };

    if (profileImageFile != null) {
      dataMap["profile"] = await MultipartFile.fromFile(
        profileImageFile!.path,
        filename: profileImageFile!.name,
        contentType: profileImageFile!.mimeType != null ? MediaType.parse(profileImageFile!.mimeType!) : null,
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
    // ✅ 이전에 사용하시던 로컬 색상 변수들을 다시 정의합니다.
    final Color scaffoldBgColor = Colors.grey.shade200;
    final Color cardBgColor = Colors.white;
    final Color appBarBgColor = Colors.white;
    final Color primaryTextColor = Colors.black87;
    final Color secondaryTextColor = Colors.grey.shade700;
    final Color accentColor = Colors.blue.shade700; // 버튼, 포커스 등에 사용될 강조색
    final Color inputFillColor = Colors.white; // 입력 필드 배경색 (카드 내부이므로 흰색이 적절)
    final Color inputBorderColor = Colors.grey.shade400; // 입력 필드 테두리색

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
                  const SizedBox(height: 10), // 드롭다운 사이 간격
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
                    backgroundColor: accentColor, // ✅ 로컬 accentColor 사용
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

  Widget _buildProfileImagePicker(BuildContext context, Color cardBgColor, Color accentColor) {
    ImageProvider? displayImageProvider;
    // 로컬에서 새로 선택한 이미지가 있으면 그것을 우선 표시
    if (profileImageFile != null) {
      displayImageProvider = FileImage(File(profileImageFile!.path));
    }
    // 그렇지 않고, 초기 이미지 URL이 있다면 그것을 표시 (캐시 방지용 timestamp는 initState에서 처리)
    else if (currentProfileImageUrlForDisplay != null && currentProfileImageUrlForDisplay!.isNotEmpty) {
      displayImageProvider = NetworkImage(currentProfileImageUrlForDisplay!);
    }
    // 둘 다 없으면 아이콘 표시 (CircleAvatar의 child로 처리)

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
                image: displayImageProvider != null
                    ? DecorationImage(image: displayImageProvider, fit: BoxFit.cover)
                    : null,
              ),
              child: (displayImageProvider == null)
                  ? Icon(Icons.person, size: 70, color: Colors.grey.shade500) // 아이콘은 이미지가 없을 때만
                  : null,
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
        // ✅ 로컬 색상 변수들을 파라미터로 받음
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
      { // ✅ 로컬 색상 변수들을 파라미터로 받음
        required Color primaryTextColor,
        required Color secondaryTextColor,
        required Color inputBorderColor,
        required Color inputFillColor, // TextField와 통일성을 위해 inputFillColor 사용
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
                  fillColor: inputFillColor, // TextField와 동일한 배경색 사용
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3), // 패딩 조정
                ),
                items: items.map((e) => DropdownMenuItem<String>(value: e, child: Text(e, style: TextStyle(fontSize: 16, color: primaryTextColor)))).toList(),
                onChanged: onChanged,
                hint: Text("선택하세요", style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down_rounded, color: secondaryTextColor, size: 28),
                itemHeight: 50, // 아이템 높이 (기본값)
                style: TextStyle(fontSize: 16, color: primaryTextColor), // 드롭다운 버튼 텍스트 스타일
              ),
            ],
          )
      );
}