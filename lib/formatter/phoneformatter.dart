import 'package:flutter/services.dart';

class Phoneformatter extends TextInputFormatter{

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String digits = newValue.text.replaceAll(RegExp(r'\D'), "");

     if (digits.length > 11) {
      digits = digits.substring(0, 11); // 최대 11자리 제한
    }

    String formatted = digits;
    if (digits.length >= 11) {
      formatted = '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7, 11)}';
    } else if (digits.length >= 7) {
      formatted = '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7)}';
    } else if (digits.length >= 4) {
      formatted = '${digits.substring(0, 3)}-${digits.substring(3)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}