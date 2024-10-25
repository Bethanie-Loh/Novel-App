import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novel_app/core/service/auth_service.dart';
import 'package:novel_app/utils/app_alert_dialog.dart';
import 'package:novel_app/utils/app_validator.dart';

void showLogoutDialogAndPerformLogout(BuildContext context) async {
  final AuthService authService = AuthService();

  bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AppAlertDialog(
      title: 'Confirm logging out?',
      content: '',
      textOK: 'Yes',
      onOkPressed: () => Navigator.of(context).pop(true),
      onCancelPressed: () => Navigator.of(context).pop(false),
    ),
  );

  if (confirmed == true) {
    try {
      await authService.logOut();
      SystemNavigator.pop();
    } catch (e) {
      debugPrint("Error during logout: $e");
      if (!context.mounted) return;
      AppValidator.showSnackBar(context, "Error during logout: $e", true);
    }
  }
}
