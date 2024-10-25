import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:novel_app/utils/app_colors.dart';
import 'package:novel_app/utils/app_text_styles.dart';

class AppDatePicker extends StatefulWidget {
  final String hintText;
  final void Function(String)? onDateChanged;
  final DateTime? dob;

  const AppDatePicker(
      {super.key, required this.hintText, this.onDateChanged, this.dob});

  @override
  AppDatePickerState createState() => AppDatePickerState();
}

class AppDatePickerState extends State<AppDatePicker> {
  DateTime? _selectedDate;

  @override
  void initState() {
    _init();
    super.initState();
  }

  void _init() {
    if (widget.dob != null) {
      _selectedDate = widget.dob;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.dob ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColors.periwinkle,
            colorScheme: const ColorScheme.light(
              primary: AppColors.periwinkle,
              onPrimary: AppColors.white,
              onSurface: AppColors.mulberry,
            ),
            dialogBackgroundColor: AppColors.white,
            textTheme: const TextTheme(
              headlineLarge: AppTextStyles.bold_26,
              titleLarge: AppTextStyles.italic_16,
              labelLarge: AppTextStyles.inputText,
              bodyLarge: AppTextStyles.inputText,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                textStyle: AppTextStyles.italic_16,
                foregroundColor: AppColors.mulberry,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      debugPrint("picked date: $picked");
      debugPrint("_selectedDate: $_selectedDate");
      setState(() => _selectedDate = picked);
      widget.onDateChanged?.call(DateFormat('dd/MM/yyyy').format(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.gray),
          color: AppColors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedDate == null
                  ? widget.hintText
                  : DateFormat('dd/MM/yyyy').format(_selectedDate!),
              style: _selectedDate == null
                  ? AppTextStyles.hintInputText
                  : AppTextStyles.inputText,
            ),
            const Icon(Icons.calendar_today, color: AppColors.gray),
          ],
        ),
      ),
    );
  }
}
