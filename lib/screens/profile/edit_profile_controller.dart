import 'package:flutter/material.dart';
import 'package:novel_app/constants/app_strings.dart';
import 'package:novel_app/controllers/books_controller.dart';
import 'package:novel_app/data/model/user.dart';
import 'package:novel_app/data/repo/book_repo.dart';
import 'package:novel_app/data/repo/user_repo.dart';
import 'package:novel_app/utils/app_validator.dart';

class EditProfileController {
  final _userRepo = UserRepo();
  final _booksController = BooksController();
  final _bookRepo = BookRepo();
  AppUser? user;

  EditProfileController() {
    _getUser();
  }

  void _getUser() async {
    final userStream = _userRepo.getUserStream();
    user = await userStream.first;
  }

  Future<String> updateCover(
      String profilePicture, BuildContext context) async {
    final updatedUser = user?.copyWith(profilePicture: profilePicture);
    final res = await _userRepo.updateUser(updatedUser!);

    if (context.mounted) {
      if (res == AppStrings.success) {
        AppValidator.showSnackBar(
            context, 'Image uploaded successfully', false);
        return AppStrings.success;
      } else {
        AppValidator.showSnackBar(context, 'Image upload failed', true);
        return AppStrings.failure;
      }
    }
    return AppStrings.failure;
  }

  Future<void> updateUser(
    String name,
    String imageUrl,
    String dob,
    String quote,
    List<String> selectedGenres,
    BuildContext context,
  ) async {
    if (!AppValidator.checkInputIfEmpty([name, dob, quote], context)) return;
    debugPrint("user in updateUser: $user");

    try {
      final updatedUser = user?.copyWith(
        name: name,
        profilePicture: imageUrl,
        quote: quote,
        favouriteGenres: selectedGenres,
        dob: dob,
      );

      final res = await _userRepo.updateUser(updatedUser!);
      if (res == AppStrings.success) {
        if (!context.mounted) return;
        await _updateBookAuthor(name, context);
        if (!context.mounted) return;
        AppValidator.showSnackBar(
            context, 'Your profile has been updated', false);
        Navigator.pop(context);
      } else {
        if (!context.mounted) return;
        AppValidator.showSnackBar(context, 'Failed to update user', true);
      }
    } catch (e) {
      debugPrint("Error in updating profile: $e");
    }
  }

  Future<void> _updateBookAuthor(
      String newAuthorName, BuildContext context) async {
    debugPrint("newAuthorname: $newAuthorName");
    try {
      final booksStream = _booksController.getYourPublishedBooks();
      debugPrint("booksStream in _updateBookAuthor: $booksStream");

      final books = await booksStream.first;
      debugPrint("books in _updateBookAuthor: $books");
      for (var book in books) {
        final updatedBook = book.copyWith(author: newAuthorName);
        final res = await _bookRepo.updateBook(updatedBook);

        if (context.mounted) {
          if (res == AppStrings.success) {
            AppValidator.showSnackBar(context, '${book.author} updated', false);
          } else {
            AppValidator.showSnackBar(context,
                'Failed to update book, please contact the app owner', true);
          }
        }
      }
    } catch (e) {
      debugPrint("Error updating book author: $e");
    }
  }
}
