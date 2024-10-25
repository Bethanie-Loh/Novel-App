import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:novel_app/constants/app_strings.dart';
import 'package:novel_app/data/model/user.dart';

class UserRepo {
  CollectionReference getUserCollRef() {
    return FirebaseFirestore.instance.collection('users');
  }

  String getUid() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User doesn't exist");
    }
    return user.uid;
  }

  Future<void> createUser(AppUser user) async {
    try {
      await getUserCollRef().doc(getUid()).set(user.toMap());
    } catch (e) {
      debugPrint("UserRepo => Error creating user: $e");
      rethrow;
    }
  }

  // Future<AppUser?> getUser() async {
  //   final DocumentSnapshot doc = await getUserCollRef().doc(getUid()).get();
  //   if (doc.exists) {
  //     return AppUser.fromMap(doc.data() as Map<String, dynamic>);
  //   }
  //   return null;
  // }

  Stream<AppUser?> getUserStream() {
    return getUserCollRef().doc(getUid()).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return AppUser.fromMap(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  Future<AppUser?> getUserById(String id) async {
    final DocumentSnapshot doc = await getUserCollRef().doc(id).get();
    if (doc.exists) {
      return AppUser.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<String> updateUser(AppUser user) async {
    try {
      await getUserCollRef().doc(getUid()).set(user.toMap());
      return AppStrings.success;
    } catch (e) {
      debugPrint("Error in updating user. Error: $e");
      return AppStrings.failure;
    }
  }
}
