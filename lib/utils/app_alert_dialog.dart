import 'package:flutter/material.dart';
import 'package:novel_app/utils/app_colors.dart';
import 'package:novel_app/utils/app_text_styles.dart';

class AppAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final String textOK;
  final VoidCallback onOkPressed;
  final VoidCallback? onCancelPressed;

  const AppAlertDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onOkPressed,
    required this.textOK,
    this.onCancelPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.periwinkle,
      title: Text(
        title,
        style: AppTextStyles.bold_20,
      ),
      content: Text(
        content,
        style: AppTextStyles.italic_16.copyWith(color: AppColors.black),
      ),
      actions: [
        if (onCancelPressed != null)
          TextButton(
            onPressed: onCancelPressed ?? () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTextStyles.italic_bold_16
                  .copyWith(color: AppColors.mulberry),
            ),
          ),
        TextButton(
          onPressed: onOkPressed,
          child: Text(
            textOK,
            style: AppTextStyles.italic_bold_16
                .copyWith(color: AppColors.mulberry),
          ),
        ),
      ],
    );
  }
}
