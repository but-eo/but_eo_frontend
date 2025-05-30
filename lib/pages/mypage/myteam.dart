import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:project/contants/api_contants.dart';
import 'package:project/pages/mypage/EditProfilePage.dart'; // EditProfilePage import
import 'package:project/pages/team/teamDetailPage.dart';
import 'package:project/pages/team/teamFormPage.dart';
import 'package:project/pages/team/teamSearchPage.dart';
import 'package:project/service/teamService.dart';
import 'package:project/utils/token_storage.dart';

class MyTeamPage extends StatefulWidget {
  final int initialTabIndex; // ✨ 1. 초기 탭 인덱스를 받을 변수 추가

  const MyTeamPage({
    super.key,
    this.initialTabIndex = 0, // ✨ 2. 생성자에 파라미터 추가 (기본값 0)
  });

  @override
  State<MyTeamPage> createState() => _MyTeamPageState();
}

class _MyTeamPageState extends State<MyTeamPage> {
  int _tabIndex = 0;

  // "내 정보" 탭을 위한 상태 변수
  Map<String, dynamic>? _userInfo;
  bool _isLoadingUserInfo = true;
  String? _profileFullUrl;

  // "내 팀 목록" 탭을 위한 상태 변수
  List<dynamic> _myLeaderTeams = [];
  bool _isLoadingMyLeaderTeams = true;

  @override
  void initState() {
    super.initState();
    _tabIndex = widget.initialTabIndex; // ✨ 3. 위젯에서 전달받은 값으로 _tabIndex 초기화
    _fetchDataForCurrentTab();
  }

  void _onTabSelected(int index) {
    if (!mounted) return;
    setState(() {
      _tabIndex = index;
    });
    _fetchDataForCurrentTab();
  }

  Future<void> _fetchDataForCurrentTab() async {
    if (!mounted) return;
    if (_tabIndex == 0) {
      if (_userInfo == null || _isLoadingUserInfo == false) {
        await _fetchCurrentUserInfo();
      }
    } else if (_tabIndex == 2) {
      if (_myLeaderTeams.isEmpty || _isLoadingMyLeaderTeams == false) {
        await _fetchMyLeaderTeams();
      }
    }
  }

  Future<void> _fetchCurrentUserInfo() async {
    if (!mounted) return;
    setState(() => _isLoadingUserInfo = true);
    try {
      final token = await TokenStorage.getAccessToken();
      if (token == null) throw Exception("로그인이 필요합니다.");

      final dio = Dio();
      final response = await dio.get(
        "${ApiConstants.baseUrl}/users/me",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (mounted && response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final profilePathFromServer = data['profile'];
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        String? tempProfileFullUrl;

        if (profilePathFromServer != null && profilePathFromServer.toString().isNotEmpty) {
          if (profilePathFromServer.toString().startsWith("http")) {
            tempProfileFullUrl = "$profilePathFromServer?v=$timestamp";
          } else {
            tempProfileFullUrl = "${ApiConstants.imageBaseUrl}$profilePathFromServer?v=$timestamp";
          }
        } else {
          tempProfileFullUrl = "${ApiConstants.imageBaseUrl}/uploads/profiles/DefaultProfileImage.png?v=$timestamp";
        }
        setState(() {
          _userInfo = data;
          _profileFullUrl = tempProfileFullUrl;
          _isLoadingUserInfo = false;
        });
      } else if (mounted) {
        throw Exception("사용자 정보 로드 실패 (${response.statusCode})");
      }
    } catch (e) {
      if (mounted) {
        print("사용자 정보 가져오기 실패 (MyTeamPage - 내 정보 탭): $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사용자 정보를 가져오는 데 실패했습니다.')),
        );
        setState(() => _isLoadingUserInfo = false);
      }
    }
  }

  Future<void> _fetchMyLeaderTeams() async {
    if (!mounted) return;
    setState(() => _isLoadingMyLeaderTeams = true);
    try {
      final teams = await TeamService.getMyTeams();
      if (mounted) {
        setState(() {
          _myLeaderTeams = teams;
          _isLoadingMyLeaderTeams = false;
        });
      }
    } catch (e) {
      if (mounted) {
        print("내 리더 팀 목록 가져오기 실패 (MyTeamPage): $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('리더인 팀 목록을 가져오는 데 실패했습니다.')),
        );
        setState(() => _isLoadingMyLeaderTeams = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: Text(
            _getAppBarTitle(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        iconTheme: const IconThemeData(color: Colors.black87),
        elevation: 0.5,
        actions: [
          if (_tabIndex == 2) ...[
            IconButton(
                icon: const Icon(Icons.search),
                tooltip: "팀 검색",
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const TeamSearchPage()));
                }),
            IconButton(
                icon: const Icon(Icons.add_circle_outline),
                tooltip: "새 팀 만들기",
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TeamFormPage()),
                  );
                  if (result == 'update' || result == true) {
                    _fetchMyLeaderTeams();
                  }
                }),
          ]
        ],
      ),
      body: Column(
        children: [
          _tabBar(theme),
          Expanded(
            child: IndexedStack(
              index: _tabIndex,
              children: [
                _buildMyInfoTab(), // theme 전달 제거
                _buildMyReviewsTab(theme),
                _buildMyLeaderTeamsTab(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_tabIndex) {
      case 0:
        return "내 프로필";
      case 1:
        return "내가 남긴 리뷰";
      case 2:
        return "내 팀 (리더)";
      default:
        return "My Page";
    }
  }

  Widget _tabBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, // AppBar와 동일한 배경색
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ]
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _tabButton("내 프로필", 0, theme),
          _tabButton("내 리뷰", 1, theme),
          _tabButton("내 팀", 2, theme),
        ],
      ),
    );
  }

  Widget _tabButton(String title, int index, ThemeData theme) {
    final isSelected = _tabIndex == index;
    final Color selectedColor = theme.colorScheme.primary;
    final Color unselectedColor = Colors.grey.shade700;

    return Expanded(
      child: InkWell(
        onTap: () => _onTabSelected(index),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? selectedColor : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? selectedColor : unselectedColor,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {
    required Color iconColor,
    required Color labelColor,
    required Color valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor.withOpacity(0.8), size: 22),
          const SizedBox(width: 18),
          SizedBox(
            width: 80,
            child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: labelColor.withOpacity(0.9),
                  fontSize: 14,
                )
            ),
          ),
          const Text(": ", style: TextStyle(fontSize: 14, color: Colors.grey)),
          Expanded(
              child: Text(
                value,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: valueColor),
                overflow: TextOverflow.ellipsis,
              )
          ),
        ],
      ),
    );
  }

  Widget _buildMyInfoTab() {
    // 로컬 색상 정의 (EditProfilePage와 유사하게)
    final Color cardBgColor = Colors.white;
    final Color primaryTextColor = Colors.black87;
    final Color secondaryTextColor = Colors.grey.shade700;
    final Color accentColor = Colors.blue.shade700;

    if (_isLoadingUserInfo) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_userInfo == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sentiment_dissatisfied_outlined, color: Colors.grey.shade400, size: 60),
              const SizedBox(height: 16),
              Text("사용자 정보를 불러올 수 없습니다.", style: TextStyle(fontSize: 16, color: secondaryTextColor)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text("다시 시도"),
                onPressed: _fetchCurrentUserInfo,
                style: ElevatedButton.styleFrom(backgroundColor: accentColor, foregroundColor: Colors.white),
              )
            ],
          ),
        ),
      );
    }

    String getUserInfo(String key, [String defaultValue = '정보 없음']) {
      return _userInfo![key]?.toString() ?? defaultValue;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: _profileFullUrl != null && _profileFullUrl!.isNotEmpty
                    ? NetworkImage(_profileFullUrl!)
                    : null,
                child: (_profileFullUrl == null || _profileFullUrl!.isEmpty)
                    ? Icon(Icons.person_outline, size: 60, color: Colors.grey.shade400)
                    : null,
              ),
              Container(
                decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: cardBgColor, width: 2)
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 18),
              )
            ],
          ),
          const SizedBox(height: 16),
          Text(
            getUserInfo('name'),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: primaryTextColor),
          ),
          const SizedBox(height: 8),
          Text(
            getUserInfo('email'),
            style: TextStyle(color: secondaryTextColor, fontSize: 15),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
                ]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.email_outlined, "이메일", getUserInfo('email'), iconColor: secondaryTextColor, labelColor: secondaryTextColor, valueColor: primaryTextColor),
                Divider(thickness: 0.5, color: Colors.grey.shade200), // ✅ const 제거
                _buildInfoRow(Icons.phone_android_outlined, "전화번호", getUserInfo('tel'), iconColor: secondaryTextColor, labelColor: secondaryTextColor, valueColor: primaryTextColor),
                Divider(thickness: 0.5, color: Colors.grey.shade200), // ✅ const 제거
                _buildInfoRow(Icons.map_outlined, "지역", getUserInfo('region'), iconColor: secondaryTextColor, labelColor: secondaryTextColor, valueColor: primaryTextColor),
                Divider(thickness: 0.5, color: Colors.grey.shade200), // ✅ const 제거
                _buildInfoRow(Icons.sports_kabaddi_outlined, "선호 종목", getUserInfo('preferSports'), iconColor: secondaryTextColor, labelColor: secondaryTextColor, valueColor: primaryTextColor),
                Divider(thickness: 0.5, color: Colors.grey.shade200), // ✅ const 제거
                _buildInfoRow(Icons.transgender_outlined, "성별", getUserInfo('gender'), iconColor: secondaryTextColor, labelColor: secondaryTextColor, valueColor: primaryTextColor),
                Divider(thickness: 0.5, color: Colors.grey.shade200), // ✅ const 제거
                _buildInfoRow(Icons.celebration_outlined, "출생년도", getUserInfo('birth'), iconColor: secondaryTextColor, labelColor: secondaryTextColor, valueColor: primaryTextColor),
              ],
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            icon: const Icon(Icons.manage_accounts_outlined, size: 20, color: Colors.white),
            label: const Text("프로필 정보 관리", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfilePage(
                    initialProfileImageUrl: _profileFullUrl,
                    userInfo: _userInfo,
                  ),
                ),
              );
              if (result == true && mounted) {
                _fetchCurrentUserInfo();
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              elevation: 2.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMyReviewsTab(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.speaker_notes_off_outlined, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text("내가 남긴 리뷰", style: theme.textTheme.titleLarge?.copyWith(fontSize: 18, color: Colors.black87)),
            const SizedBox(height: 12),
            Text("이 기능은 현재 준비 중입니다.\n(백엔드 API 추가 필요)",
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyLeaderTeamsTab(ThemeData theme) {
    if (_isLoadingMyLeaderTeams) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_myLeaderTeams.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.groups_2_outlined, size: 70, color: Colors.grey.shade400),
              const SizedBox(height: 20),
              Text("리더로 있는 팀이 없습니다", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 10),
              Text(
                "새로운 팀을 만들어 리더가 되거나\n다른 팀을 검색하여 활동해보세요!",
                style: TextStyle(fontSize: 15, color: Colors.grey.shade600, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_circle_outline, size: 20),
                label: const Text("새 팀 만들기"),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TeamFormPage()),
                  );
                  if (result == 'update' || result == true) {
                    _fetchMyLeaderTeams();
                  }
                },
                style: theme.elevatedButtonTheme.style?.copyWith(
                  padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                  textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchMyLeaderTeams,
      color: theme.colorScheme.primary,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        itemCount: _myLeaderTeams.length,
        itemBuilder: (context, index) {
          final team = _myLeaderTeams[index];
          final String teamName = team['teamName'] ?? '이름 없음';
          final String? teamPath = team['teamImg'];
          String? teamImageUrl;
          if (teamPath != null && teamPath.isNotEmpty) {
            teamImageUrl = TeamService.getFullTeamImageUrl(teamPath);
          }
          final String teamEvent = TeamService.getEventLabel(team['event']) ?? '종목 미정';
          final String teamRegion = TeamService.getRegionLabel(team['region']) ?? '지역 미정';

          return Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: CircleAvatar(
                radius: 28,
                backgroundImage: teamImageUrl != null ? NetworkImage("$teamImageUrl?v=${DateTime.now().millisecondsSinceEpoch}") : null,
                backgroundColor: Colors.grey.shade200,
                child: teamImageUrl == null ? Icon(Icons.shield_outlined, color: Colors.grey.shade500, size: 28,) : null,
              ),
              title: Text(teamName, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black87)),
              subtitle: Text("$teamEvent · $teamRegion", style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TeamDetailPage(team: Map<String, dynamic>.from(team)),
                  ),
                );
                if (result == 'updated' || result == 'update' || result == 'deleted' || result == 'left') {
                  _fetchMyLeaderTeams();
                }
              },
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 0),
      ),
    );
  }
}