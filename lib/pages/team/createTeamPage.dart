import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/service/teamService.dart';
import 'package:project/data/teamEnum.dart';

class CreateTeamPage extends StatefulWidget {
  const CreateTeamPage({super.key});

  @override
  State<CreateTeamPage> createState() => _CreateTeamPageState();
}

class _CreateTeamPageState extends State<CreateTeamPage> {
  final _formKey = GlobalKey<FormState>();

  String teamName = "";
  Event event = Event.soccer;
  Region region = Region.seoul;
  TeamCase teamCase = TeamCase.club;
  AgeGroup ageGroup = AgeGroup.twenties;
  String description = "";
  File? _teamImage;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _teamImage = File(picked.path);
      });
    }
  }

  int _parseAgeGroupToInt(AgeGroup group) {
    switch (group) {
      case AgeGroup.teen:
        return 10;
      case AgeGroup.twenties:
        return 20;
      case AgeGroup.thirties:
        return 30;
      case AgeGroup.fortiesUp:
        return 40;
      default:
        return 0;
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Future(() async {
        bool success = false;
        try {
          final age = _parseAgeGroupToInt(ageGroup);
          await TeamService.createTeam(
            teamName: teamName,
            event: event.name.toUpperCase(),
            region: region.name.toUpperCase(),
            memberAge: age,
            teamCase: teamCase.name.toUpperCase(),
            teamDescription: description,
            teamImage: _teamImage,
          );

          success = true;
        } catch (e) {
          success = false;
        }

        if (!mounted) return;

        if (success) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("등록 완료"),
              content: const Text("팀이 성공적으로 등록되었습니다."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("확인"),
                ),
              ],
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("팀 생성에 실패했습니다. 다시 시도해주세요.")),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("팀 생성")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _teamImage != null
                            ? FileImage(_teamImage!)
                            : const AssetImage('assets/logo_placeholder.png')
                        as ImageProvider,
                      ),
                      const Icon(Icons.camera_alt, color: Colors.white70, size: 30),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: "팀명", hintText: "팀명을 입력해주세요"),
                onSaved: (val) => teamName = val ?? "",
                validator: (val) => val == null || val.isEmpty ? "필수 입력" : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Event>(
                value: event,
                items: Event.values
                    .map((e) => DropdownMenuItem(value: e, child: Text(eventEnumMap[e]!)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => event = val);
                },
                decoration: const InputDecoration(labelText: "종목"),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Region>(
                value: region,
                items: Region.values
                    .map((e) => DropdownMenuItem(value: e, child: Text(regionEnumMap[e]!)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => region = val);
                },
                decoration: const InputDecoration(labelText: "지역"),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<TeamCase>(
                value: teamCase,
                items: TeamCase.values
                    .map((e) => DropdownMenuItem(value: e, child: Text(teamCaseEnumMap[e]!)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => teamCase = val);
                },
                decoration: const InputDecoration(labelText: "팀분류"),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<AgeGroup>(
                value: ageGroup,
                items: AgeGroup.values
                    .map((e) => DropdownMenuItem(value: e, child: Text(ageGroupEnumMap[e]!)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => ageGroup = val);
                },
                decoration: const InputDecoration(labelText: "연령대"),
              ),
              const SizedBox(height: 12),
              TextFormField(
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "팀소개",
                  hintText: "팀 소개를 적어주세요.",
                ),
                onSaved: (val) => description = val ?? "",
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  child: const Text("팀 생성하기"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
