import 'package:flutter/material.dart';
import 'package:novel_app/screens/auth/register/register_controller.dart';
import 'package:novel_app/utils/app_button.dart';
import 'package:novel_app/utils/app_colors.dart';
import 'package:novel_app/utils/app_loading.dart';
import 'package:novel_app/utils/app_text_field.dart';
import 'package:novel_app/utils/app_text_styles.dart';

class RegisterScreen2 extends StatefulWidget {
  static const route = "Register2";
  final String name;
  final String gender;
  final List<String> genres;
  final String dob;

  RegisterScreen2({
    super.key,
    required this.name,
    required this.gender,
    required this.genres,
    required this.dob,
  }) {
    debugPrint('Name: $name');
    debugPrint('Gender: $gender');
    debugPrint('Genres: $genres');
    debugPrint('Date of Birth: $dob');
  }

  @override
  State<RegisterScreen2> createState() => _RegisterScreen2State();
}

class _RegisterScreen2State extends State<RegisterScreen2> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confirmPwController = TextEditingController();
  final RegisterController _registerController = RegisterController();
  bool _isLoading = false;

  void toggleLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.galaxy,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 70),
              child: const Column(
                children: [
                  Text(
                    'DREAM',
                    style: AppTextStyles.appName,
                  ),
                  Text(
                    'Dare to dream, dare to write',
                    style: AppTextStyles.italic_bold_16,
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: const Text(
                'Finally...',
                style: AppTextStyles.italic_bold_16,
              ),
            ),
            AppTextfield(
              hintText: 'Email',
              obscureText: false,
              controller: _emailController,
            ),
            AppTextfield(
              hintText: 'Password',
              obscureText: true,
              controller: _pwController,
            ),
            AppTextfield(
              hintText: 'Confirm Password',
              obscureText: true,
              controller: _confirmPwController,
            ),
            const SizedBox(height: 30),
            _isLoading
                ? const AppLoading()
                : AppButton(
                    label: 'REGISTER',
                    onPressed: () {
                      _registerController.register(
                        context,
                        widget.name,
                        widget.gender,
                        widget.genres,
                        widget.dob,
                        _emailController.text,
                        _pwController.text,
                        _confirmPwController.text,
                      );
                    },
                  ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Back",
                style: AppTextStyles.italic_bold_16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
