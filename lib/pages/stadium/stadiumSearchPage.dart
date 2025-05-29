import 'package:flutter/material.dart';
import 'package:project/pages/stadium/stadiumFormPage.dart';
import 'package:project/pages/stadium/stadiumDetailPage.dart';

class StadiumSearchPage extends StatefulWidget {
  const StadiumSearchPage({super.key});

  @override
  State<StadiumSearchPage> createState() => _StadiumSearchPageState();
}

class _StadiumSearchPageState extends State<StadiumSearchPage> {
  String selectedRegion = "전체";
  String selectedStadiumType = "전체";
  List<dynamic> allStadiums = []; // 전체 경기장 목록
  List<dynamic> filteredStadiums = []; // 필터링된 경기장 목록
  bool isLoading = false;

  final List<String> regions = ['전체', '서울', '경기', '강원', '충청', '전라', '경상', '제주'];
  final List<String> stadiumTypes = ['전체', '풋살장', '축구장', '농구장', '테니스장'];

  @override
  void initState() {
    super.initState();
    _fetchStadiums();
  }

  Future<void> _fetchStadiums() async {
    if (mounted) {
      setState(() => isLoading = true);
    }
    try {
      // TODO: 실제 StadiumService.fetchStadiums() 호출로 대체
      // final result = await StadiumService.fetchStadiums();
      // allStadiums = result;
      // 임시 데이터
      allStadiums = [
        {
          'id': '1',
          'stadiumName': '우리동네 풋살장',
          'price': 30000,
          'location': '서울 강남구 역삼동',
          'stadiumType': '풋살장',
          'region': '서울',
          'imageUrl': 'stadium1.jpg',
          'startDate': '2024-01-01',
          'endDate': '2024-12-31',
          'alwaysOpen': false,
          'description': '도심 속 쾌적한 풋살장입니다. 주차 가능.'
        },
        {
          'id': '2',
          'stadiumName': '용산 농구 코트',
          'price': 20000,
          'location': '서울 용산구 이태원동',
          'stadiumType': '농구장',
          'region': '서울',
          'imageUrl': 'stadium2.jpg',
          'alwaysOpen': true,
          'description': '야외 농구 코트. 조명 시설 완비.'
        },
        {
          'id': '3',
          'stadiumName': '부산 해운대 테니스장',
          'price': 25000,
          'location': '부산 해운대구',
          'stadiumType': '테니스장',
          'region': '부산',
          'imageUrl': 'stadium3.jpg',
          'startDate': '2025-03-01',
          'endDate': '2025-11-30',
          'alwaysOpen': false,
          'description': '바다를 보며 테니스를 칠 수 있는 아름다운 테니스장.'
        },
        {
          'id': '4',
          'stadiumName': '대구 달서구 축구장',
          'price': 40000,
          'location': '대구 달서구',
          'stadiumType': '축구장',
          'region': '대구',
          'imageUrl': 'stadium4.jpg',
          'alwaysOpen': false,
          'startDate': '2025-01-01',
          'endDate': '2025-12-31',
          'description': '잔디 상태 최상의 축구장.'
        },
      ];
      _applyFilters();
    } catch (e) {
      print("경기장 조회 실패: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("경기장 목록을 불러오는데 실패했습니다: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _applyFilters() {
    setState(() {
      filteredStadiums = allStadiums.where((stadium) {
        final regionMatch = selectedRegion == "전체" || stadium['region'] == selectedRegion;
        final typeMatch = selectedStadiumType == "전체" || stadium['stadiumType'] == selectedStadiumType;
        return regionMatch && typeMatch;
      }).toList();
    });
  }

  // 경기장 이미지 URL을 구성하는 헬퍼 함수 (StadiumService에서 가져올 수 있음)
  String _getFullStadiumImageUrl(String? path) {
    if (path == null || path.isEmpty) return "";
    return "assets/images/butteoLogo.png";//임시
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('전체 경기장'),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 5),

          //지역필터
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: regions.map((region) {
                final isSelected = region == selectedRegion;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: ChoiceChip(
                    label: Text(region),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => selectedRegion = region);
                      _applyFilters();
                    },
                    selectedColor: Colors.grey[700],
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                    side: BorderSide(color: isSelected ? Colors.grey[700]! : Colors.grey.shade400),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          // 구장 타입 필터
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: stadiumTypes.map((type) {
                final isSelected = type == selectedStadiumType;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: ChoiceChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => selectedStadiumType = type);
                      _applyFilters();
                    },
                    selectedColor: Colors.grey[700],
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                    side: BorderSide(color: isSelected ? Colors.grey[700]! : Colors.grey.shade400),
                  ),
                );
              }).toList(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("검색 결과 (${filteredStadiums.length}개)", style: Theme.of(context).textTheme.titleMedium),
                ElevatedButton.icon(
                  onPressed: () async {
                    // 경기장 등록 페이지로 이동
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const StadiumFormPage()),
                    );
                    // 등록 또는 수정 후 돌아왔을 때 목록 갱신
                    if (result == 'created' || result == 'updated' || result == 'deleted') {
                      _fetchStadiums();
                    }
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('경기장 등록', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredStadiums.isEmpty
                ? const Center(child: Text("검색된 경기장이 없습니다."))
                : ListView.builder(
              itemCount: filteredStadiums.length,
              itemBuilder: (context, index) {
                final stadium = filteredStadiums[index];
                // 경기장 이미지 URL (임시)
                final String imageUrl = _getFullStadiumImageUrl(stadium['imageUrl']);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: InkWell(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StadiumDetailPage(
                            stadium: stadium,
                            isLeader: index == 0, // 첫 번째 경기장은 리더로 가정
                          ),
                        ),
                      );
                      // 상세 페이지에서 수정/삭제 후 돌아왔을 때 목록 갱신
                      if (result == 'updated' || result == 'deleted') {
                        _fetchStadiums();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.broken_image, color: Colors.grey),
                                  ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stadium['stadiumName'] ?? '이름 없음',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${stadium['region'] ?? ''} | ${stadium['stadiumType'] ?? ''}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '가격: ${stadium['price']?.toString() ?? '정보 없음'} 원',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}