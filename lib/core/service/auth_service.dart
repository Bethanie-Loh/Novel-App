import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user != null;
    } catch (e) {
      debugPrint("AuthService => Error creating user: $e");
      return false;
    }
  }

  Future<User?> loginUserWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      debugPrint("Error logging in user: $e");
      return null;
    }
  }

  String? getUid() => _auth.currentUser?.uid;

  Future<void> logOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint("AuthService => Error logging out: $e");
    }
  }
}
