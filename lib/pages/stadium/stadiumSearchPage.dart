import 'package:flutter/material.dart';
import 'package:project/pages/components/reusable_filter.dart';
import 'package:project/pages/stadium/stadiumFormPage.dart';
import 'package:project/pages/stadium/stadiumDetailPage.dart';
import 'package:project/service/stadiumService.dart';
import 'package:project/appStyle/app_colors.dart';
import 'package:project/contants/api_contants.dart';

class StadiumSearchPage extends StatefulWidget {
  const StadiumSearchPage({super.key});

  @override
  State<StadiumSearchPage> createState() => _StadiumSearchPageState();
}

class _StadiumSearchPageState extends State<StadiumSearchPage> {
  String _selectedRegion = '전체';
  String _selectedSport = '전체';

  List<dynamic> allStadiums = [];
  List<dynamic> filteredStadiums = [];
  bool isLoading = false;

  final List<String> regions = ['전체', '서울', '경기', '강원', '충청', '전라', '경상', '제주'];
  final List<String> eventTypes = ['전체', '풋살장', '축구장', '농구장', '테니스장', '탁구장', '볼링장'];

  @override
  void initState() {
    super.initState();
    _fetchStadiums();
  }

  Future<void> _fetchStadiums() async {
    setState(() => isLoading = true);
    try {
      final List<dynamic>? stadiums = await StadiumService.getAllStadiums();
      if (stadiums != null && mounted) {
        setState(() {
          allStadiums = stadiums;
          _applyFilters();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('경기장 목록 불러오기 오류: $e')),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      filteredStadiums = allStadiums.where((stadium) {
        final regionMatch = _selectedRegion == '전체' || stadium['stadiumRegion'] == _selectedRegion;
        final stadiumEventsList = (stadium['stadiumEvents'] as String? ?? '')
            .split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toSet();
        final eventMatch = _selectedSport == '전체' || stadiumEventsList.contains(_selectedSport);
        return regionMatch && eventMatch;
      }).toList();
    });
  }

  String _getFullStadiumImageUrl(List<dynamic>? imageUrls) {
    if (imageUrls != null && imageUrls.isNotEmpty && imageUrls[0] is String && imageUrls[0].isNotEmpty) {
      return "${ApiConstants.baseUrl}/${imageUrls[0]}";
    }
    return "assets/images/default_stadium_image.png";
  }

  void _showFilterDialog() {
    ReusableFilter.show(
      context: context,
      regions: regions,
      sports: eventTypes,
      selectedRegion: _selectedRegion,
      selectedSport: _selectedSport,
      onApply: (String region, String sport) {
        setState(() {
          _selectedRegion = region;
          _selectedSport = sport;
        });
        _applyFilters();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('전체 경기장'),
        centerTitle: true,
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.baseWhiteColor,
        actions: [
          ElevatedButton.icon(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list, size: 20, color: AppColors.baseWhiteColor),
            label: const Text('필터', style: TextStyle(color: AppColors.baseWhiteColor)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("검색 결과 (${filteredStadiums.length}개)",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textPrimary)),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const StadiumFormPage()),
                    );
                    if (result == 'created' || result == 'updated' || result == 'deleted') {
                      _fetchStadiums();
                    }
                  },
                  icon: const Icon(Icons.add, color: AppColors.baseWhiteColor),
                  label: const Text('경기장 등록', style: TextStyle(color: AppColors.baseWhiteColor)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
                : filteredStadiums.isEmpty
                ? Center(child: Text("검색된 경기장이 없습니다.", style: TextStyle(color: AppColors.textSecondary)))
                : ListView.builder(
              itemCount: filteredStadiums.length,
              itemBuilder: (context, index) {
                final stadium = filteredStadiums[index];
                final String imageUrl = _getFullStadiumImageUrl(stadium['imageUrls'] as List<dynamic>?);
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
                          ),
                        ),
                      );
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
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 80,
                                height: 80,
                                color: AppColors.baseGrey10Color,
                                child: Icon(Icons.broken_image, color: AppColors.textSubtle),
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
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${stadium['stadiumRegion'] ?? ''} | ${stadium['stadiumEvents'] ?? '종목 없음'}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '가격: ${stadium['stadiumCost']?.toString() ?? '정보 없음'} 원',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '운영 시간: ${stadium['availableHours'] ?? '정보 없음'}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
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