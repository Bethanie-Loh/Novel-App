import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_app/data/model/review.dart';

class BookFeedback {
  bool isLiked;
  List<Review> reviews;

  BookFeedback({required this.isLiked, required this.reviews});

  BookFeedback copyWith({
    bool? isLiked,
    List<Review>? reviews,
  }) {
    return BookFeedback(
        isLiked: isLiked ?? this.isLiked, reviews: reviews ?? this.reviews);
  }
}

class BookFeedbackNotifier extends StateNotifier<BookFeedback> {
  BookFeedbackNotifier() : super(BookFeedback(isLiked: false, reviews: []));

  void toggleLike(bool like) {
    state = state.copyWith(isLiked: like);
  }

  void addReview(Review review) {
    final updatedReviews = [...state.reviews, review];
    state = state.copyWith(reviews: updatedReviews);
  }

  void addReviews(List<Review> reviews) {
    final updatedReviews = [...state.reviews, ...reviews];
    state = state.copyWith(reviews: updatedReviews);
  }

}

final bookFeedbackNotifierProvider =
    StateNotifierProvider<BookFeedbackNotifier, BookFeedback>((ref) {
  return BookFeedbackNotifier();
});
