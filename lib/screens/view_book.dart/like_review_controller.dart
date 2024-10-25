import 'package:flutter/material.dart';
import 'package:novel_app/constants/app_strings.dart';
import 'package:novel_app/core/service/auth_service.dart';
import 'package:novel_app/data/model/book.dart';
import 'package:novel_app/data/model/review.dart';
import 'package:novel_app/data/repo/book_repo.dart';
import 'package:novel_app/utils/app_validator.dart';

class LikeReviewController {
  final _bookRepo = BookRepo();

  Future<void> handleLike(Book book, bool liked, BuildContext context) async {
    final userId = AuthService().getUid();
    if (book.likedUserIds!.contains(userId)) return;
    final updatedBook = book.copyWith(likedUserIds: [...?book.likedUserIds]);

    liked
        ? updatedBook.likedUserIds?.remove(userId)
        : updatedBook.likedUserIds?.add(userId!);

    final res = await _bookRepo.updateBook(updatedBook);
    if (!context.mounted) return;

    if (!liked && res == AppStrings.success) {
      AppValidator.showSnackBar(context, "You liked ${book.title}", false);
    } else if (liked && res == AppStrings.success) {
      AppValidator.showSnackBar(context, "You unliked ${book.title}", false);
    }
  }

  Future<void> addComment(
      Book book, Review review, BuildContext context) async {
    try {
      List<Review> updatedReviews = book.reviews ?? [];
      updatedReviews.add(review);
      final updatedBook = book.copyWith(reviews: updatedReviews);
      debugPrint("reviews at addCommentt: $updatedReviews");
      final res = await _bookRepo.updateBook(updatedBook);

      if (!context.mounted) return;
      if (res == AppStrings.success) {
        AppValidator.showSnackBar(context, "Review added successfully", false);
      } else {
        AppValidator.showSnackBar(context, "Failed to add review", true);
      }
    } catch (e) {
      debugPrint("Failed to add review: $e");
    }
  }
}
