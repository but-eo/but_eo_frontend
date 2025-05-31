import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:project/service/teamService.dart';
import 'package:project/data/teamEnum.dart';

class TeamFormPage extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const TeamFormPage({super.key, this.initialData});

  @override
  State<TeamFormPage> createState() => _TeamFormPageState();
}

class _TeamFormPageState extends State<TeamFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final bool isEdit;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  AgeGroup? selectedAgeGroup;
  Region? selectedRegion;
  Event? selectedEvent;
  TeamCase? selectedCase;
  File? imageFile;
  String? initialImageUrl;

  T? enumFromBackend<T>(String? value, List<T> enumValues) {
    if (value == null) return null;
    return enumValues.firstWhere(
          (e) => e.toString().split('.').last.toUpperCase() == value.toUpperCase(),
      orElse: () => enumValues.first,
    );
  }

  @override
  void initState() {
    super.initState();
    isEdit = widget.initialData != null;

    _nameController = TextEditingController(text: widget.initialData?['teamName'] ?? '');
    _descriptionController = TextEditingController(text: widget.initialData?['teamDescription'] ?? '');

    final regionStr = widget.initialData?['region'];
    final eventStr = widget.initialData?['event'];
    final caseStr = widget.initialData?['teamCase'];
    final ageVal = widget.initialData?['memberAge'];

    selectedRegion = enumFromBackend(regionStr, Region.values) ?? Region.seoul;
    selectedEvent = enumFromBackend(eventStr, Event.values) ?? Event.soccer;
    selectedCase = enumFromBackend(caseStr, TeamCase.values) ?? TeamCase.club;
    selectedAgeGroup = AgeGroup.values.firstWhere(
          (e) => _ageGroupToInt(e) == ageVal,
      orElse: () => AgeGroup.twenties,
    );

    initialImageUrl = widget.initialData?['teamImg'] != null && widget.initialData!['teamImg'].toString().isNotEmpty
        ? TeamService.getFullTeamImageUrl(widget.initialData!['teamImg']) + "?v=${DateTime.now().millisecondsSinceEpoch}"
        : null;
  }

  int _ageGroupToInt(AgeGroup group) {
    switch (group) {
      case AgeGroup.teen:
        return 10;
      case AgeGroup.twenties:
        return 20;
      case AgeGroup.thirties:
        return 30;
      case AgeGroup.fortiesUp:
        return 40;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final teamName = _nameController.text;
      final teamDescription = _descriptionController.text;

      String? errorMessage;
      Map<String, dynamic> formMapForUpdate = {};

      if (isEdit) {
        final original = widget.initialData!;

        if (teamName != original['teamName']) formMapForUpdate['teamName'] = teamName;
        if (teamDescription != original['teamDescription']) formMapForUpdate['teamDescription'] = teamDescription;
        if (selectedEvent!.name.toUpperCase() != original['event']) formMapForUpdate['event'] = selectedEvent!.name.toUpperCase();
        if (selectedRegion!.name.toUpperCase() != original['region']) formMapForUpdate['region'] = selectedRegion!.name.toUpperCase();
        if (selectedCase != null && selectedCase!.name.toUpperCase() != original['teamCase']) {
          formMapForUpdate['teamCase'] = selectedCase!.name.toUpperCase();
        }
        if (_ageGroupToInt(selectedAgeGroup!) != original['memberAge']) {
          formMapForUpdate['memberAge'] = _ageGroupToInt(selectedAgeGroup!);
        }

        if (imageFile != null) {
          formMapForUpdate['teamImg'] = await MultipartFile.fromFile(
            imageFile!.path,
            filename: imageFile!.path.split('/').last,
          );
        }

        if (formMapForUpdate.isEmpty) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("변경된 내용이 없습니다.")),
          );
          return;
        }

        final formData = FormData.fromMap(formMapForUpdate);

        errorMessage = await TeamService.updateTeam(
          teamId: original['teamId'],
          formData: formData,
        );
      } else {
        errorMessage = await TeamService.createTeam(
          teamName: teamName,
          event: selectedEvent!.name.toUpperCase(),
          region: selectedRegion!.name.toUpperCase(),
          memberAge: _ageGroupToInt(selectedAgeGroup!),
          teamCase: selectedCase?.name.toUpperCase(),
          teamDescription: teamDescription,
          teamImage: imageFile,
        );
      }

      if (errorMessage != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
        return;
      }

      if (mounted) {
        Navigator.pop(context, 'update');
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => imageFile = File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(isEdit ? '팀 정보 수정' : '팀 생성'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundImage: imageFile != null
                          ? FileImage(imageFile!)
                          : (initialImageUrl != null
                          ? NetworkImage(initialImageUrl!)
                          : null) as ImageProvider?,
                      child: (imageFile == null && initialImageUrl == null)
                          ? const Icon(Icons.person, size: 48, color: Colors.white)
                          : null,
                      backgroundColor: Colors.grey[400],
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.blue, size: 20),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildLabeledInput("팀 이름", TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(border: InputBorder.none, hintText: '입력해주세요'),
                validator: (v) => v == null || v.isEmpty ? '입력해주세요' : null,
              )),
              _buildLabeledDropdown<Event>("경기 종목", selectedEvent, Event.values, eventEnumMap, (val) => setState(() => selectedEvent = val)),
              _buildLabeledDropdown<Region>("지역", selectedRegion, Region.values, regionEnumMap, (val) => setState(() => selectedRegion = val)),
              _buildLabeledDropdown<AgeGroup>("연령대", selectedAgeGroup, AgeGroup.values, ageGroupEnumMap, (val) => setState(() => selectedAgeGroup = val)),
              _buildLabeledDropdown<TeamCase>("팀 유형", selectedCase, TeamCase.values, teamCaseEnumMap, (val) => setState(() => selectedCase = val)),
              _buildLabeledInput("팀 소개", TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(border: InputBorder.none, hintText: '입력해주세요'),
              )),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(isEdit ? "수정 완료" : "팀 생성하기", style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabeledInput(String label, Widget inputField) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: inputField,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildLabeledDropdown<T>(String label, T? selected, List<T> items, Map<T, String> labelMap, ValueChanged<T?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonFormField<T>(
            value: selected,
            isExpanded: true,
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(labelMap[e]!))).toList(),
            onChanged: onChanged,
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}