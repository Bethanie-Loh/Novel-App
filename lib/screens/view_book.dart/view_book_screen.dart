import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_app/controllers/global_data_controller.dart';
import 'package:novel_app/core/service/auth_service.dart';
import 'package:novel_app/data/model/book.dart';
import 'package:novel_app/data/model/user.dart';
import 'package:novel_app/data/repo/user_repo.dart';
import 'package:novel_app/screens/edit_book/edit_book_screen.dart';
import 'package:novel_app/screens/read/read_screen.dart';
import 'package:novel_app/screens/view_book.dart/like_review_controller.dart';
import 'package:novel_app/screens/view_book.dart/view_book_controller.dart';
import 'package:novel_app/utils/app_colors.dart';
import 'package:novel_app/utils/app_loading.dart';
import 'package:novel_app/utils/app_text_styles.dart';
import 'package:novel_app/widgets/app_appbar.dart';
import 'package:novel_app/widgets/app_drawer.dart';
import 'package:go_router/go_router.dart';
import 'package:novel_app/widgets/app_review.dart';

class ViewBookScreen extends ConsumerStatefulWidget {
  final String bookId;
  final bool isSaved;
  final bool isWriting;

  const ViewBookScreen({
    super.key,
    required this.bookId,
    required this.isSaved,
    required this.isWriting,
  });
  static const route = 'view_book';
  @override
  ConsumerState<ViewBookScreen> createState() => _ViewBookScreenState();
}

class _ViewBookScreenState extends ConsumerState<ViewBookScreen> {
  final _globalDataController = GlobalDataController();
  final _viewBookController = ViewBookController();
  final _reviewController = LikeReviewController();
  final _userRepo = UserRepo();

  Book? book;
  bool _isLoading = false;
  bool isAuthor = false;
  bool isSaved = false;
  String _userId = '';
  bool _isPublished = false;
  bool _like = false;
  int? _likeCount;
  void _init() {
    _fetchBook();
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  Future<Book?> _fetchBook() async {
    _userId = AuthService().getUid()!;
    debugPrint("_userId at viewbook: $_userId");
    setState(() => _isLoading = true);
    try {
      final fetchedBook =
          await _globalDataController.getBookById(widget.bookId);

      debugPrint("fetchedBook: $fetchedBook");
      debugPrint("this book publish status: ${fetchedBook!.isPublished}");

      final AppUser? user = await _userRepo.getUserById(_userId);

      setState(() {
        book = fetchedBook;
        isAuthor = user!.name == book!.author! ? true : false;
        book!.savedUserIds?.contains(_userId) == true
            ? isSaved = true
            : isSaved = false;
        _isPublished = book!.isPublished;
        _likeCount = book!.likedUserIds!.length;
        _like = book!.likedUserIds!.contains(_userId);
        _isLoading = false;
      });

      return fetchedBook;
    } catch (e) {
      debugPrint('Error fetching book: $e');
      setState(() => _isLoading = false);
      return null;
    }
  }

  void _navigateToEditBook() {
    context.pushNamed(
      EditBookScreen.route,
      pathParameters: {'bookId': widget.bookId},
    );
  }

  void _handlePublishBook() {
    _viewBookController.publishBook(book!, context, _isPublished);
  }

  void _toggleSaveToLibrary() async {
    await _viewBookController.saveBookToLibrary(context, isSaved, book!);
    setState(() => isSaved = !isSaved);
  }

  void navigateToReadScreen(String bookId) {
    debugPrint("im sending this $bookId");
    context.pushNamed(
      ReadScreen.route,
      pathParameters: {'bookId': bookId, 'chapterId': '1'},
      extra: {'newReading': false},
    );
  }

  void _handleLike() async {
    await _reviewController.handleLike(book!, _like, context);
    setState(() {
      _like = !_like;
      _likeCount = _like ? _likeCount! + 1 : _likeCount! - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mystery,
      appBar: const AppAppbar(),
      drawer: const AppDrawer(),
      body: Container(
        child: _isLoading
            ? const Center(child: AppLoading())
            : book == null
                ? const Center(
                    child: Text(
                      'Book data is unavailable',
                      style: AppTextStyles.regular_16,
                    ),
                  )
                : SingleChildScrollView(
                    child: Container(
                      margin: const EdgeInsets.all(25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppColors.periwinkle.withOpacity(0.3),
                                    blurRadius: 4,
                                    spreadRadius: 3,
                                    offset: const Offset(2, 3),
                                  ),
                                ],
                              ),
                              child: SizedBox(
                                width: 130,
                                height: 180,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: book!.cover != null &&
                                          book!.cover!.isNotEmpty
                                      ? Image.network(
                                          book!.cover!,
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
                          ),
                          const SizedBox(height: 35),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  book?.title ?? "Unknown title",
                                  style: AppTextStyles.bold_24
                                      .copyWith(color: AppColors.white),
                                  maxLines: 3,
                                ),
                              ),
                              !widget.isWriting
                                  ? IconButton(
                                      icon: Icon(
                                        isSaved
                                            ? Icons.bookmark
                                            : Icons.bookmark_border,
                                        color: isSaved
                                            ? AppColors.periwinkle
                                            : AppColors.white,
                                      ),
                                      iconSize: 28,
                                      onPressed: _toggleSaveToLibrary,
                                      splashColor: Colors.transparent,
                                    )
                                  : const Row(),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                              "Written By: ${book?.author ?? "Unknown author"}",
                              style: AppTextStyles.italic_16
                                  .copyWith(color: AppColors.white)),
                          const SizedBox(height: 25),
                          isSaved
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 180,
                                      child: OutlinedButton(
                                          onPressed: () =>
                                              navigateToReadScreen(book!.id!),
                                          style: ButtonStyle(
                                            padding: WidgetStateProperty.all(
                                                const EdgeInsets.symmetric(
                                                    horizontal: 25,
                                                    vertical: 0)),
                                            side: const WidgetStatePropertyAll(
                                                BorderSide.none),
                                            backgroundColor:
                                                const WidgetStatePropertyAll(
                                                    AppColors.emerald),
                                          ),
                                          child: const Text("Read",
                                              style: AppTextStyles
                                                  .italic_bold_16)),
                                    ),
                                  ],
                                )
                              : const Row(),
                          const SizedBox(height: 10),
                          const Text("Summary:", style: AppTextStyles.bold_18),
                          const SizedBox(height: 10),
                          Text(
                            book?.summary ?? "No summary available",
                            style: AppTextStyles.regular_16
                                .copyWith(color: AppColors.white),
                          ),
                          const SizedBox(height: 15),
                          const Text("Genres:", style: AppTextStyles.bold_18),
                          const SizedBox(height: 10),
                          Text(
                            (book?.genres?.isNotEmpty == true)
                                ? book!.genres!.join(', ')
                                : "No genre specified",
                            style: AppTextStyles.regular_16
                                .copyWith(color: AppColors.white),
                          ),
                          const SizedBox(height: 15),
                          const Text("Total Pages:",
                              style: AppTextStyles.bold_18),
                          const SizedBox(width: 15),
                          Text(
                              book!.totalPages == 1
                                  ? "${book!.totalPages.toString()} page"
                                  : "${book!.totalPages.toString()} pages",
                              style: AppTextStyles.regular_16
                                  .copyWith(color: AppColors.white)),
                          const SizedBox(height: 30),
                          !widget.isWriting
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    IconButton(
                                      color: _like
                                          ? AppColors.grapeRed
                                          : Colors.transparent,
                                      onPressed: _handleLike,
                                      icon: Row(
                                        children: [
                                          _like
                                              ? const Icon(Icons.favorite)
                                              : const Icon(
                                                  Icons.favorite_border,
                                                  color: AppColors.white,
                                                ),
                                          const SizedBox(width: 5),
                                          Text(
                                            _likeCount! > 0
                                                ? _likeCount == 1
                                                    ? '$_likeCount like'
                                                    : '$_likeCount likes'
                                                : '',
                                            style: AppTextStyles.bold_12
                                                .copyWith(
                                                    color: AppColors.gray),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ReviewSection(book: book!)
                                  ],
                                )
                              : const Column(),
                          const SizedBox(height: 50),
                          isAuthor
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    OutlinedButton(
                                      onPressed: () => _handlePublishBook(),
                                      style: ButtonStyle(
                                        padding: WidgetStateProperty.all(
                                            const EdgeInsets.symmetric(
                                                horizontal: 25, vertical: 0)),
                                        side: const WidgetStatePropertyAll(
                                            BorderSide.none),
                                        backgroundColor:
                                            const WidgetStatePropertyAll(
                                                AppColors.mulberry),
                                      ),
                                      child: Text(
                                          !_isPublished
                                              ? "Publish Book"
                                              : "Unpublish Book",
                                          style: AppTextStyles.italic_bold_16),
                                    ),
                                    const SizedBox(width: 60),
                                    OutlinedButton(
                                        onPressed: () => _navigateToEditBook(),
                                        style: ButtonStyle(
                                          padding: WidgetStateProperty.all(
                                              const EdgeInsets.symmetric(
                                                  horizontal: 25, vertical: 0)),
                                          side: const WidgetStatePropertyAll(
                                              BorderSide.none),
                                          backgroundColor:
                                              const WidgetStatePropertyAll(
                                                  AppColors.emerald),
                                        ),
                                        child: const Text("Edit Book",
                                            style:
                                                AppTextStyles.italic_bold_16)),
                                  ],
                                )
                              : const Center(),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}
