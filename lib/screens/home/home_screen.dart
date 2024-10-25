import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:novel_app/controllers/books_controller.dart';
import 'package:novel_app/data/model/book.dart';
import 'package:novel_app/data/model/user.dart';
import 'package:novel_app/data/repo/user_repo.dart';
import 'package:novel_app/utils/app_colors.dart';
import 'package:novel_app/utils/app_loading.dart';
import 'package:novel_app/utils/app_text_styles.dart';
import 'package:novel_app/widgets/app_display_books.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final BooksController _booksController = BooksController();
  final _userRepo = UserRepo();
  late Stream<List<Book>> _incompleteBooks;
  late Stream<List<Book>> _savedBooks;
  late Stream<List<Book>> _favouriteGenresBooks;
  bool _isLoading = true;

  @override
  void initState() {
    _init();
    super.initState();
  }

  void _init() {
    _fetchBooks();
  }

  void _fetchBooks() async {
    setState(() => _isLoading = true);

    try {
      setState(() {
        _incompleteBooks = _booksController.getIncompleteBooks();
        _savedBooks = _booksController.getSavedBooks();
        _favouriteGenresBooks = _booksController.getFavouriteGenreBooks();
      });
    } catch (e) {
      debugPrint("Error fetching incomplete books and saved books: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mystery,
      body: _isLoading
          ? const Center(child: AppLoading())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildWelcomeSection(),
                  const SizedBox(height: 20),
                  AppDisplayBooks(
                    sectionName: "Continue Writing...",
                    books: _incompleteBooks,
                    viewBook: false,
                    isSaved: false,
                    continueWriting: true,
                    emptyMessage:
                        "You haven't created any books to write yet. Start writing now!",
                  ),
                  const SizedBox(height: 20),
                  AppDisplayBooks(
                    sectionName: "Your Library",
                    books: _savedBooks,
                    viewBook: true,
                    continueWriting: false,
                    isSaved: true,
                    emptyMessage: "You haven't saved any books yet",
                  ),
                  const SizedBox(height: 20),
                  AppDisplayBooks(
                    sectionName: "Recommended for you",
                    books: _favouriteGenresBooks,
                    viewBook: true,
                    continueWriting: false,
                    isSaved: false,
                    emptyMessage: "No books match your interests yet",
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildWelcomeSection() {
    return StreamBuilder<AppUser?>(
      stream: _userRepo.getUserStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AppLoading();
        } else if (snapshot.hasError) {
          return const Text('Error loading user',
              style: AppTextStyles.italic_white_bold_18);
        } else if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          return Row(
            children: [
              Text(
                "Welcome, ${user.name}",
                style: AppTextStyles.italic_white_bold_18,
              ),
              const SizedBox(width: 8),
              SvgPicture.asset(
                'assets/icons/ic_sparkle2.svg',
              ),
            ],
          );
        } else {
          return const Text('Welcome, User',
              style: AppTextStyles.italic_white_bold_18);
        }
      },
    );
  }
}
