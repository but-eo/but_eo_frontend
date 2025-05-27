import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart'; // MediaType을 위해 추가
// 프로젝트의 실제 경로에 맞게 아래 import 경로를 수정해주세요.
import 'package:project/contants/api_contants.dart';
import 'package:project/utils/token_storage.dart';

class EditProfilePage extends StatefulWidget {
  final String? initialProfileImageUrl; // MyPage에서 전달받는 현재 프로필 이미지 URL
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

  XFile? profileImageFile; // 사용자가 새로 선택한 이미지 파일 (XFile)
  String? currentProfileImageUrl; // 화면에 표시될 최종 이미지 URL (네트워크 또는 로컬 파일 경로 아님)

  final sports = ['축구', '풋살', '테니스', '배드민턴', '탁구', '볼링'];
  final years = List.generate(50, (index) => (DateTime.now().year - 7 - index).toString());
  final regions = ['서울', '경기', '인천', '부산', '대구', '광주', '대전', '울산', '세종', '강원', '충북', '충남', '전북', '전남', '경북', '경남', '제주'];

  // 서버 UsersService.java의 registerUser와 일치하는 기본 프로필 경로
  final String serverDefaultProfilePath = "/uploads/profiles/DefaultProfileImage.png";
  // ApiConstants.imageBaseUrl를 사용하는 것이 좋습니다. baseUrl은 /api를 포함할 수 있기 때문입니다.
  // ApiConstants.dart 파일에 imageBaseUrl이 'http://172.18.5.99:714'와 같이 정의되어 있다고 가정합니다.
  final String imageBaseUrl = ApiConstants.imageBaseUrl;


  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 초기 프로필 이미지 설정: MyPage에서 전달받은 URL 사용
    // 전달받은 URL이 없거나 비어있으면, 서버의 기본 프로필 이미지 경로를 사용
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    if (widget.initialProfileImageUrl != null && widget.initialProfileImageUrl!.isNotEmpty) {
      // initialProfileImageUrl이 이미 완전한 URL인지, 아니면 상대 경로인지 확인 필요.
      // MyPage에서 NetworkImage로 표시했다면 완전한 URL일 가능성이 높음.
      if (widget.initialProfileImageUrl!.startsWith("http")) {
        currentProfileImageUrl = "${widget.initialProfileImageUrl}?v=$timestamp";
      } else {
        // MyPage에서 전달한 URL이 상대경로였다면 imageBaseUrl과 조합
        currentProfileImageUrl = "$imageBaseUrl${widget.initialProfileImageUrl}?v=$timestamp";
      }
    } else {
      currentProfileImageUrl = "$imageBaseUrl$serverDefaultProfilePath?v=$timestamp";
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
      // ApiConstants.baseUrl이 'http://서버주소:포트/api' 형태라고 가정
      final res = await dio.get(
        "${ApiConstants.baseUrl}/users/my-info",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      print("✅ [전체 JSON] 사용자 정보 응답 (EditProfile): ${res.data}");

      if (res.statusCode == 200) {
        final data = res.data;
        if (data is Map<String, dynamic>) {
          String? birthYearString;
          if (data['birth'] != null) birthYearString = data['birth'].toString();
          else if (data['birthYear'] != null) birthYearString = data['birthYear'].toString();

          String? nickname = (data['name'] ?? data['nickname'])?.toString();
          String? preferSports = data['preferSports']?.toString();
          String? region = data['region']?.toString();
          final profilePathFromServerApi = data['profile']; // API 응답의 프로필 경로
          final timestamp = DateTime.now().millisecondsSinceEpoch;

          if (mounted) {
            setState(() {
              nicknameController.text = nickname ?? '';
              selectedSport = (preferSports != null && sports.contains(preferSports)) ? preferSports : null;
              selectedBirthYear = (birthYearString != null && years.contains(birthYearString)) ? birthYearString : null;
              selectedRegion = (region != null && regions.contains(region)) ? region : null;

              if (profilePathFromServerApi != null && profilePathFromServerApi is String && profilePathFromServerApi.isNotEmpty) {
                if (profilePathFromServerApi.startsWith("http")) {
                  currentProfileImageUrl = "$profilePathFromServerApi?v=$timestamp";
                } else {
                  currentProfileImageUrl = "$imageBaseUrl$profilePathFromServerApi?v=$timestamp";
                }
              } else {
                // API 응답에 프로필 정보가 없으면 서버의 기본 경로 사용
                currentProfileImageUrl = "$imageBaseUrl$serverDefaultProfilePath?v=$timestamp";
              }
            });
          }
        } else { /* ... 오류 처리 ... */ }
      } else { /* ... 오류 처리 ... */ }
    } catch (e) {
      print("❗ 사용자 정보 요청 중 오류 (EditProfile): $e");
      if (mounted) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        setState(() {
          currentProfileImageUrl = "$imageBaseUrl$serverDefaultProfilePath?v=$timestamp";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("사용자 정보 로딩 중 오류가 발생했습니다.")),
        );
      }
    }
  }

  Future<void> pickProfileImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (pickedFile != null && mounted) {
        setState(() {
          profileImageFile = pickedFile; // 로컬에서 선택한 파일 (XFile)
        });
      }
    } catch (e) { /* ... 오류 처리 ... */ }
  }

  Future<void> updateUserInfo() async {
    // ... (비밀번호 일치 검사, 토큰 확인 로직은 동일)
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
      if (passwordController.text.isNotEmpty) "password": passwordController.text,
      "birthYear": selectedBirthYear,
      "preferSports": selectedSport,
      "region": selectedRegion,
    };

    if (profileImageFile != null) { // profileImageFile 사용
      String? guessedMimeType = profileImageFile!.mimeType;
      MediaType? mediaType;
      if (guessedMimeType != null) {
        try { mediaType = MediaType.parse(guessedMimeType); } catch (e) { print("❗ MimeType 파싱 오류: $e"); }
      } else {
        String extension = profileImageFile!.name.split('.').last.toLowerCase();
        if (extension == 'jpg' || extension == 'jpeg') mediaType = MediaType('image', 'jpeg');
        else if (extension == 'png') mediaType = MediaType('image', 'png');
      }
      dataMap["profile"] = await MultipartFile.fromFile(
        profileImageFile!.path,
        filename: profileImageFile!.name,
        contentType: mediaType,
      );
    }

    final formData = FormData.fromMap(dataMap);
    final dio = Dio();
    try {
      // ApiConstants.baseUrl이 'http://서버주소:포트/api' 형태라고 가정
      final response = await dio.patch(
        "${ApiConstants.baseUrl}/users/update",
        data: formData,
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      if ((response.statusCode == 200 || response.statusCode == 201) && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("회원정보가 수정되었습니다.")));
        Navigator.pop(context, true); // 성공 시 true 반환하여 MyPage에서 새로고침 유도
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("수정 실패: ${response.data?['message'] ?? response.statusMessage}")));
      }
    } catch (e) {
      // ... (오류 처리 로직은 이전과 동일) ...
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
    final Color scaffoldBgColor = Colors.grey.shade200;
    final Color cardBgColor = Colors.white;
    final Color appBarBgColor = Colors.white;
    final Color primaryTextColor = Colors.black87;
    final Color secondaryTextColor = Colors.grey.shade700;
    final Color accentColor = Colors.blue.shade700;
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
                  _buildTextField("닉네임", nicknameController, hint: "2~10자 이내로 입력해주세요", primaryTextColor: primaryTextColor, secondaryTextColor: secondaryTextColor, inputBorderColor: inputBorderColor, inputFillColor: cardBgColor, accentColor: accentColor),
                ],
              ),
              const SizedBox(height: 20),
              _buildSectionCard(
                title: "계정 정보 (선택)",
                cardBgColor: cardBgColor,
                secondaryTextColor: secondaryTextColor,
                children: [
                  _buildTextField("비밀번호", passwordController, obscure: true, hint: "변경시에만 입력 (8자 이상 권장)", primaryTextColor: primaryTextColor, secondaryTextColor: secondaryTextColor, inputBorderColor: inputBorderColor, inputFillColor: cardBgColor, accentColor: accentColor),
                  _buildTextField("비밀번호 확인", confirmPasswordController, obscure: true, hint: "변경시에만 비밀번호 재입력", primaryTextColor: primaryTextColor, secondaryTextColor: secondaryTextColor, inputBorderColor: inputBorderColor, inputFillColor: cardBgColor, accentColor: accentColor),
                ],
              ),
              const SizedBox(height: 20),
              _buildSectionCard(
                title: "추가 정보",
                cardBgColor: cardBgColor,
                secondaryTextColor: secondaryTextColor,
                children: [
                  _buildDropdown("선호 종목", selectedSport, sports, (val) { if (mounted) setState(() => selectedSport = val); }, primaryTextColor: primaryTextColor, secondaryTextColor: secondaryTextColor, inputBorderColor: inputBorderColor, inputFillColor: cardBgColor, accentColor: accentColor),
                  const SizedBox(height: 10),
                  _buildDropdown("출생년도", selectedBirthYear, years, (val) { if (mounted) setState(() => selectedBirthYear = val); }, primaryTextColor: primaryTextColor, secondaryTextColor: secondaryTextColor, inputBorderColor: inputBorderColor, inputFillColor: cardBgColor, accentColor: accentColor),
                  const SizedBox(height: 10),
                  _buildDropdown("지역", selectedRegion, regions, (val) { if (mounted) setState(() => selectedRegion = val); }, primaryTextColor: primaryTextColor, secondaryTextColor: secondaryTextColor, inputBorderColor: inputBorderColor, inputFillColor: cardBgColor, accentColor: accentColor),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Container(
              color: scaffoldBgColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: SafeArea(
                top: false,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : updateUserInfo,
                  style: ElevatedButton.styleFrom(backgroundColor: accentColor, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 2),
                  child: _isLoading ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))) : const Text("내 정보 수정", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImagePicker(BuildContext context, Color cardBgColor, Color accentColor) {
    ImageProvider? displayImageProvider;
    final timestamp = DateTime.now().millisecondsSinceEpoch; // 캐시 방지를 위해 항상 새로운 타임스탬프

    if (profileImageFile != null) {
      displayImageProvider = FileImage(File(profileImageFile!.path));
    } else if (currentProfileImageUrl != null && currentProfileImageUrl!.isNotEmpty) {
      // currentProfileImageUrl이 이미 ?v=timestamp를 포함하고 있을 수 있으므로, 중복 추가 방지
      String urlToLoad = currentProfileImageUrl!;
      if (!urlToLoad.contains("?v=")) {
        urlToLoad = "$urlToLoad?v=$timestamp";
      }
      displayImageProvider = NetworkImage(urlToLoad);
    }
    // 기본 이미지를 표시해야 하는 경우 (displayImageProvider가 여전히 null일 때)
    // 로컬 에셋을 사용하거나, 서버의 고정된 기본 이미지 경로를 사용
    // 여기서는 currentProfileImageUrl이 initState에서 기본 경로로 설정되므로,
    // 해당 경로가 유효하다면 NetworkImage로 시도될 것입니다.
    // 만약 그것마저 실패하면 아이콘이 표시됩니다.

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
                color: Colors.grey.shade300, // 이미지 없을 시 배경
                border: Border.all(color: cardBgColor, width: 3),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: ClipOval( // CircleAvatar 효과
                child: displayImageProvider != null
                    ? Image(
                  image: displayImageProvider,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print("Error loading displayImageProvider ($currentProfileImageUrl): $error");
                    // 기본 서버 이미지로 fallback (경로 확인 필수)
                    return Image.network(
                        "$imageBaseUrl$serverDefaultProfilePath?v=$timestamp", // 항상 새로운 timestamp
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print("Error loading serverDefaultProfilePath: $error");
                          // 최종 fallback: 아이콘
                          return Icon(Icons.person, size: 70, color: Colors.grey.shade500);
                        }
                    );
                  },
                )
                    : Icon(Icons.person, size: 70, color: Colors.grey.shade500), // displayImageProvider가 null일 때
              ),
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
    // ... (이전 답변과 동일) ...
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
      {bool obscure = false, String? hint,
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
      { required Color primaryTextColor,
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