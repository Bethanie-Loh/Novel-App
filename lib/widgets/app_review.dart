import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:novel_app/core/service/auth_service.dart';
import 'package:novel_app/data/model/book.dart';
import 'package:novel_app/data/model/review.dart';
import 'package:novel_app/data/repo/user_repo.dart';
import 'package:novel_app/screens/profile/profile_screen.dart';
import 'package:novel_app/screens/view_book.dart/like_review_controller.dart';
import 'package:novel_app/utils/app_colors.dart';
import 'package:novel_app/utils/app_date.dart';
import 'package:novel_app/utils/app_loading.dart';
import 'package:novel_app/utils/app_text_styles.dart';
import 'package:novel_app/utils/app_validator.dart';
import 'package:go_router/go_router.dart';

class ReviewSection extends StatefulWidget {
  final Book book;
  const ReviewSection({super.key, required this.book});

  @override
  State<ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends State<ReviewSection> {
  final _userRepo = UserRepo();
  final TextEditingController _commentController = TextEditingController();
  final _reviewController = LikeReviewController();
  bool _showComments = false;
  bool _isLoading = false;
  String? _userId;
  String? _userName;
  String? _profilePicture;
  List<Review> _reviews = [];

  @override
  void initState() {
    _init();
    super.initState();
  }

  void _init() {
    _getUser();
  }

  void _getUser() {
    setState(() => _isLoading = true);

    _userRepo.getUserStream().listen((user) {
      if (user != null) {
        setState(() {
          _userId = AuthService().getUid();
          _userName = user.name;
          _profilePicture = user.profilePicture;
          _reviews = widget.book.reviews ?? [];

          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    });
  }

  void _toggleComments() {
    setState(() => _showComments = !_showComments);
  }

  void _addReview() async {
    if (_commentController.text.isEmpty) {
      AppValidator.showSnackBar(context, "Empty comments are forbidden", true);
      return;
    }

    final reviewId = _reviews.isEmpty ? 1 : _reviews.length + 1;
    final review = Review(
      id: reviewId.toString(),
      timestamp: AppDate().getCurrentDateTime(),
      userId: _userId!,
      userName: _userName!,
      profilePicture: _profilePicture!,
      comment: _commentController.text,
    );

    await _reviewController.addComment(widget.book, review, context);
    setState(() => _commentController.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          onPressed: _toggleComments,
          icon: Row(
            children: [
              SvgPicture.asset('assets/icons/ic_chat_bubble.svg'),
              const SizedBox(width: 5),
              Text(
                _reviews.isEmpty
                    ? ''
                    : _reviews.length == 1
                        ? '${_reviews.length} review'
                        : '${_reviews.length} reviews',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        _isLoading
            ? const AppLoading()
            : Visibility(
                visible: _showComments,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _reviews.length,
                          itemBuilder: (context, index) {
                            return ReviewItem(
                              review: _reviews[index],
                              profilePicture: _profilePicture ?? '',
                              context: context,
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: TextField(
                          cursorColor: AppColors.periwinkle,
                          style: AppTextStyles.inputText
                              .copyWith(color: AppColors.white),
                          controller: _commentController,
                          decoration: InputDecoration(
                            focusColor: AppColors.mulberry,
                            hintText: "What's your thought on this book?",
                            focusedBorder: const UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColors.periwinkle),
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.send,
                                  color: AppColors.periwinkle),
                              onPressed: () => _addReview(),
                            ),
                          ),
                          onSubmitted: (text) => _addReview(),
                        ),
                      )
                    ],
                  ),
                ),
              ),
      ],
    );
  }
}

class ReviewItem extends StatelessWidget {
  final Review review;
  final String profilePicture;
  final BuildContext context;

  const ReviewItem(
      {super.key,
      required this.review,
      required this.profilePicture,
      required this.context});

  void navigateToProfileScreen(String userId) {
    context.pushNamed(
      ProfileScreen.route,
      extra: userId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: GestureDetector(
        onTap: () => navigateToProfileScreen(review.userId),
        child: SizedBox(
          width: 30,
          height: 30,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: profilePicture.isNotEmpty
                ? Image.network(
                    review.profilePicture,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  )
                : Image.asset(
                    "assets/images/sky.jpg",
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
          ),
        ),
      ),
      title: Text(
        review.userName,
        style: AppTextStyles.italic_bold_16,
      ),
      subtitle: Text(
        review.comment,
        style: AppTextStyles.regular_14,
      ),
      trailing: Text(
        _formatTime(review.timestamp),
        style: const TextStyle(fontSize: 12, color: AppColors.gray),
      ),
    );
  }

  String _formatTime(String timestampString) {
    final format = DateFormat('dd MMM yyyy HH:mm:ss');

    final timestamp = format.parse(timestampString);

    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays >= 365) {
      return '${(difference.inDays / 365).floor()}y';
    } else if (difference.inDays >= 30) {
      return '${(difference.inDays / 30).floor()}mo';
    } else if (difference.inDays >= 7) {
      return '${(difference.inDays / 7).floor()}w';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Just now';
    }
  }
}
