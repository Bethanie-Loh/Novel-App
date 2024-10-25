import 'package:flutter/material.dart';
import 'package:novel_app/controllers/books_controller.dart';
import 'package:novel_app/utils/app_colors.dart';
import 'package:novel_app/utils/app_text_styles.dart';
import 'package:novel_app/widgets/app_appbar.dart';
import 'package:novel_app/widgets/app_display_books.dart';
import 'package:novel_app/widgets/app_drawer.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});
  static const route = "Library";
  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final BooksController _booksController = BooksController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppbar(),
      drawer: const AppDrawer(),
      backgroundColor: AppColors.mystery,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("Library", style: AppTextStyles.italic_white_bold_24),
            const SizedBox(height: 30),
            AppDisplayBooks(
              sectionName: "Reading",
              books: _booksController.getUnfinishedReadingBooks(),
              isSaved: true,
              viewBook: false,
              continueWriting: false,
              emptyMessage: "You are currently not reading any books yet",
            ),
            const SizedBox(height: 20),
            AppDisplayBooks(
              sectionName: "Finished Reading",
              books: _booksController.getFinishedReadingBooks(),
              isSaved: false,
              viewBook: false,
              continueWriting: false,
              emptyMessage:
                  "You haven't completed reading any books yet. Keep on reading!",
            ),
          ],
        ),
      ),
    );
  }
}
