import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:project/service/stadiumService.dart';

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
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _telController = TextEditingController();

  DateTimeRange? _operatingHours;
  bool _alwaysOpen = false;
  String? _availableDays;
  String? _region;
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
      _locationController.text = widget.initialData!['stadiumRegion'] ?? '';
      _telController.text = widget.initialData!['stadiumTel'] ?? '';
      _region = widget.initialData!['stadiumRegion'];
      _alwaysOpen = widget.initialData!['availableDays'] == '상시운영';

      final String? startDateStr = widget.initialData!['startDate'];
      final String? endDateStr = widget.initialData!['endDate'];
      if (startDateStr != null && endDateStr != null) {
        _operatingHours = DateTimeRange(
          start: DateTime.parse(startDateStr),
          end: DateTime.parse(endDateStr),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _telController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(pickedFiles.map((x) => File(x.path)));
        if (_selectedImages.length > 10) {
          _selectedImages = _selectedImages.sublist(0, 10);
        }
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _selectOperatingHours(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 5),
      initialDateRange: _operatingHours,
    );
    if (picked != null) {
      setState(() {
        _operatingHours = picked;
        _alwaysOpen = false;
      });
    }
  }

  Future<FormData> _buildFormData() async {
    final formMap = {
      'stadiumName': _nameController.text,
      'stadiumRegion': _region ?? '',
      'stadiumMany': 22,
      'availableDays': _alwaysOpen ? '상시운영' : (_availableDays ?? '매일'),
      'availableHours': _operatingHours != null
          ? '${_operatingHours!.start.hour}:00~${_operatingHours!.end.hour}:00'
          : '00:00~24:00',
      'stadiumTel': _telController.text,
      'stadiumCost': int.tryParse(_priceController.text) ?? 0,
    };

    final imageFiles = await Future.wait(
      _selectedImages.map((file) async {
        return await MultipartFile.fromFile(file.path, filename: file.path.split('/').last);
      }),
    );

    return FormData.fromMap({
      ...formMap,
      if (imageFiles.isNotEmpty) 'imageFiles': imageFiles,
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
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
            backgroundColor: isSuccess ? Colors.green : Colors.red,
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
      appBar: AppBar(title: Text(isEditMode ? '경기장 수정' : '경기장 등록')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: _pickImage,
                  icon: const CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.add_a_photo, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: List.generate(
                  _selectedImages.length,
                      (index) => Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Image.file(
                        _selectedImages[index],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      GestureDetector(
                        onTap: () => _removeImage(index),
                        child: const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.black54,
                          child: Icon(Icons.close, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: '경기장 이름 *'),
                validator: (value) => value == null || value.isEmpty ? '필수 입력' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '시간당 가격 *'),
                validator: (value) => value == null || double.tryParse(value) == null ? '숫자 입력' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: '지역 *'),
                validator: (value) => value == null || value.isEmpty ? '지역 입력' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telController,
                decoration: const InputDecoration(labelText: '전화번호'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('상시 운영'),
                  Switch(
                    value: _alwaysOpen,
                    onChanged: (val) => setState(() => _alwaysOpen = val),
                  ),
                  if (!_alwaysOpen)
                    TextButton(
                      onPressed: () => _selectOperatingHours(context),
                      child: Text(_operatingHours != null
                          ? '${_operatingHours!.start.toLocal()} ~ ${_operatingHours!.end.toLocal()}'
                          : '운영 시간 선택'),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(isEditMode ? '수정' : '등록'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
