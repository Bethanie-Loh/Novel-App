import 'package:flutter/material.dart';
import 'package:novel_app/utils/app_colors.dart';
import 'package:novel_app/utils/app_text_styles.dart';

class AppTextfield extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final bool? longText;
  final bool geminiAI;
  final ValueChanged<String>? onChanged;
  const AppTextfield(
      {super.key,
      required this.hintText,
      required this.obscureText,
      required this.controller,
      this.longText,
      this.geminiAI = false,
      this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        onChanged: (value) => onChanged,
        minLines: (longText ?? false) ? 3 : 1,
        maxLines: (obscureText
            ? 1
            : (longText ?? false)
                ? null
                : 2),
        controller: controller,
        obscureText: obscureText,
        cursorColor: AppColors.periwinkle,
        style: AppTextStyles.inputText,
        textInputAction: geminiAI ? TextInputAction.send : TextInputAction.done,
        onSubmitted: geminiAI
            ? (value) {
                debugPrint("Query Submitted: $value");
                Navigator.pop(context);
              }
            : null,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.hintInputText,
          filled: true,
          fillColor: AppColors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: longText == true
                ? BorderRadius.circular(20)
                : BorderRadius.circular(30),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: longText == true
                ? BorderRadius.circular(20)
                : BorderRadius.circular(30),
            borderSide: const BorderSide(color: AppColors.periwinkle, width: 3),
          ),
        ),
      ),
    );
  }
}
