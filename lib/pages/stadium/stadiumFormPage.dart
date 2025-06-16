import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:project/service/stadiumService.dart';
import 'package:project/data/teamEnum.dart';
import 'package:project/appStyle/app_colors.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';



class StadiumFormPage extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const StadiumFormPage({super.key, this.initialData});

  @override
  State<StadiumFormPage> createState() => _StadiumFormPageState();
}

class _StadiumFormPageState extends State<StadiumFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _telController = TextEditingController();

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  DateTimeRange? _operatingHours;
  bool _alwaysOpen = false;

  Region? _selectedRegion;
  Set<Event> _selectedEvents = {};

  List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  late final bool isEditMode;

  @override
  void initState() {
    super.initState();
    isEditMode = widget.initialData != null;

    if (isEditMode) {
      _nameController.text = widget.initialData!['stadiumName'] ?? '';
      _priceController.text = widget.initialData!['stadiumCost']?.toString() ?? '';
      _telController.text = widget.initialData!['stadiumTel'] ?? '';
      _addressController.text = widget.initialData!['stadiumAddress'] ?? '';
      _descriptionController.text = widget.initialData!['stadiumDetail'] ?? '';

      final String? initialRegionStr = widget.initialData!['stadiumRegion'];
      if (initialRegionStr != null) {
        try {
          _selectedRegion = regionEnumMap.entries.firstWhere(
                (entry) => entry.value == initialRegionStr,
          ).key;
        } catch (e) {
          _selectedRegion = Region.seoul;
          debugPrint('Warning: Initial region "$initialRegionStr" not found in regionEnumMap. Defaulting to Seoul.');
        }
      }

      final String? initialEventsStr = widget.initialData!['stadiumEvents'];
      if (initialEventsStr != null && initialEventsStr.isNotEmpty) {
        _selectedEvents = initialEventsStr.split(',').map((e) {
          final eventName = e.trim();
          try {
            return eventEnumMap.entries.firstWhere(
                  (entry) => entry.value == eventName,
            ).key;
          } catch (error) {
            debugPrint('Warning: Initial event "$eventName" not found in eventEnumMap.');
            return null;
          }
        }).whereType<Event>().toSet();
      }

      _alwaysOpen = widget.initialData!['availableDays'] == '상시운영';

      final String? availableHoursStr = widget.initialData!['availableHours'];
      if (availableHoursStr != null && availableHoursStr.contains('~')) {
        try {
          final parts = availableHoursStr.split('~');
          final startTime = parts[0].trim();
          final endTime = parts[1].trim();

          _startTimeController.text = startTime;
          _endTimeController.text = endTime;

          final now = DateTime.now();
          final startHour = int.parse(startTime.split(':')[0]);
          final startMinute = int.parse(startTime.split(':')[1]);
          final endHour = int.parse(endTime.split(':')[0]);
          final endMinute = int.parse(endTime.split(':')[1]);
          _operatingHours = DateTimeRange(
            start: DateTime(now.year, now.month, now.day, startHour, startMinute),
            end: DateTime(now.year, now.month, now.day, endHour, endMinute),
          );
        } catch (e) {
          debugPrint('Error parsing operating hours: $e');
          _startTimeController.text = '00:00';
          _endTimeController.text = '24:00';
        }
      } else {
        _startTimeController.text = '00:00';
        _endTimeController.text = '24:00';
      }
    } else {
      _startTimeController.text = '00:00';
      _endTimeController.text = '24:00';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _telController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(pickedFiles.map((x) => File(x.path)));
        if (_selectedImages.length > 10) {
          _selectedImages = _selectedImages.sublist(0, 10);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('사진은 최대 10장까지 추가할 수 있습니다.'),
              backgroundColor: AppColors.warningOrange,
            ),
          );
        }
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<FormData> _buildFormData() async {
    final formMap = {
      'stadiumName': _nameController.text,
      'stadiumRegion': regionEnumMap[_selectedRegion] ?? '',
      'stadiumMany': 22, // 이 값은 현재 하드코딩되어 있습니다. 동적인 값이라면 UI에서 입력받아야 합니다.
      'availableDays': _alwaysOpen ? '상시운영' : '매일',
      'availableHours': _alwaysOpen
          ? '00:00~24:00'
          : '${_startTimeController.text}~${_endTimeController.text}',
      'stadiumTel': _telController.text,
      'stadiumCost': int.tryParse(_priceController.text) ?? 0,
      'stadiumEvents': _selectedEvents.map((e) => eventEnumMap[e]!).join(','), // 이 값은 Flutter에서 잘 보내고 있습니다.
      'stadiumAddress': _addressController.text, // 이 값은 Flutter에서 잘 보내고 있습니다.
      'stadiumDetail': _descriptionController.text, // 이 값은 Flutter에서 잘 보내고 있습니다.
    };

    final imageMultipartFiles = await Future.wait(
      _selectedImages.map((file) async {
        final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
        final parts = mimeType.split('/');
        return await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
          contentType: MediaType(parts[0], parts[1]),
        );
      }),
    );


    return FormData.fromMap({
      ...formMap,
      'imageFiles': imageMultipartFiles, // 이미 이전에 'imageFiles'에서 'images'로 수정했습니다.
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedEvents.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('적어도 하나의 종목을 선택해주세요.'),
            backgroundColor: AppColors.errorRed,
          ),
        );
        return;
      }
      if (!_alwaysOpen) {
        final startTime = _startTimeController.text;
        final endTime = _endTimeController.text;

        if (!RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$').hasMatch(startTime) ||
            !RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$').hasMatch(endTime)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('운영 시간을 HH:MM 형식으로 정확히 입력해주세요.'),
              backgroundColor: AppColors.errorRed,
            ),
          );
          return;
        }
      }

      final formData = await _buildFormData();
      String? error;

      if (isEditMode) {
        final stadiumId = widget.initialData!['stadiumId'];
        error = await StadiumService.updateStadium(
          stadiumId: stadiumId,
          formData: formData,
        );
      } else {
        error = await StadiumService.createStadium(formData: formData);
      }

      if (context.mounted) {
        final message = error ?? '✅ 완료되었습니다';
        final isSuccess = error == null;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: isSuccess ? AppColors.successGreen : AppColors.errorRed,
          ),
        );

        if (isSuccess) {
          Navigator.pop(context, isEditMode ? 'updated' : 'created');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? '경기장 수정' : '경기장 등록'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.baseWhiteColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- 경기장 사진 섹션 (UI 개선) ---
              Text('경기장 사진 (최대 10장)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _selectedImages.length) {
                      if (_selectedImages.length >= 10) return const SizedBox.shrink();
                      return GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(right: 8.0),
                          decoration: BoxDecoration(
                            color: AppColors.baseGrey10Color,
                            border: Border.all(color: AppColors.textSubtle, style: BorderStyle.solid, width: 1.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, size: 30, color: AppColors.textSubtle),
                              Text('사진 추가', style: TextStyle(color: AppColors.textSubtle, fontSize: 12)),
                            ],
                          ),
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.file(
                              _selectedImages[index],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: AppColors.textSubtle.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.close, size: 16, color: AppColors.baseWhiteColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // --- Form Fields ---
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '경기장 이름 *',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.stadium, color: AppColors.primaryBlue),
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                ),
                validator: (value) => value == null || value.isEmpty ? '경기장 이름을 입력해주세요.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: '시간당 가격 *',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.money, color: AppColors.primaryBlue),
                  suffixText: '원',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                ),
                validator: (value) => value == null || double.tryParse(value) == null ? '올바른 가격을 입력해주세요.' : null,
              ),
              const SizedBox(height: 16),

              // --- 지역 드롭다운 ---
              DropdownButtonFormField<Region>(
                value: _selectedRegion,
                decoration: InputDecoration(
                  labelText: '지역 *',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.location_on, color: AppColors.primaryBlue),
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                ),
                items: regionEnumMap.entries.map((entry) {
                  return DropdownMenuItem<Region>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (Region? newValue) {
                  setState(() {
                    _selectedRegion = newValue;
                  });
                },
                validator: (value) => value == null ? '지역을 선택해주세요.' : null,
              ),
              const SizedBox(height: 16),

              // --- 주소 입력 필드 추가 ---
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: '경기장 주소 *',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.primaryBlue),
                  hintText: '도로명 주소 또는 지번 주소',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  hintStyle: TextStyle(color: AppColors.textSubtle),
                ),
                validator: (value) => value == null || value.isEmpty ? '경기장 주소를 입력해주세요.' : null,
              ),
              const SizedBox(height: 16),

              // --- 종목 멀티 선택 ---
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('가능 종목 *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: AppColors.textPrimary)),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: eventEnumMap.entries.map((entry) {
                      final isSelected = _selectedEvents.contains(entry.key);
                      return ChoiceChip(
                        label: Text(entry.value),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedEvents.add(entry.key);
                            } else {
                              _selectedEvents.remove(entry.key);
                            }
                          });
                        },
                        selectedColor: AppColors.primaryBlue.withOpacity(0.2),
                        backgroundColor: AppColors.baseGrey10Color,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.darkBlue : AppColors.textPrimary,
                        ),
                        side: isSelected
                            ? BorderSide(color: AppColors.primaryBlue, width: 1.0)
                            : BorderSide.none,
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _telController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: '전화번호',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.phone, color: AppColors.primaryBlue),
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 16),

              // --- 운영 시간 직접 입력 필드 ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('상시 운영', style: TextStyle(color: AppColors.textPrimary)),
                        Switch(
                          value: _alwaysOpen,
                          onChanged: (val) => setState(() {
                            _alwaysOpen = val;
                            if (val) {
                              _startTimeController.text = '00:00';
                              _endTimeController.text = '24:00';
                            }
                          }),
                          activeColor: AppColors.primaryBlue,
                        ),
                      ],
                    ),
                  ),
                  if (!_alwaysOpen)
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _startTimeController,
                              keyboardType: TextInputType.datetime,
                              decoration: InputDecoration(
                                labelText: '시작',
                                border: const OutlineInputBorder(),
                                hintText: 'HH:MM',
                                labelStyle: TextStyle(color: AppColors.textSecondary),
                                hintStyle: TextStyle(color: AppColors.textSubtle),
                              ),
                              validator: (value) {
                                if (value == null || !RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$').hasMatch(value)) {
                                  return 'HH:MM 형식';
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('~', style: TextStyle(color: AppColors.textPrimary)),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: _endTimeController,
                              keyboardType: TextInputType.datetime,
                              decoration: InputDecoration(
                                labelText: '종료',
                                border: const OutlineInputBorder(),
                                hintText: 'HH:MM',
                                labelStyle: TextStyle(color: AppColors.textSecondary),
                                hintStyle: TextStyle(color: AppColors.textSubtle),
                              ),
                              validator: (value) {
                                if (value == null || !RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$').hasMatch(value)) {
                                  return 'HH:MM 형식';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // --- 메모 (상세 정보) 입력 필드 추가 ---
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: '추가 상세 정보',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.notes, color: AppColors.primaryBlue),
                  hintText: '경기장 이용 규칙, 특이사항 등을 입력하세요 (선택 사항)',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  hintStyle: TextStyle(color: AppColors.textSubtle),
                ),
                maxLines: 4,
                minLines: 1,
              ),
              const SizedBox(height: 24),

              // --- 제출 버튼 ---
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: AppColors.baseWhiteColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  isEditMode ? '경기장 수정' : '경기장 등록',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 이미지 선택을 위한 점선 테두리 컨테이너 헬퍼 위젯 (이제 직접 사용되지 않음)
class DottedBorderContainer extends StatelessWidget {
  final Widget child;
  const DottedBorderContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.baseGrey10Color,
        border: Border.all(color: AppColors.textSubtle, style: BorderStyle.solid, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(child: child),
    );
  }
}