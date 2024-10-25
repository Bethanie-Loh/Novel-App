import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:novel_app/constants/app_strings.dart';
import 'package:novel_app/data/model/book.dart';

class BookRepo {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('books');

  Stream<List<Book>> getBooks() async* {
    try {
      yield* _collection.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>?;

          if (data != null) {
            return Book.fromMap(data..['id'] = doc.id);
          } else {
            throw Exception("Document data is null");
          }
        }).toList();
      });
    } catch (e) {
      debugPrint('Error in getting books from repository: $e');
      yield [];
    }
  }

  Future<String?> addBook(Book book) async {
    debugPrint("book at addBook repo: $book");
    try {
      final docRef = await _collection.add(book.toMap());
      final updatedBook = book.copyWith(id: docRef.id);
      await docRef.set(updatedBook.toMap());
      return updatedBook.id;
    } catch (e) {
      debugPrint('Failed to add book: $e');
      return null;
    }
  }

  Future<Book?> getBookById(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          return Book.fromMap(data as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Failed to get book: $e');
      return null;
    }
  }

  Future<String> updateBook(Book book) async {
    debugPrint("Book at updateBook book_repo: $book");
    debugPrint("Book ID at updateBook book_repo: ${book.id}");
    try {
      if (book.id != null) {
        await _collection.doc(book.id).set(book.toMap());
        return AppStrings.success;
      } else {
        debugPrint("No book id. Book id: ${book.id}");
        return AppStrings.failure;
      }
    } catch (e) {
      debugPrint("Error in updating book. Error: $e");
      return AppStrings.failure;
    }
  }

  Future<String> deleteBook(String id) async {
    debugPrint("Attempting to delete book with ID: $id");
    try {
      await _collection.doc(id).delete();
      debugPrint("Book with ID: $id successfully deleted.");
      return AppStrings.success;
    } catch (e) {
      debugPrint("Error in deleting book. Error: $e");
      return AppStrings.failure;
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
