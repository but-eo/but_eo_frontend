import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/image_picker/image_picker.dart';

class ProfileImagePicker extends StatefulWidget {
  const ProfileImagePicker({super.key});

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.gallery); // 또는 camera

    setState(() {
      _imageFile = pickedFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: 50,
            backgroundImage: _imageFile != null
                ? FileImage(File(_imageFile!.path))
                : const AssetImage("assets/profile.jpg") as ImageProvider,
            child: const Align(
              alignment: Alignment.bottomRight,
              child: Icon(Icons.camera_alt, size: 20),
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (_imageFile != null)
          Text('선택된 파일: ${_imageFile!.name}'),
      ],
    );
  }
}
