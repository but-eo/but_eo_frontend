import 'package:flutter/material.dart';
import 'package:project/pages/stadium/stadiumFormPage.dart';
import 'package:project/service/stadiumService.dart'; // StadiumService 임포트

class StadiumDetailPage extends StatefulWidget {
  final Map<String, dynamic> stadium; // 상세 정보를 표시할 경기장 데이터
  final bool isLeader; // 현재 사용자가 이 경기장의 관리자(리더)인지 여부
  const StadiumDetailPage({super.key, required this.stadium, this.isLeader = false});

  @override
  State<StadiumDetailPage> createState() => _StadiumDetailPageState();
}

class _StadiumDetailPageState extends State<StadiumDetailPage> {
  late Map<String, dynamic> _currentStadiumData;

  @override
  void initState() {
    super.initState();
    _currentStadiumData = Map<String, dynamic>.from(widget.stadium);
  }

  // 경기장 이미지 URL을 구성하는 헬퍼 함수
  // TODO: 백엔드에서 이미지 가져오는 실제 URL 로직으로 수정 필요
  String _getFullStadiumImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      // 이미지 URL이 없을 때 기본 로고 또는 플레이스홀더 사용
      return "assets/images/butteoLogo.png";
    }
    // TODO: 실제 이미지 서버의 URL과 path를 조합하여 반환하도록 수정 필요
    // 예: return "${ApiConstants.imageUrlBaseUrl}/$path";
    return path; // 현재는 path가 이미 완전한 URL이라고 가정
  }

  // 경기장 데이터를 새로고침하는 함수
  Future<void> _refreshStadiumData() async {
    final String? stadiumId = _currentStadiumData['stadiumId'];
    if (stadiumId != null) {
      final updatedData = await StadiumService.getStadium(stadiumId);
      if (updatedData != null && mounted) {
        setState(() {
          _currentStadiumData = updatedData;
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('경기장 정보를 불러오는데 실패했습니다.')),
        );
      }
    }
  }

  void _navigateToEditPage() async {
    // 수정 페이지로 이동하고, 결과값을 기다립니다.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StadiumFormPage(initialData: _currentStadiumData),
      ),
    );

    // 수정 완료 후 'updated'와 같은 결과가 돌아오면 데이터를 갱신
    if (result == 'updated') {
      await _refreshStadiumData(); // 최신 데이터 다시 불러오기
      if (mounted) Navigator.pop(context, 'updated'); // 이전 페이지로 업데이트 신호 전달
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
        final String? response = await StadiumService.deleteStadium(stadiumId);
        if (response != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("경기장이 성공적으로 삭제되었습니다: $response")),
          );
          Navigator.pop(context, 'deleted'); // 삭제 완료 신호를 이전 페이지로 전달
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("경기장 삭제에 실패했습니다.")),
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
    final String price = _currentStadiumData['price']?.toString() ?? '가격 정보 없음';
    final String location = _currentStadiumData['location'] ?? '위치 정보 없음';
    final String description = _currentStadiumData['description'] ?? '경기장 설명이 없습니다.';
    final String stadiumType = _currentStadiumData['stadiumType'] ?? '종류 미지정';
    final String region = _currentStadiumData['region'] ?? '지역 미지정';

    // 운영 시간 표시 로직
    String operatingHoursText;
    if (_currentStadiumData['alwaysOpen'] == true) {
      operatingHoursText = '상시 운영';
    } else if (_currentStadiumData['startDate'] != null && _currentStadiumData['endDate'] != null) {
      operatingHoursText = '${_currentStadiumData['startDate']} ~ ${_currentStadiumData['endDate']}';
    } else {
      operatingHoursText = '운영 기간 정보 없음';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(stadiumName),
        actions: widget.isLeader
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
                // `_getFullStadiumImageUrl`을 사용하여 이미지 표시
                backgroundImage: _currentStadiumData['imageUrl'] != null && _currentStadiumData['imageUrl'].isNotEmpty
                    ? NetworkImage(_getFullStadiumImageUrl(_currentStadiumData['imageUrl'])) as ImageProvider<Object>?
                    : null,
                child: _currentStadiumData['imageUrl'] == null || _currentStadiumData['imageUrl'].isEmpty
                    ? const Icon(Icons.sports_soccer, size: 50, color: Colors.grey) // 기본 아이콘
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
            _buildInfoRow(Icons.monetization_on, '가격', '$price 원'),
            _buildInfoRow(Icons.location_on, '위치', location),
            _buildInfoRow(Icons.access_time, '운영 기간', operatingHoursText),
            _buildInfoRow(Icons.category, '종류', stadiumType),
            _buildInfoRow(Icons.map, '지역', region),
            const Divider(height: 32),
            Text(
              '경기장 설명',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: 예약하기 기능 구현
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
