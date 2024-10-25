import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/quill_delta.dart';

class WriteBook {
  final QuillController quillController;
  final bool isWriting;
  final bool isDarkMode;
  final FocusNode editorFocusNode;
  final bool isGeminiAIShown;
  final bool enableGeminiAI;
  final int wordCount;
  final int charCount;
  final String bookTitle;
  final String chapterTitle;
  WriteBook({
    required this.quillController,
    required this.isWriting,
    required this.isDarkMode,
    required this.editorFocusNode,
    required this.enableGeminiAI,
    required this.isGeminiAIShown,
    required this.wordCount,
    required this.charCount,
    required this.bookTitle,
    required this.chapterTitle,
  });

  WriteBook copyWith({
    QuillController? quillController,
    bool? isWriting,
    bool? isDarkMode,
    FocusNode? editorFocusNode,
    bool? enableGeminiAI,
    bool? isGeminiAIShown,
    int? wordCount,
    int? charCount,
    String? bookTitle,
    String? chapterTitle,
  }) {
    return WriteBook(
      quillController: quillController ?? this.quillController,
      isWriting: isWriting ?? this.isWriting,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      editorFocusNode: editorFocusNode ?? this.editorFocusNode,
      enableGeminiAI: enableGeminiAI ?? this.enableGeminiAI,
      isGeminiAIShown: isGeminiAIShown ?? this.isGeminiAIShown,
      wordCount: wordCount ?? this.wordCount,
      charCount: charCount ?? this.charCount,
      bookTitle: bookTitle ?? this.bookTitle,
      chapterTitle: chapterTitle ?? this.chapterTitle,
    );
  }
}

class WriteBookNotifier extends StateNotifier<WriteBook> {
  WriteBookNotifier()
      : super(WriteBook(
          quillController: QuillController.basic(),
          isWriting: false,
          isDarkMode: true,
          editorFocusNode: FocusNode(),
          enableGeminiAI: false,
          isGeminiAIShown: false,
          wordCount: 0,
          charCount: 0,
          bookTitle: "Untitled Book",
          chapterTitle: "Untitled Chapter",
        )) {
    state.editorFocusNode.unfocus();
    state.quillController.document.changes.listen((event) {
      _updateWordAndCharCount();
    });
  }

  // Getter for bookTitle
  String get bookTitle => state.bookTitle;

  // Getter for chapterTitle
  String get chapterTitle => state.chapterTitle;
  // void updateBook(Book updatedBook) {
  //   state = state.copyWith(book: updatedBook);
  //   debugPrint("Updated book: ${state.book}");
  // }

  void toggleDarkMode() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
    debugPrint("isDarkMode from provider: ${state.isDarkMode}");
  }

  void toggleWritingMode() {
    state = state.copyWith(isWriting: !state.isWriting);
    debugPrint("isWriting from provider: ${state.isWriting}");
  }

  void toggleGeminiAI() {
    state = state.copyWith(enableGeminiAI: !state.enableGeminiAI);
    debugPrint("enableGeminiAI from provider: ${state.enableGeminiAI}");
  }

  void setGeminiAIShown(bool isShown) {
    state = state.copyWith(isGeminiAIShown: isShown);
    debugPrint("isGeminiAIShown from provider: ${state.isGeminiAIShown}");
  }

  void toggleEditorFocusNode() {
    debugPrint(
        "%%%%%%%%%state.editorFocusNode.hasFocus: ${state.editorFocusNode.hasFocus}");
    if (!state.isWriting) {
      state.editorFocusNode.unfocus();
    } else {
      state.editorFocusNode.requestFocus();
    }

    state = state.copyWith(editorFocusNode: state.editorFocusNode);
  }

  void toggleQuillController() {
    state.quillController.readOnly = !state.quillController.readOnly;
    state = state.copyWith();
  }

  void updateQuillDocument(Delta content) {
    final newDocument = Document.fromDelta(content);

    state = state.copyWith(
      quillController: QuillController(
        document: newDocument,
        selection: TextSelection.collapsed(offset: newDocument.length),
      ),
    );

    _updateWordAndCharCount();
  }

  void _updateWordAndCharCount() {
    final text = state.quillController.document.toPlainText();

    final wordCount = _calculateWordCount(text);
    final charCount = text.length;

    state = state.copyWith(wordCount: wordCount, charCount: charCount);

    debugPrint("Word count: $wordCount, Char count: $charCount");
  }

  int _calculateWordCount(String text) {
    final words = text.trim().split(RegExp(r'\s+'));
    return words.isEmpty ? 0 : words.length;
  }

  void updateBookTitle(String title) {
    state = state.copyWith(bookTitle: title);
    debugPrint("Updated bookTitle: ${state.bookTitle}");
  }

  void updateChapterTitle(String title) {
    state = state.copyWith(chapterTitle: title);
    debugPrint("Updated chapterTitle: ${state.chapterTitle}");
  }

  void reset() {
    state.quillController.clear();
    state.editorFocusNode.unfocus();

    state = WriteBook(
      quillController: QuillController.basic(),
      isWriting: false,
      isDarkMode: true,
      editorFocusNode: FocusNode(),
      enableGeminiAI: false,
      isGeminiAIShown: false,
      wordCount: 0,
      charCount: 0,
      bookTitle: "Untitled Book",
      chapterTitle: "Untitled Chapter",
    );

    debugPrint("All values reset to default.");
  }
}

final writeBookNotifierProvider =
    StateNotifierProvider<WriteBookNotifier, WriteBook>((ref) {
  return WriteBookNotifier();
});
