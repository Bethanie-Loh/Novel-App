import 'package:flutter/widgets.dart';
import 'package:novel_app/constants/app_strings.dart';
import 'package:novel_app/data/model/book.dart';
import 'package:novel_app/data/model/chapter.dart';
import 'package:novel_app/data/repo/book_repo.dart';
import 'package:novel_app/data/repo/user_repo.dart';
import 'package:novel_app/utils/app_date.dart';
import 'package:novel_app/utils/app_validator.dart';

class WriteController {
  final _bookRepo = BookRepo();

  final _userRepo = UserRepo();
  String? _userName;

  WriteController() {
    fetchUserName();
  }

  void fetchUserName() {
    _userRepo.getUserStream().listen((user) {
      if (user != null) {
        _userName = user.name;
      } else {
        _userName = 'User not found';
      }
    });
  }

  Future<String> addNewBook(BuildContext context, String title,
      List<Chapter> chapters, int totalPages) async {
    debugPrint('title: $title');
    debugPrint('userName: $_userName');
    debugPrint('chapters: $chapters');
    debugPrint('totalPages: $totalPages');
    debugPrint('userName: $_userName');

    try {
      String? result = await _bookRepo.addBook(Book(
        title: title,
        author: _userName,
        chapters: chapters,
        totalPages: totalPages,
        dateBookCreated: AppDate().getCurrentDateTime(),
        isPublished: false,
      ));

      if (context.mounted) {
        if (result != null) {
          AppValidator.showSnackBar(
              context, '$title added successfully', false);
          return result;
        } else {
          AppValidator.showSnackBar(context,
              'Failed to add book, please contact the app owner', true);
        }
      }
    } catch (e) {
      if (context.mounted) {
        AppValidator.showSnackBar(
            context, 'Error: Failed to add book: $e', true);
        return AppStrings.failure;
      }
    }
    return AppStrings.failure;
  }

  Future<void> updateBook(Book book, String bookTitle, Chapter chapter,
      BuildContext context) async {
    try {
      final foundChapterIndex = book.chapters.indexWhere(
        (ch) => ch.id == chapter.id,
      );

      final updatedChapter = book.chapters[foundChapterIndex].copyWith(
        title: chapter.title,
        content: chapter.content,
        totalPages: chapter.totalPages,
      );

      final updatedChapters = List<Chapter>.from(book.chapters);
      updatedChapters[foundChapterIndex] = updatedChapter;

      final totalPages = updatedChapters.fold<int>(
        0,
        (sum, chapter) => sum + chapter.totalPages,
      );

      final updatedBook = book.copyWith(
        chapters: updatedChapters,
        totalPages: totalPages,
        isPublished: false,
      );

      debugPrint("updatedChapters: $updatedChapters, totalPages: $updatedBook");

      final result = await _bookRepo.updateBook(updatedBook);

      if (context.mounted) {
        if (result == AppStrings.success) {
          AppValidator.showSnackBar(context, '${book.title} saved', false);
        } else {
          AppValidator.showSnackBar(context,
              'Failed to update book, please contact the app owner', true);
        }
      }
    } catch (e) {
      debugPrint("Error in saving book. Error: $e");
    }
  }
}
