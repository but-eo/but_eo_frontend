import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// TODO: 실제 프로젝트 경로에 맞게 service 및 enum import 경로 수정
// import 'package:project/service/stadium_service.dart';
// import 'package:project/data/stadium_enum.dart';

class StadiumFormPage extends StatefulWidget {
  final Map<String, dynamic>? initialData; // 수정 모드일 경우 초기 데이터
  const StadiumFormPage({super.key, this.initialData});

  @override
  State<StadiumFormPage> createState() => _StadiumFormPageState();
}

class _StadiumFormPageState extends State<StadiumFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTimeRange? _operatingHours;
  bool _alwaysOpen = false;
  String? _stadiumType;
  String? _region;
  List<File> _selectedImages = []; // 이미지 파일 목록
  final ImagePicker _picker = ImagePicker();

  late final bool isEditMode; // 수정 모드인지 확인

  @override
  void initState() {
    super.initState();
    isEditMode = widget.initialData != null;

    if (isEditMode) {
      _nameController.text = widget.initialData!['stadiumName'] ?? '';
      _priceController.text = widget.initialData!['price']?.toString() ?? '';
      _locationController.text = widget.initialData!['location'] ?? '';
      _descriptionController.text = widget.initialData!['description'] ?? '';

      // TODO: Enum 값 초기화 (실제 enum이 있다면 valueOf 등으로 변환 필요)
      _stadiumType = widget.initialData!['stadiumType'];
      _region = widget.initialData!['region'];

      // 운영 시간 초기화 (백엔드 데이터 형식에 따라 다를 수 있음)
      // 예시: 백엔드에서 start_date, end_date 문자열로 온다고 가정
      final String? startDateStr = widget.initialData!['startDate'];
      final String? endDateStr = widget.initialData!['endDate'];
      if (startDateStr != null && endDateStr != null) {
        _operatingHours = DateTimeRange(
          start: DateTime.parse(startDateStr),
          end: DateTime.parse(endDateStr),
        );
      }
      _alwaysOpen = widget.initialData!['alwaysOpen'] ?? false;

      // 이미지 URL이 있다면 File 객체로 변환하거나, NetworkImage로 표시 준비
      // 여기서는 예시로 초기 이미지 URL만 표시하고, 실제 파일은 선택 시에만 처리
      // 만약 기존 이미지를 수정할 수 있게 하려면 더 복잡한 로직이 필요합니다.
      // _selectedImages에 기존 이미지 파일이 있다면 여기에 로드해야 합니다.
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // --- 이미지 관련 로직 ---
  Future<void> _pickImage() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        List<File> newImages = [..._selectedImages];
        for (var xfile in pickedFiles) {
          newImages.add(File(xfile.path));
          if (newImages.length >= 6) {
            break;
          }
        }
        _selectedImages = newImages;
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }
  // --- 이미지 관련 로직 끝 ---

  // --- 운영 시간 관련 로직 ---
  Future<void> _selectOperatingHours(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 5),
      initialDateRange: _operatingHours,
      helpText: '운영 시작일과 종료일 선택',
      cancelText: '취소',
      confirmText: '확인',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.lightGreen,
            colorScheme: const ColorScheme.light(primary: Colors.lightGreen),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _operatingHours) {
      setState(() {
        _operatingHours = picked;
        _alwaysOpen = false; // 날짜 범위 선택 시 상시 운영 해제
      });
    }
  }
  // --- 운영 시간 관련 로직 끝 ---

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // TODO: 백엔드 API 호출 로직 구현 (StadiumService 사용)
      if (isEditMode) {
        print('경기장 수정 요청 전송!');
        // StadiumService.updateStadium(...)
        // Navigator.pop(context, 'updated'); // 수정 완료 후 이전 페이지로 결과 전달
      } else {
        print('경기장 등록 요청 전송!');
        // StadiumService.createStadium(...)
        // Navigator.pop(context, 'created'); // 생성 완료 후 이전 페이지로 결과 전달
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEditMode ? '경기장 수정 요청 전송!' : '경기장 등록 요청 전송!')),
      );
      // 실제 API 호출 후 성공 여부에 따라 Navigator.pop 호출
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? '경기장 정보 수정' : '경기장 관리자 등록'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                isEditMode ? '경기장 정보 수정' : '경기장 등록',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // 이미지 업로드 섹션
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.image_outlined, size: 40, color: Colors.grey),
                      const SizedBox(height: 8),
                      Text(
                        '사진을 등록해주세요 (${_selectedImages.length}/6)',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const Text(
                        '최대 6장까지 가능합니다.',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              if (_selectedImages.isNotEmpty) ...[
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '선택된 이미지 (${_selectedImages.length}/6)',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _selectedImages[index],
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // 경기장 이름
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '경기장 이름 *',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '경기장 이름을 입력해주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 가격
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '시간 당 가격 *',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '가격을 입력해주세요.';
                  }
                  if (double.tryParse(value) == null) {
                    return '유효한 숫자를 입력해주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 위치
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: '위치 *',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.location_on),
                    onPressed: () {
                      // TODO: 위치 선택기(지도) 기능 구현
                      print('위치 아이콘 클릭됨');
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '위치를 입력해주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 운영기간 섹션
              InkWell(
                onTap: _alwaysOpen ? null : () => _selectOperatingHours(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: '운영기간 *',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        _operatingHours == null
                            ? '선택해주세요'
                            : '${_operatingHours!.start.toLocal().toString().split(' ')[0]} ~ ${_operatingHours!.end.toLocal().toString().split(' ')[0]}',
                        style: TextStyle(
                          color: _alwaysOpen ? Colors.grey : null,
                        ),
                      ),
                      Icon(Icons.calendar_today, color: _alwaysOpen ? Colors.grey : null),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Switch(
                    value: _alwaysOpen,
                    onChanged: (bool value) {
                      setState(() {
                        _alwaysOpen = value;
                        if (value) {
                          _operatingHours = null; // 상시 운영 시 날짜 범위 초기화
                        }
                      });
                    },
                    activeColor: Colors.lightGreen,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      '종료일 없음 (상시 운영)',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              if (_alwaysOpen)
                const Padding(
                  padding: EdgeInsets.only(left: 40.0, top: 4.0),
                  child: Text(
                    '상시 운영으로 변경시, 다른 기본 운영기간은 삭제됩니다.',
                    style: TextStyle(color: Colors.redAccent, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 16),

              // 경기장 종류 드롭다운
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: '경기장 종류 *',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                value: _stadiumType,
                isExpanded: true,
                items: <String>['풋살장', '축구장', '농구장', '테니스장'] // 예시 데이터
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _stadiumType = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '경기장 종류를 선택해주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 지역 드롭다운
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: '지역 *',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                value: _region,
                isExpanded: true,
                items: const ['서울', '부산', '대구', '인천', '광주', '대전', '울산', '세종', '경기', '강원', '충북', '충남', '전북', '전남', '경북', '경남', '제주'] // 예시 데이터
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _region = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '지역을 선택해주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 경기장 설명 필드
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: '경기장 설명',
                  hintText: '경기장 정보에 추가하실 내용을 작성해주세요.',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 32),

              // 경기장 등록/수정 버튼
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  isEditMode ? '경기장 정보 수정' : '경기장 등록',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}