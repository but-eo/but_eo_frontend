import 'package:flutter/material.dart';
import 'package:project/pages/stadium/stadiumFormPage.dart';
import 'package:project/service/stadiumService.dart';
import 'package:project/contants/api_contants.dart';
import 'package:project/utils/token_storage.dart';

class StadiumDetailPage extends StatefulWidget {
  final Map<String, dynamic> stadium;
  const StadiumDetailPage({super.key, required this.stadium});

  @override
  State<StadiumDetailPage> createState() => _StadiumDetailPageState();
}

class _StadiumDetailPageState extends State<StadiumDetailPage> {
  late Map<String, dynamic> _currentStadiumData;
  bool isOwner = false;

  @override
  void initState() {
    super.initState();
    _currentStadiumData = Map<String, dynamic>.from(widget.stadium);
    _checkOwnership();
    _refreshStadiumData();
  }

  Future<void> _checkOwnership() async {
    final nickname = await TokenStorage.getUserNickname(); 
    final ownerNickname = _currentStadiumData['ownerNickname'];

    if (nickname != null && ownerNickname != null && nickname == ownerNickname) {
      setState(() {
        isOwner = true;
      });
    }
  }

  String _getFullStadiumImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return "assets/images/butteoLogo.png";
    }
    return "${ApiConstants.baseUrl}$path";
  }

  Future<void> _refreshStadiumData() async {
    final String? stadiumId = _currentStadiumData['stadiumId'];
    if (stadiumId != null) {
      final updatedData = await StadiumService.getStadium(stadiumId);
      if (updatedData != null && mounted) {
        setState(() {
          _currentStadiumData = updatedData;
        });
        await _checkOwnership();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('경기장 정보를 불러오는데 실패했습니다.')),
        );
      }
    }
  }

  void _navigateToEditPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StadiumFormPage(initialData: _currentStadiumData),
      ),
    );

    if (result == 'updated') {
      await _refreshStadiumData();
      if (mounted) Navigator.pop(context, 'updated');
    }
  }

  void _deleteStadium() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("경기장 삭제"),
        content: Text("${_currentStadiumData['stadiumName']}을(를) 정말로 삭제하시겠습니까?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("취소"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("삭제"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final String? stadiumId = _currentStadiumData['stadiumId'];
      if (stadiumId != null) {
        final String? errorMessage = await StadiumService.deleteStadium(stadiumId);
        if (errorMessage == null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("경기장이 성공적으로 삭제되었습니다.")),
          );
          Navigator.pop(context, 'deleted');
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("경기장 삭제에 실패했습니다: ${errorMessage ?? '알 수 없는 오류'}")),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("삭제할 경기장 ID를 찾을 수 없습니다.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String stadiumName = _currentStadiumData['stadiumName'] ?? '이름 없음';
    final int stadiumCost = _currentStadiumData['stadiumCost'] ?? 0;
    final String stadiumRegion = _currentStadiumData['stadiumRegion'] ?? '지역 정보 없음';
    final String stadiumTel = _currentStadiumData['stadiumTel'] ?? '전화번호 정보 없음';
    final String availableDays = _currentStadiumData['availableDays'] ?? '이용 가능 요일 정보 없음';
    final String availableHours = _currentStadiumData['availableHours'] ?? '이용 가능 시간 정보 없음';
    final int stadiumMany = _currentStadiumData['stadiumMany'] ?? 0;
    final String ownerNickname = _currentStadiumData['ownerNickname'] ?? '소유자 정보 없음';

    final List<dynamic>? imageUrls = _currentStadiumData['imageUrls'];
    String? displayImageUrl;
    if (imageUrls != null && imageUrls.isNotEmpty) {
      displayImageUrl = imageUrls[0];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(stadiumName),
        actions: isOwner
            ? [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navigateToEditPage,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteStadium,
          ),
        ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: displayImageUrl != null && displayImageUrl.isNotEmpty
                    ? NetworkImage(_getFullStadiumImageUrl(displayImageUrl)) as ImageProvider<Object>?
                    : null,
                child: displayImageUrl == null || displayImageUrl.isEmpty
                    ? Image.asset("assets/images/butteoLogo.png", fit: BoxFit.cover)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                stadiumName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoRow(Icons.monetization_on, '이용 요금', '$stadiumCost 원'),
            _buildInfoRow(Icons.location_on, '지역', stadiumRegion),
            _buildInfoRow(Icons.phone, '연락처', stadiumTel),
            _buildInfoRow(Icons.calendar_today, '이용 가능 요일', availableDays),
            _buildInfoRow(Icons.access_time, '이용 가능 시간', availableHours),
            _buildInfoRow(Icons.people, '수용 인원', '$stadiumMany 명'),
            _buildInfoRow(Icons.person, '소유자', ownerNickname),
            const Divider(height: 32),
            Text(
              '경기장 설명',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '$stadiumName은(는) $stadiumRegion에 위치한 경기장입니다. $availableDays에 $availableHours 동안 이용 가능합니다.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  print('예약하기 버튼 클릭');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '예약하기',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[700], size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
