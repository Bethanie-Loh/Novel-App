import 'package:flutter/material.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_app/constants/app_strings.dart';
import 'package:novel_app/data/model/book.dart';
import 'package:novel_app/data/model/chapter.dart';
import 'package:novel_app/data/repo/book_repo.dart';
import 'package:novel_app/provider/write_book_provider.dart';
import 'package:novel_app/screens/view_book.dart/view_book_screen.dart';
import 'package:novel_app/screens/write/write_screen.dart';
import 'package:novel_app/utils/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:novel_app/utils/app_text_styles.dart';
import 'package:novel_app/utils/app_validator.dart';

class WritePopUpMenu extends StatelessWidget {
  final Function? onToggleGeminiAI;
  final Book book;

  const WritePopUpMenu({
    super.key,
    this.onToggleGeminiAI,
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    final bookRepo = BookRepo();

    void addNewChapter(WriteBookNotifier notifier) async {
      final newChapterTitle = "New Chapter ${book.chapters.length + 1}";
      final newContent = Delta()..insert("Beginning of a new chapter...\n");
      debugPrint("THIS BOOK'S LENGTH: ${book.chapters.length}");
      final newEmptyChapter = Chapter(
          id: book.chapters.length + 1,
          title: newChapterTitle,
          content: newContent,
          totalPages: 1);
      debugPrint('New chapter content: ${newEmptyChapter.content}');
      final updatedBook =
          book.copyWith(chapters: [...book.chapters, newEmptyChapter]);

      final result = await bookRepo.updateBook(updatedBook);
      debugPrint("result: $result");
      if (!context.mounted) return;
      if (result == AppStrings.success) {
        notifier.updateQuillDocument(newContent);
        notifier.updateBookTitle(book.title ?? "Couldn't get book title");
        notifier.updateChapterTitle(newChapterTitle);
        final latestChapterId = updatedBook.chapters.last.id;
        context.pushNamed(WriteScreen.route, pathParameters: {
          'bookId': book.id!,
          'chapterId': latestChapterId.toString(),
        }, extra: {
          'newBook': false,
          'newChapter': true,
          'chapterTitle': newChapterTitle,
        });
        AppValidator.showSnackBar(context, 'Welcome to new chapter', false);
      } else {
        AppValidator.showSnackBar(context,
            'Failed to add a new chapter, please contact the app owner', true);
      }
    }

    void navigateToViewBook() {
      context.pushNamed(
        ViewBookScreen.route,
        pathParameters: {'bookId': book.id!},
        extra: {'isAuthor': true, 'isSaved': false, 'isWriting': true},
      );
    }

    return Consumer(
      builder: (context, ref, _) {
        final watchWriteScreen = ref.watch(writeBookNotifierProvider);
        final notifier = ref.read(writeBookNotifierProvider.notifier);
        final isDarkMode = watchWriteScreen.isDarkMode;
        final isWriting = watchWriteScreen.isWriting;
        final wordCount = watchWriteScreen.wordCount;
        final charCount = watchWriteScreen.charCount;

        return PopupMenuButton<String>(
          color: AppColors.periwinkle,
          child: const Icon(Icons.more_vert, color: AppColors.black),
          onSelected: (value) {
            if (value == 'new chapter') {
              addNewChapter(notifier);
            } else if (value == 'view & edit book') {
              navigateToViewBook();
            } else {
              debugPrint("clicking gemini ai in pop up menu");
              notifier.toggleGeminiAI();
            }
          },
          itemBuilder: (BuildContext context) {
            List<PopupMenuEntry<String>> menuItems = [
              PopupMenuItem(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        isDarkMode
                            ? const Icon(Icons.dark_mode)
                            : const Icon(Icons.light_mode),
                        const SizedBox(width: 10),
                        Switch(
                            activeColor: AppColors.mulberry,
                            value: isDarkMode,
                            onChanged: (bool value) =>
                                {notifier.toggleDarkMode()})
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                child: Text('Word Count: $wordCount',
                    style: AppTextStyles.bold_14),
              ),
              PopupMenuItem<String>(
                  child: Text('Characters Count: $charCount',
                      style: AppTextStyles.bold_14)),
            ];

            if (!isWriting) {
              menuItems.add(
                const PopupMenuItem<String>(
                  value: 'new chapter',
                  child: Text('New Chapter', style: AppTextStyles.bold_14),
                ),
              );
              menuItems.add(
                const PopupMenuItem<String>(
                    value: 'view & edit book',
                    child:
                        Text('View & Edit Book', style: AppTextStyles.bold_14)),
              );
            }

            if (isWriting) {
              menuItems.add(const PopupMenuItem<String>(
                value: 'Gemini AI',
                child: Text('Gemini AI', style: AppTextStyles.bold_14),
              ));
            }
            return menuItems;
          },
        );
      },
    );
  }
}
