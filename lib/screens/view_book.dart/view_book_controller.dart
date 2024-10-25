import 'package:flutter/material.dart';
import 'package:novel_app/constants/app_strings.dart';
import 'package:novel_app/core/service/auth_service.dart';
import 'package:novel_app/data/model/book.dart';
import 'package:novel_app/data/repo/book_repo.dart';
import 'package:novel_app/screens/tab_container_screen.dart';
import 'package:novel_app/utils/app_date.dart';
import 'package:novel_app/utils/app_validator.dart';
import 'package:go_router/go_router.dart';

class ViewBookController {
  final _bookRepo = BookRepo();

  Future<void> saveBookToLibrary(
      BuildContext context, bool isSaved, Book book) async {
    final userId = AuthService().getUid();
    final updatedBook = book.copyWith(savedUserIds: [...?book.savedUserIds]);

    isSaved
        ? updatedBook.savedUserIds?.remove(userId)
        : updatedBook.savedUserIds?.add(userId!);

    final res = await _bookRepo.updateBook(updatedBook);
    if (!context.mounted) return;

    if (!isSaved && res == AppStrings.success) {
      AppValidator.showSnackBar(context,
          "${book.title} saved to your library. Enjoy reading!", false);
    } else if (isSaved && res == AppStrings.success) {
      AppValidator.showSnackBar(
          context, "${book.title} removed from your library", false);
    }
  }

  Future<void> publishBook(
      Book book, BuildContext context, bool publishStatus) async {
    try {
      final updatedBook = book.copyWith(
        datePublished: AppDate().getCurrentDateTime(),
        isPublished: publishStatus == true ? false : true,
      );

      final res = await _bookRepo.updateBook(updatedBook);

      if (!context.mounted) return;
      if (res == AppStrings.success) {
        publishStatus == false
            ? AppValidator.showSnackBar(context,
                "${book.title} is published! Great job for your effort!", false)
            : AppValidator.showSnackBar(
                context,
                "${book.title} has unpublished. Hope to see your book again.",
                false);
        context.pushNamed(TabContainerScreen.route);
      } else if (res == AppStrings.failure) {
        publishStatus == false
            ? AppValidator.showSnackBar(
                context, "${book.title} has problems in publishing", false)
            : AppValidator.showSnackBar(
                context, "${book.title} has problems in unpublishing", false);
      }
    } catch (e) {
      debugPrint("Error in publishing book. Error: $e");
    }
  }
}
