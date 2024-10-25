import 'package:flutter/material.dart';
import 'package:novel_app/screens/auth/login/login_controller.dart';
import 'package:novel_app/utils/app_button.dart';
import 'package:novel_app/utils/app_text_field.dart';
import 'package:novel_app/utils/app_colors.dart';
import 'package:novel_app/utils/app_text_styles.dart';
import 'package:novel_app/utils/app_loading.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const route = "Login";

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LoginController _authController = LoginController();

  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    await _authController.login(
      email: _emailController.text,
      password: _passwordController.text,
      context: context,
    );

    setState(() {
      _isLoading = false;
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
              margin: const EdgeInsets.symmetric(vertical: 100),
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
            AppTextfield(
              hintText: 'Email',
              obscureText: false,
              controller: _emailController,
            ),
            AppTextfield(
              hintText: 'Password',
              obscureText: true,
              controller: _passwordController,
            ),
            const SizedBox(height: 30),
            _isLoading
                ? const AppLoading()
                : AppButton(
                    label: 'LOGIN',
                    onPressed: _login,
                  ),
            const SizedBox(height: 20),
            const Text(
              "Don't have an account?",
              style: AppTextStyles.italic_14,
            ),
            TextButton(
              onPressed: () {
                context.push('/register');
              },
              child: const Text(
                "Register",
                style: AppTextStyles.italic_bold_16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
