import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

// Input field yang dipakai di form login, register, dll
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String  hintText;
  final IconData? prefixIcon;
  final Widget?   suffixIcon;
  final bool    obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int     maxLines;
  final bool    readOnly;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller:   controller,
      obscureText:  obscureText,
      keyboardType: keyboardType,
      validator:    validator,
      maxLines:     obscureText ? 1 : maxLines,
      readOnly:     readOnly,
      style: const TextStyle(color: AppColors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText:   hintText,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.grey, size: 20)
            : null,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
