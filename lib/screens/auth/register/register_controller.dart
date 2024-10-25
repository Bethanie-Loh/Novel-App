import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:novel_app/core/service/auth_service.dart';
import 'package:novel_app/data/model/user.dart';
import 'package:novel_app/data/repo/user_repo.dart';
import 'package:novel_app/screens/tab_container_screen.dart';
import 'package:novel_app/utils/app_date.dart';
import 'package:novel_app/utils/app_validator.dart';
import 'package:go_router/go_router.dart';

class RegisterController {
  final AuthService authService = AuthService();
  final UserRepo userRepo = UserRepo();

  Future<void> register(
    BuildContext context,
    String name,
    String gender,
    List<String> genres,
    String dob,
    String email,
    String password,
    String confirmPassword,
  ) async {
    if (!AppValidator.checkInputIfEmpty(
          [email, password, confirmPassword],
          context,
        ) ||
        !validateEmail(email, context) ||
        !validatePassword(password, context) ||
        !validateConfirmPassword(password, confirmPassword, context)) {
      return;
    }

    try {
      await authService.createUserWithEmailAndPassword(email, password);

      await userRepo.createUser(
        AppUser(
            name: name,
            email: email,
            gender: gender,
            dob: dob,
            favouriteGenres: genres,
            joinedDate: AppDate().getCurrentDateTime()),
      );

      if (!context.mounted) return;

      if (context.mounted) {
        context.pushNamed(TabContainerScreen.route);
        AppValidator.showSnackBar(context, 'Welcome, $name', false);
      }
    } catch (e) {
      if (context.mounted) {
        AppValidator.showSnackBar(context, e.toString(), true);
      }
    }
  }

  bool validateEmail(String email, BuildContext context) {
    if (!EmailValidator.validate(email)) {
      AppValidator.showSnackBar(context, 'Enter a valid email', true);
      return false;
    }
    return true;
  }

  bool validatePassword(String password, BuildContext context) {
    RegExp regex = RegExp(
      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$',
    );
    if (!regex.hasMatch(password)) {
      AppValidator.showSnackBar(
          context,
          'Password should be at least 8 characters and \ncontain at least one uppercase, one lowercase, one digit, one special character',
          true);
      return false;
    }
    return true;
  }

  bool validateConfirmPassword(
      String password, String confirmPassword, BuildContext context) {
    if (password != confirmPassword) {
      AppValidator.showSnackBar(context, 'Passwords do not match', true);
      return false;
    }
    return true;
  }
}
