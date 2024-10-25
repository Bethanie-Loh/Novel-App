import 'package:flutter/material.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_app/constants/app_strings.dart';
import 'package:novel_app/data/model/book.dart';
import 'package:novel_app/data/model/chapter.dart';
import 'package:novel_app/data/repo/book_repo.dart';
import 'package:novel_app/provider/write_book_provider.dart';
import 'package:novel_app/screens/write/write_controller.dart';
import 'package:novel_app/screens/write/write_screen.dart';
import 'package:novel_app/utils/app_colors.dart';
import 'package:novel_app/utils/app_text_field.dart';
import 'package:novel_app/utils/app_text_styles.dart';
import 'package:novel_app/utils/app_validator.dart';
import 'package:go_router/go_router.dart';

class AppWriteDialog extends ConsumerStatefulWidget {
  final String header;
  final bool newBook;
  final Book? book;
  final BuildContext? context;
  final int? charCount;
  final Function(Book updatedBook)? onBookUpdated;
  final Function(String bookId)? onNewBookReleased;
  final bool? renameChapterTitle;
  final int? chapterId;

  const AppWriteDialog({
    super.key,
    required this.header,
    required this.newBook,
    this.book,
    this.context,
    this.charCount,
    this.onBookUpdated,
    this.renameChapterTitle,
    this.onNewBookReleased,
    this.chapterId,
  });

  @override
  ConsumerState<AppWriteDialog> createState() => _AppWriteDialogState();
}

class _AppWriteDialogState extends ConsumerState<AppWriteDialog> {
  final bookRepo = BookRepo();
  late TextEditingController _controller;
  final WriteController _writeController = WriteController();

  @override
  void initState() {
    _init();
    super.initState();
  }

  void _init() {
    final notifier = ref.read(writeBookNotifierProvider.notifier);

    _controller = TextEditingController(
      text: widget.newBook
          ? "New Book"
          : widget.renameChapterTitle == true
              ? notifier.chapterTitle
              : notifier.bookTitle,
    );

    // Listen for changes to the controller
    _controller.addListener(() {
      final inputText = _controller.text.trim();
      if (widget.newBook) {
        notifier.updateBookTitle(inputText); // Update book title
      } else if (widget.renameChapterTitle == true) {
        notifier.updateChapterTitle(inputText); // Update chapter title
      } else {
        notifier.updateBookTitle(inputText); // Default update
      }
    });
  }

  void addNewBook(String bookTitle) async {
    debugPrint("Add new book in dialog");

    final chapter = Chapter(
      id: 1,
      title: "New Chapter 1",
      content: Delta()..insert(""),
      totalPages: 1,
    );

    debugPrint('Adding new book: ${chapter.toMap()}');

    if (widget.context == null) {
      debugPrint("Error: widget.context is null");
      return;
    }

    final res = await _writeController.addNewBook(
      widget.context!,
      bookTitle,
      [chapter],
      chapter.totalPages,
    );

    debugPrint("res: $res");

    if (res.isNotEmpty) {
      if (widget.onNewBookReleased != null) {
        widget.onNewBookReleased!(res);
      }

      Navigator.of(widget.context!).pop();

      if (widget.book != null) {
        widget.context!.pushNamed(
          WriteScreen.route,
          pathParameters: {
            'bookId': widget.book!.id!,
            'chapterId': '1',
          },
          extra: {'newBook': true, 'chapterTitle': chapter.title},
        );
      } else {
        debugPrint("Error: widget.book is null");
      }
    } else {
      debugPrint("Error in adding new book");
    }
  }

  void updateBookTitle(String bookTitle) async {
    debugPrint("CHANGING BOOK TITLE INSIDE DIALOG");

    Book updatedBook = widget.book!.copyWith(
      title: bookTitle,
    );

    final result = await bookRepo.updateBook(updatedBook);

    if (result == AppStrings.success) {
      Navigator.of(widget.context!).pop();

      if (widget.onBookUpdated != null) {
        widget.onBookUpdated!(updatedBook);
      }

      AppValidator.showSnackBar(widget.context!, 'Book title updated', false);
    } else {
      AppValidator.showSnackBar(widget.context!,
          'Failed to update book title, please contact the app owner', true);
    }
  }

  void updateChapterTitle(String chapterTitle) async {
    if (widget.book == null) {
      debugPrint("Book is missing");
      return;
    }

    if (widget.book!.chapters.isEmpty) {
      debugPrint("No chapters found in the book");
      return;
    }

    int chapterId = widget.book!.chapters.length == 1
        ? widget.book!.chapters.first.id!
        : widget.chapterId ?? -1;

    if (chapterId == -1) {
      debugPrint("Chapter ID is missing or invalid");
      return;
    }

    List<Chapter> updatedChapters = List.from(widget.book!.chapters);

    int chapterIndex = updatedChapters.indexWhere(
      (chapter) => chapter.id == chapterId,
    );

    if (chapterIndex != -1) {
      updatedChapters[chapterIndex] = updatedChapters[chapterIndex].copyWith(
        title: chapterTitle,
      );

      Book updatedBook = widget.book!.copyWith(chapters: updatedChapters);
      final result = await bookRepo.updateBook(updatedBook);

      if (result == AppStrings.success) {
        Navigator.of(widget.context!).pop();

        if (widget.onBookUpdated != null) {
          widget.onNewBookReleased!(updatedBook.id!);
        }

        AppValidator.showSnackBar(
            widget.context!, 'Chapter title updated', false);
      } else {
        AppValidator.showSnackBar(
            widget.context!,
            'Failed to update chapter title, please contact the app owner',
            true);
      }
    } else {
      debugPrint("Chapter not found");
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("is it newBook: ${widget.newBook}");
    debugPrint("is it renameChapterTitle: ${widget.renameChapterTitle}");
    return Consumer(builder: (context, ref, _) {
      final state = ref.watch(writeBookNotifierProvider);
      final bookTitle = state.bookTitle;
      final chapterTitle = state.chapterTitle;

      return AlertDialog(
        backgroundColor: AppColors.periwinkle,
        title: Text(
          widget.header,
          style: AppTextStyles.bold_20,
        ),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          if (widget.newBook) ...[
            const Text("You may change it later anytime",
                style: AppTextStyles.italic_16),
            const SizedBox(height: 20)
          ],
          AppTextfield(
            hintText: widget.newBook ? bookTitle : chapterTitle,
            obscureText: false,
            controller: _controller,
          )
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTextStyles.italic_bold_16
                  .copyWith(color: AppColors.mulberry),
            ),
          ),
          TextButton(
            onPressed: () {
              if (widget.newBook) {
                addNewBook(bookTitle);
                updateBookTitle(bookTitle);
              } else {
                if (widget.renameChapterTitle == true) {
                  updateChapterTitle(chapterTitle);
                } else {
                  updateBookTitle(bookTitle);
                }
              }
            },
            child: Text(
              "OK",
              style: AppTextStyles.italic_bold_16
                  .copyWith(color: AppColors.mulberry),
            ),
          ),
        ],
      );
    });
  }
}
