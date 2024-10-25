import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:novel_app/screens/auth/login/login_screen.dart';
import 'package:novel_app/screens/tab_container_screen.dart';
import 'package:novel_app/utils/app_loading.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: AppLoading());
        }
        if (snapshot.hasData) {
          return const TabContainerScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
