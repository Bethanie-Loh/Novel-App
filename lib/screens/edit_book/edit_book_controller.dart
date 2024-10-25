import 'package:flutter/material.dart';
import 'package:novel_app/constants/app_strings.dart';
import 'package:novel_app/data/model/book.dart';
import 'package:novel_app/data/repo/book_repo.dart';
import 'package:novel_app/utils/app_date.dart';

class EditBookController {
  final _bookRepo = BookRepo();

  Future<void> updateCover(Book book, String cover) async {
    final updatedBook = book.copyWith(cover: cover);
    _bookRepo.updateBook(updatedBook);
  }

  Future<String> updateBook(Book book, String bookTitle, String cover,
      List<String> genres, String summary, BuildContext context) async {
    debugPrint("UPDATING BOOK IN EDIT BOOK CONTROLLER");

    try {
      final updatedBook = book.copyWith(
        title: bookTitle,
        cover: cover,
        genres: genres,
        summary: summary,
        isPublished: false,
        datePublished: AppDate().getCurrentDateTime(),
      );

      debugPrint("updatedBook: $updatedBook");

      final result = await _bookRepo.updateBook(updatedBook);

      if (result == AppStrings.success) {
        return AppStrings.success;
      } else {
        return AppStrings.failure;
      }
    } catch (e) {
      debugPrint("Error in saving book. Error: $e");
      return AppStrings.failure;
    }
  }
}
