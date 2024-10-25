import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StorageState {
  final bool isUploading;
  final bool isLoading;
  StorageState({
    this.isUploading = false,
    this.isLoading = true,
  });

  StorageState copyWith({
    bool? isUploading,
    bool? isLoading,
  }) {
    return StorageState(
      isUploading: isUploading ?? this.isUploading,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class StorageService extends StateNotifier<StorageState> {
  final firebaseStorage = FirebaseStorage.instance;

  StorageService() : super(StorageState());

  Future<String> uploadImage() async {
    state = state.copyWith(isUploading: true);
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      state = state.copyWith(isUploading: false);
      return 'null';
    }

    File file = File(image.path);

    try {
      String filePath =
          'uploaded_images/${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      await firebaseStorage.ref(filePath).putFile(file);
      String downloadUrl = await firebaseStorage.ref(filePath).getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint("Error uploading images: $e");
      return "null";
    } finally {
      state = state.copyWith(isUploading: false);
    }
  }

  Future<void> deleteImageFromStorage(String imageUrl) async {
    try {
      final Reference firebaseStorageRef =
          FirebaseStorage.instance.refFromURL(imageUrl);
      await firebaseStorageRef.delete();
      debugPrint("Image at $imageUrl successfully deleted.");
    } catch (e) {
      debugPrint("Error in deleting image. Error: $e");
    }
  }
}

final storageProvider = StateNotifierProvider<StorageService, StorageState>(
  (ref) => StorageService(),
);
