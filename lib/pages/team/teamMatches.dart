import 'package:flutter/material.dart';
import 'package:project/pages/team/widgets/completedMatchesList.dart';
import 'package:project/pages/team/widgets/ongoingMatchesList.dart';

class Teammatches extends StatefulWidget {
  final String teamId;
  const Teammatches({super.key, required this.teamId});

  @override
  State<Teammatches> createState() => _TeammatchesState();
}

class _TeammatchesState extends State<Teammatches>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("경기 일정"),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "진행 중 경기"),
            Tab(text: "완료 경기"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 진행 중 경기 목록 위젯
          OngoingMatchesList(teamId: widget.teamId),
          // 완료 경기 목록 위젯
          CompletedMatchesList(teamId: widget.teamId),
        ],
      ),
    );
  }
}