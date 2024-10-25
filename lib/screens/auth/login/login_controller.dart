import 'dart:async';

import 'package:flutter/material.dart';
import 'package:novel_app/core/service/auth_service.dart';
import 'package:novel_app/data/repo/user_repo.dart';
import 'package:go_router/go_router.dart';
import 'package:novel_app/utils/app_validator.dart';

class LoginController {
  final AuthService authService = AuthService();
  final UserRepo userRepo = UserRepo();

  Future<void> login(
      {required String email,
      required String password,
      required BuildContext context}) async {
    try {
      final user =
          await authService.loginUserWithEmailAndPassword(email, password);
      if (user != null) {
        userRepo.getUserStream().listen((appUser) {
          if (!context.mounted) return;

          if (appUser != null) {
            context.go('/home');
            AppValidator.showSnackBar(
                context, 'Welcome back, ${appUser.name}', false);
          } else {
            AppValidator.showSnackBar(context, 'User not found', true);
          }
        });
      } else {
        if (!context.mounted) return;
        AppValidator.showSnackBar(context, 'Login failed', true);
      }
    } catch (e) {
      debugPrint('Login Error: $e');
      AppValidator.showSnackBar(
          context, 'An error occurred during login', true);
    }
  }
}
