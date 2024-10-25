import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_app/controllers/global_data_controller.dart';
import 'package:novel_app/data/model/book.dart';
import 'package:novel_app/data/model/chapter.dart';
import 'package:novel_app/provider/write_book_provider.dart';
import 'package:novel_app/screens/write/custom_quill/app_quill_toolbar.dart';
import 'package:novel_app/screens/write/my_quill_editor.dart';
import 'package:novel_app/screens/write/write_controller.dart';
import 'package:novel_app/screens/write/write_pop_up_menu.dart';
import 'package:novel_app/utils/app_colors.dart';
import 'package:novel_app/utils/app_loading.dart';
import 'package:novel_app/utils/app_text_styles.dart';
import 'package:novel_app/utils/app_write_dialog.dart';
import 'package:novel_app/widgets/book_drawer.dart';

class WriteScreen extends ConsumerStatefulWidget {
  final String? bookId;
  final int? chapterId;
  final String? chapterTitle;
  final bool newBook;

  const WriteScreen({
    super.key,
    this.bookId,
    this.chapterId,
    this.chapterTitle,
    required this.newBook,
  });

  static const route = "Write";

  @override
  ConsumerState<WriteScreen> createState() => _WriteScreenState();
}

class _WriteScreenState extends ConsumerState<WriteScreen> {
  final TextEditingController _bookTitleController =
      TextEditingController(text: "New Book");
  late TextEditingController _chapterTitleController;
  final GlobalKey _quillKey = GlobalKey();
  final _writeController = WriteController();
  final _globalDataController = GlobalDataController();
  late Delta documentDelta;
  Book? book;
  bool _isLoading = false;
  String bookID = '';
  bool enableGeminiAI = false;

  void _init() async {
    bookID = widget.bookId ?? '';
    await _fetchBook();
    _handleWritingActions();
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  void _handleWritingActions() {
    final notifier = ref.read(writeBookNotifierProvider.notifier);
    if (widget.newBook) {
      _showBookTitleDialog();

      notifier.updateQuillDocument(
          Delta()..insert("Beginning of a new chapter...\n"));
      notifier.updateBookTitle("New Book");
      notifier.updateChapterTitle("New Chapter 1");
      return;
    }

    if (widget.bookId?.isNotEmpty == true) {
      if (widget.chapterId != null) {
        debugPrint('Continuing writing at chapter: ${widget.chapterId}');
        _continueWriting();
      } else {
        debugPrint('Showing chapter title dialog for a new chapter');
        _showChapterTitleDialog();
      }
      return;
    }

    debugPrint('No valid book or chapter selected.');
  }

  void handleNewBookRelease(String? bookId) async {
    debugPrint("bookId: $bookId");
    setState(() => bookID = bookId!);
    await _fetchBook();
  }

  Future<void> _fetchBook() async {
    if (bookID.isEmpty) debugPrint("bookID is empty");

    if (bookID.isEmpty && widget.bookId?.isEmpty == true) {
      debugPrint('No valid bookId provided. Cannot fetch book.');
    }

    setState(() => _isLoading = true);

    try {
      final fetchedBook = await _globalDataController
          .getBookById(bookID.isNotEmpty ? bookID : widget.bookId ?? '');

      setState(() {
        book = fetchedBook;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching book: $e');
      setState(() => _isLoading = false);
    }
  }

  void _continueWriting() async {
    ref
        .read(writeBookNotifierProvider.notifier)
        .updateBookTitle(book?.title ?? "Couldn't get book title");
    Chapter? currentChapter =
        book!.chapters.firstWhere((chapter) => chapter.id == widget.chapterId);
    ref
        .read(writeBookNotifierProvider.notifier)
        .updateChapterTitle(currentChapter.title);

    Delta content = currentChapter.content;
    ref.read(writeBookNotifierProvider.notifier).updateQuillDocument(content);

    if (content.isNotEmpty && content.last.data is String) {
      String lastText = content.last.data as String;
      if (!lastText.endsWith('\n')) content.insert('\n');
    }

    if (currentChapter.id != null) {
      if (book != null) {
        debugPrint("Fetched Book: ${book!.toString()}");
      } else {
        debugPrint("No book found or an error occurred.");
      }
    } else {
      debugPrint("No chapter found with the given ID.");
    }
  }

  void _saveWriting(QuillController quillController) {
    documentDelta = quillController.document.toDelta();

    int chapterId = book!.chapters.length == 1
        ? book!.chapters.first.id!
        : widget.chapterId ?? -1;

    if (chapterId == -1) {
      debugPrint("Chapter ID is missing or invalid");
      return;
    }

    String chapterTitle = ref.read(writeBookNotifierProvider).chapterTitle;
    final charCount = ref.watch(writeBookNotifierProvider).charCount;

    final chapter = Chapter(
        id: chapterId,
        title: chapterTitle,
        content: documentDelta,
        totalPages: (charCount / 1500).ceil());

    debugPrint('Saving Chapter: ${chapter.toMap()}');

    _writeController.updateBook(
      book!,
      _bookTitleController.text,
      chapter,
      context,
    );
  }

  void handleBookUpdated(Book updatedBook) {
    setState(() => book = updatedBook);
  }

  void _showBookTitleDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AppWriteDialog(
            header: "What is the title of your new book?",
            newBook: true,
            book: book,
            renameChapterTitle: false,
            context: context,
            onNewBookReleased: handleNewBookRelease,
            onBookUpdated: null,
          );
        });
    _bookTitleController.addListener(() => setState(() {}));
  }

  void _showChapterTitleDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AppWriteDialog(
          header: "Rename Chapter",
          newBook: false,
          renameChapterTitle: true,
          book: book,
          context: context,
          onBookUpdated: handleBookUpdated,
          onNewBookReleased: handleNewBookRelease,
          chapterId: widget.chapterId,
        );
      },
    ).then((_) {
      setState(() {
        _chapterTitleController.text = _chapterTitleController.text.isNotEmpty
            ? _chapterTitleController.text
            : "New Chapter 1";
      });
    });
  }

  void _renameBookTitle() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AppWriteDialog(
          header: "Rename Book Title",
          newBook: false,
          renameChapterTitle: false,
          book: book,
          context: context,
          onBookUpdated: handleBookUpdated,
          onNewBookReleased: null,
        );
      },
    ).then((_) {
      setState(() {
        _bookTitleController.text = _bookTitleController.text.isNotEmpty
            ? _bookTitleController.text
            : "Untitled Document";
      });
    });
  }

  void toggleWritingStates(WriteBookNotifier readBookState) {
    readBookState.toggleWritingMode();
    readBookState.toggleEditorFocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final readBookState = ref.read(writeBookNotifierProvider.notifier);
      final watchBookState = ref.watch(writeBookNotifierProvider);
      final isWriting = watchBookState.isWriting;
      final chapterTitle = watchBookState.chapterTitle;
      final quillController = watchBookState.quillController;
      final editorFocusNode = watchBookState.editorFocusNode;
      final isDarkMode = watchBookState.isDarkMode;
      debugPrint("isWriting Now: $isWriting");
      return _isLoading
          ? const AppLoading()
          : Scaffold(
              appBar: !isWriting
                  ? AppBar(
                      backgroundColor: AppColors.periwinkle,
                      title: GestureDetector(
                          onTap: () => _showChapterTitleDialog(),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(chapterTitle,
                                    style: AppTextStyles.bold_18.copyWith(
                                        color: AppColors.black,
                                        overflow: TextOverflow.ellipsis)),
                              ),
                              if (book != null) WritePopUpMenu(book: book!),
                            ],
                          )),
                    )
                  : AppBar(
                      backgroundColor: AppColors.periwinkle,
                      automaticallyImplyLeading: false,
                      actions: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                  margin: const EdgeInsets.only(right: 16),
                                  child: book != null
                                      ? WritePopUpMenu(book: book!)
                                      : Container()),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 300,
                                child: AppQuillToolbar(
                                  controller: quillController,
                                  focusNode: editorFocusNode,
                                  topToolbar: true,
                                ),
                              ),
                              IconButton(
                                  onPressed: () => {
                                        toggleWritingStates(readBookState),
                                        _saveWriting(quillController),
                                      },
                                  icon: const Icon(Icons.check,
                                      color: AppColors.black)),
                            ],
                          )
                        ]),
              drawer: book != null && !isWriting
                  ? BookDrawer(
                      book: book!,
                      write: true,
                      onRenameBookTitle: _renameBookTitle,
                    )
                  : null,
              backgroundColor: isDarkMode ? AppColors.mystery : AppColors.white,
              body: SafeArea(
                child: MyQuillEditor(
                  quillKey: _quillKey,
                  context: context,
                ),
              ),
              floatingActionButton: !isWriting
                  ? FloatingActionButton(
                      backgroundColor: AppColors.periwinkle,
                      onPressed: () => toggleWritingStates(readBookState),
                      child: const Icon(Icons.edit, color: AppColors.black),
                    )
                  : null,
              bottomNavigationBar: isWriting
                  ? AppQuillToolbar(
                      controller: quillController,
                      focusNode: editorFocusNode,
                      topToolbar: false)
                  : null,
            );
    });
  }
}
