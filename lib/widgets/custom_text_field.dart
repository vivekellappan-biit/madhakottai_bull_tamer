import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final int maxLines;
  final String label;
  final String? Function(String?)? validator;
  final int? maxLength;
  final bool isPhoneNumber;
  final bool isAadhaarNumber;
  final void Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    required this.label,
    this.validator,
    this.maxLength,
    this.isPhoneNumber = false,
    this.isAadhaarNumber = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        inputFormatters: [
          UpperCaseTextFormatter(),
          if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
          if (isPhoneNumber) PhoneNumberFormatter(),
          if (isAadhaarNumber) AadhaarNumberFormatter(),
        ],
        textCapitalization: TextCapitalization.characters,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
        ),
        validator: validator ??
            (value) {
              if (isPhoneNumber) {
                return _validatePhoneNumber(value);
              } else if (isAadhaarNumber) {
                return _validateAadhaarNumber(value);
              }
              return null;
            },
        onChanged: onChanged,
      ),
    );
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    } else if (value.replaceAll(' ', '').length != 10) {
      return 'Phone number must be 10 digits excluding spaces';
    }
    return null;
  }

  String? _validateAadhaarNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Aadhaar number is required';
    } else if (value.replaceAll(' ', '').length != 12) {
      return 'Aadhaar number must be 12 digits excluding spaces';
    }
    return null;
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
    );
  }
}

class AadhaarNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final newText = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(newText[i]);
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final newText = newValue.text.replaceAll(' ', '').replaceAll('+91', '');
    final buffer = StringBuffer('+91 ');
    for (int i = 0; i < newText.length; i++) {
      if (i == 5) {
        buffer.write(' ');
      }
      buffer.write(newText[i]);
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
