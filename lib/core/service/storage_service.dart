import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StorageState {
  final List<String> imageUrls;
  final bool isUploading;

  StorageState({
    this.imageUrls = const [],
    this.isUploading = false,
  });

  StorageState copyWith({
    List<String>? imageUrls,
    bool? isUploading,
  }) {
    return StorageState(
      imageUrls: imageUrls ?? this.imageUrls,
      isUploading: isUploading ?? this.isUploading,
    );
  }
}

class StorageService extends StateNotifier<StorageState> {
  final firebaseStorage = FirebaseStorage.instance;

  StorageService() : super(StorageState());

  Future<String> getDownloadURL(String filename) async {
    return firebaseStorage
        .ref("uploaded_images")
        .child(filename)
        .getDownloadURL();
  }

  Future<String> uploadImage() async {
    state = state.copyWith(isUploading: true);
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      state = state.copyWith(isUploading: false);
      return 'null';
    }

    File file = File(image.path);

    if (!await file.exists()) {
      debugPrint("File does not exist at path: ${file.path}");
      state = state.copyWith(isUploading: false);
      return 'null';
    }

    try {
      String filePath =
          'uploaded_images/${DateTime.now().millisecondsSinceEpoch}.png';
      await firebaseStorage.ref(filePath).putFile(file);

      String downloadUrl = await firebaseStorage.ref(filePath).getDownloadURL();

      state = state.copyWith(imageUrls: [...state.imageUrls, downloadUrl]);

      return downloadUrl;
    } catch (e) {
      debugPrint("Error uploading images: $e");
      return 'null';
    } finally {
      state = state.copyWith(isUploading: false);
    }
  }

 
}

final storageProvider = StateNotifierProvider<StorageService, StorageState>(
  (ref) => StorageService(),
);














// class StorageService with ChangeNotifier {
//   final firebaseStorage = FirebaseStorage.instance;
//   List<String> _imageUrls = [];
//   bool _isLoading = false;
//   bool _isUploading = false;

//   List<String> get imageUrl => _imageUrls;
//   bool get isLoading => _isLoading;
//   bool get isUploading => _isUploading;

//   Future<void> uploadImage() async {
//     _isUploading = true;
//     notifyListeners();
//     final ImagePicker picker = ImagePicker();
//     final XFile? image = await picker.pickImage(source: ImageSource.gallery);

//     if (image == null) return;
//     File file = File(image.path);

//     try {
//       String filePath = 'uploaded_images/${DateTime.now()}.png';
//       await firebaseStorage.ref(filePath).putFile(file);
//       String downloadUrl = await firebaseStorage.ref(filePath).getDownloadURL();

//       _imageUrls.add(downloadUrl);
//       notifyListeners();
//     } catch (e) {
//       debugPrint("Error uploading images..$e");
//     } finally {
//       _isUploading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> fetchImage() async {
//     _isLoading = true;

//     final ListResult result =
//         await firebaseStorage.ref('uploaded/images/').listAll();

//     final urls =
//         await Future.wait(result.items.map((ref) => ref.getDownloadURL()));

//     _imageUrls = urls;
//     _isLoading = false;
//     notifyListeners();
//   }
// }
