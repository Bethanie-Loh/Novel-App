import 'package:flutter/material.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:novel_app/controllers/global_data_controller.dart';
import 'package:novel_app/data/model/book.dart';
import 'package:novel_app/data/model/chapter.dart';
import 'package:novel_app/provider/write_book_provider.dart';
import 'package:novel_app/screens/view_book.dart/view_book_screen.dart';
import 'package:novel_app/utils/app_colors.dart';
import 'package:novel_app/utils/app_loading.dart';
import 'package:novel_app/utils/app_text_styles.dart';
import 'package:novel_app/utils/delta_to_html_converter.dart';
import 'package:novel_app/widgets/book_drawer.dart';
import 'package:go_router/go_router.dart';

class ReadScreen extends ConsumerStatefulWidget {
  final String bookId;
  final int chapterId;
  final bool clickFromHome;

  const ReadScreen({
    required this.bookId,
    required this.chapterId,
    required this.clickFromHome,
    super.key,
  });

  static const route = "Read";

  @override
  ConsumerState<ReadScreen> createState() => _ReadScreenState();
}

class _ReadScreenState extends ConsumerState<ReadScreen> {
  Book? _book;
  bool _isLoading = false;
  final _globalDataController = GlobalDataController();

  void _init() async {
    await _fetchBook();
    _updateBookStates();
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  void _updateBookStates() {
    if (_book != null) {
      final notifier = ref.read(writeBookNotifierProvider.notifier);

      notifier.updateBookTitle(_book!.title ?? "Couldn't get book title");

      Chapter? currentChapter = _book!.chapters
          .firstWhere((chapter) => chapter.id == widget.chapterId);

      notifier.updateChapterTitle(currentChapter.title);
      Delta content = currentChapter.content;
      notifier.updateQuillDocument(content);
    }
  }

  Future<Book?> _fetchBook() async {
    setState(() => _isLoading = true);
    try {
      final fetchedBook =
          await _globalDataController.getBookById(widget.bookId);

      debugPrint("fetchedBook: $fetchedBook");

      setState(() {
        _book = fetchedBook;
        debugPrint("book after fetched: $_book");

        _isLoading = false;
      });

      return fetchedBook;
    } catch (e, stacktrace) {
      debugPrint('Error fetching book: $e');
      debugPrint('Stacktrace: $stacktrace');
      setState(() => _isLoading = false);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final watchBookState = ref.watch(writeBookNotifierProvider);
      final notifier = ref.read(writeBookNotifierProvider.notifier);
      final chapterTitle = watchBookState.chapterTitle;
      // final quillController = watchBookState.quillController;
      // final editorFocusNode = watchBookState.editorFocusNode;
      final isDarkMode = watchBookState.isDarkMode;
      final wordCount = watchBookState.wordCount;
      final charCount = watchBookState.charCount;

      return Scaffold(
        appBar: AppBar(
          title: Text(chapterTitle,
              style: AppTextStyles.bold_18.copyWith(
                  color: AppColors.black, overflow: TextOverflow.ellipsis)),
          backgroundColor: AppColors.periwinkle,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: PopupMenuButton(
                  color: AppColors.periwinkle,
                  child: const Icon(Icons.more_vert, color: AppColors.black),
                  onSelected: (value) {
                    if (value == 'About Book') {
                      context.pushNamed(
                        ViewBookScreen.route,
                        pathParameters: {'bookId': _book!.id!},
                        extra: {
                          'isAuthor': false,
                          'isSaved': true,
                          'isWriting': false
                        },
                      );
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
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
                                        notifier.toggleDarkMode())
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
                      const PopupMenuItem<String>(
                        value: 'About Book',
                        child: Text(
                          'About Book',
                          style: AppTextStyles.bold_14,
                        ),
                      ),
                    ];
                  }),
            )
          ],
        ),
        drawer: BookDrawer(book: _book, write: false),
        backgroundColor: isDarkMode ? AppColors.mystery : AppColors.white,
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(30),
                child: _isLoading
                    ? const AppLoading()
                    : _book != null
                        ? SingleChildScrollView(
                            child: DefaultTextStyle(
                              style: TextStyle(
                                color: isDarkMode
                                    ? AppColors.white
                                    : AppColors.mystery,
                              ),
                              child: HtmlWidget(
                                DeltaToHtmlConverter.extractFormattedText(_book!
                                    .chapters
                                    .firstWhere((chapter) =>
                                        chapter.id == widget.chapterId)
                                    .content),
                              ),
                            ),
                          )
                        : const Text('No content to display'))),
      );
    });
  }
}
