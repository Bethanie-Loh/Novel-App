import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_app/controllers/books_controller.dart';
import 'package:novel_app/utils/app_colors.dart';
import 'package:novel_app/utils/app_text_styles.dart';
import 'package:novel_app/widgets/app_appbar.dart';
import 'package:novel_app/widgets/app_display_books.dart';
import 'package:novel_app/widgets/app_drawer.dart';

class YourBooksScreen extends ConsumerStatefulWidget {
  const YourBooksScreen({super.key});
  static const route = "YourBooks";
  @override
  ConsumerState<YourBooksScreen> createState() => _YourBooksScreenState();
}

class _YourBooksScreenState extends ConsumerState<YourBooksScreen> {
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
            const Text("Your Books", style: AppTextStyles.italic_white_bold_24),
            const SizedBox(height: 30),
            AppDisplayBooks(
              sectionName: "Published Books",
              books: _booksController.getYourPublishedBooks(),
              continueWriting: false,
              viewBook: true,
              isSaved: false,
              emptyMessage: "You have not published any books yet",
            ),
          ],
        ),
      ),
    );
  }
}
