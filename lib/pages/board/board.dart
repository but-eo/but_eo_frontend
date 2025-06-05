// lib/pages/board/board.dart
import 'package:flutter/material.dart';
import 'package:project/data/teamEnum.dart'; // 실제 경로와 내용에 맞게 사용
import 'package:project/pages/board/board_page.dart';

class Board extends StatefulWidget {
  const Board({super.key});

  @override
  _BoardState createState() => _BoardState();
}

class _BoardState extends State<Board> {
  String selectedSport = '축구';

  final Color _scaffoldBgColor = Colors.grey.shade200;
  final Color _appBarBgColor = Colors.white;
  final Color _primaryTextColor = Colors.black87;
  final Color _secondaryTextColor = Colors.grey.shade700;
  final Color _accentColor = Colors.blue.shade700;
  final Color _cardBgColor = Colors.white;
  // final Color _iconColor = Colors.black54; // 이 페이지에서는 직접 사용되지 않을 수 있음

  late final List<String> sports;

  @override
  void initState() {
    super.initState();
    try {
      // sports = eventEnumMap.values.toList(); // teamEnum.dart 파일 필요
      // 아래는 임시 데이터입니다. 실제 eventEnumMap 사용 권장
      sports = ['축구', '풋살', '농구', '탁구', '볼링', '테니스', '배드민턴', '야구'];
    } catch (e) {
      print("Warning: eventEnumMap not found. Using placeholder sports list.");
      sports = ['축구', '풋살', '농구', '탁구', '볼링', '테니스', '배드민턴', '야구'];
    }
    if (!sports.contains(selectedSport) && sports.isNotEmpty) {
      selectedSport = sports.first;
    }
  }

  final Map<String, List<String>> boardCategories = {
    '축구': ['자유게시판', '팀찾기게시판', '팀원찾기게시판', '후기게시판', '경기장게시판'],
    '풋살': ['자유게시판', '팀찾기게시판', '팀원찾기게시판', '후기게시판', '경기장게시판'],
    '농구': ['자유게시판', '팀찾기게시판', '팀원찾기게시판', '후기게시판', '경기장게시판'],
    '탁구': ['자유게시판', '팀찾기게시판', '팀원찾기게시판', '후기게시판', '경기장게시판'],
    '볼링': ['자유게시판', '팀찾기게시판', '팀원찾기게시판', '후기게시판', '경기장게시판'],
    '테니스': ['자유게시판', '팀찾기게시판', '팀원찾기게시판', '후기게시판', '경기장게시판'],
    '배드민턴': ['자유게시판', '팀찾기게시판', '팀원찾기게시판', '후기게시판', '경기장게시판'],
    '야구': ['자유게시판', '팀찾기게시판', '팀원찾기게시판', '후기게시판', '경기장게시판'],
  };

  @override
  Widget build(BuildContext context) {
    final currentCategories = boardCategories[selectedSport] ?? [];

    return Scaffold(
      backgroundColor: _scaffoldBgColor,
      appBar: AppBar(
        title: Text('게시판', style: TextStyle(color: _primaryTextColor, fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: _appBarBgColor,
        elevation: 1.0, // AppBar 그림자 살짝 강조
        centerTitle: false,
      ),
      body: CustomScrollView( // 다양한 크기의 위젯과 스크롤 처리를 위해 CustomScrollView 사용
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: _appBarBgColor,
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: SizedBox(
                height: 42, // ChoiceChip 높이
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: sports.length,
                  itemBuilder: (context, index) {
                    final sport = sports[index];
                    final isSelected = sport == selectedSport;
                    return ChoiceChip(
                      label: Text(sport, style: TextStyle(fontSize: 14.5)),
                      selected: isSelected,
                      onSelected: (_) {
                        if (mounted) setState(() => selectedSport = sport);
                      },
                      backgroundColor: Colors.grey.shade200,
                      selectedColor: _accentColor.withOpacity(0.9),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : _primaryTextColor.withOpacity(0.8),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      showCheckmark: false,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 9.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          side: BorderSide(
                            color: isSelected ? _accentColor : Colors.grey.shade300,
                            width: isSelected ? 0 : 1.0, // 선택 안됐을 때만 테두리
                          )
                      ),
                      elevation: isSelected ? 2.0 : 0.0,
                    );
                  },
                  separatorBuilder: (context, index) => const SizedBox(width: 10),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 12.0),
              child: Text(
                '$selectedSport 게시판',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _primaryTextColor,
                ),
              ),
            ),
          ),
          if (currentCategories.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final category = currentCategories[index];
                    return _buildCategoryCard(context, category);
                  },
                  childCount: currentCategories.length,
                ),
              ),
            )
          else
            SliverFillRemaining( // 내용이 없을 때 화면 채우기
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sentiment_dissatisfied_outlined, size: 60, color: _secondaryTextColor.withOpacity(0.7)),
                      const SizedBox(height: 16),
                      Text(
                        "선택하신 '$selectedSport' 종목에는\n게시판 카테고리가 아직 없습니다.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: _secondaryTextColor, fontSize: 16, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          SliverToBoxAdapter(child: const SizedBox(height: 20)), // 하단 여백
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title) {
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.only(bottom: 10.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      color: _cardBgColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(10.0),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BoardPage(
                event: selectedSport,
                category: title,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w500, color: _primaryTextColor),
              ),
              Icon(Icons.arrow_forward_ios, size: 18, color: _secondaryTextColor.withOpacity(0.7)),
            ],
          ),
        ),
      ),
    );
  }
}