import 'package:flutter/material.dart';
import 'package:novel_app/utils/app_colors.dart';
import 'package:novel_app/utils/app_text_styles.dart';

class AppValidator {
  static void showSnackBar(BuildContext context, String message, bool error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
        style: error
            ? AppTextStyles.italic_bold_14
            : AppTextStyles.italic_bold_14.copyWith(
                color: AppColors.black,
              ),
      ),
      backgroundColor: error ? AppColors.mulberry : AppColors.periwinkle,
    ));
  }

  static bool checkInputIfEmpty(
    List<String> fields,
    BuildContext context,
  ) {
    if (fields.any((field) => field.isEmpty)) {
      showSnackBar(context, 'Please fill in all inputs first', true);
      return false;
    }
    return true;
  }
}
