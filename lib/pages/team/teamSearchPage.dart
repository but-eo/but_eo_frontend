import 'package:flutter/material.dart';

class TeamSearchPage extends StatefulWidget {
  const TeamSearchPage({super.key});

  @override
  State<TeamSearchPage> createState() => TeamSearchPageState();
}

class TeamSearchPageState extends State<TeamSearchPage> {
  final List<String> regions = ["전체", "서울", "경기", "강원", "충청", "전라", "경상", "제주"];
  final List<String> sports = ["전체", "축구", "야구", "농구", "테니스", "배드민턴", "탁구", "볼링"];

  String selectedRegion = "전체";
  String selectedSport = "전체";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 16),
          const Text("전체 팀", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Divider(),

          // 🔶 지역 필터
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
                      setState(() {
                        selectedRegion = region;
                      });
                    },
                    selectedColor: Colors.orange,
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 10),

          // 🔷 종목 필터
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: sports.map((sport) {
                final isSelected = sport == selectedSport;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: ChoiceChip(
                    label: Text(sport),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        selectedSport = sport;
                      });
                    },
                    selectedColor: Colors.grey[700],
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // 📋 테이블 헤더
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("팀명", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("종목"),
                Text("활동지역"),
                Text("연령대"),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 📄 팀 리스트
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundImage: AssetImage('assets/logo_placeholder.png'),
                  ),
                  title: const Text("피구시치"),
                  subtitle: const Text("탁구 · 경기도 · 20~30대"),
                  onTap: () {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
