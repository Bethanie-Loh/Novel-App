import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_app/provider/write_book_provider.dart';
import 'package:novel_app/screens/write/gemini.dart';
import 'package:novel_app/utils/app_colors.dart';
import 'package:novel_app/utils/app_loading.dart';
import 'package:novel_app/utils/app_text_field.dart';
import 'package:novel_app/utils/app_text_styles.dart';

class MyQuillEditor extends ConsumerStatefulWidget {
  final GlobalKey quillKey;
  final BuildContext context;

  const MyQuillEditor({
    super.key,
    required this.quillKey,
    required this.context,
  });

  @override
  ConsumerState<MyQuillEditor> createState() => _MyQuillEditorState();
}

class _MyQuillEditorState extends ConsumerState<MyQuillEditor> {
  TextEditingController queryController = TextEditingController();

  bool _isLoading = false;

  void _updateQuillWithGeminiResponse(String response) {
    final quillController = ref.read(writeBookNotifierProvider).quillController;
    final documentLength = quillController.document.length;
    final newDelta = Delta()
      ..insert(response)
      ..insert('\n');

    quillController.compose(newDelta,
        TextSelection.collapsed(offset: documentLength), ChangeSource.local);
  }

  void _submitQuery() async {
    debugPrint("before isLoading at _submitQuery: $_isLoading");
    setState(() => _isLoading = true);
    debugPrint("after isLoading at _submitQuery: $_isLoading");
    setState(() {});
    String query = queryController.text;
    final gemini = Gemini();
    String response = await gemini.getGeminiResponse(query);
    setState(() => _isLoading = false);

    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              "Gemini AI Response",
              style: AppTextStyles.bold_20,
            ),
            content: SingleChildScrollView(
              child: Text(
                response,
                style: AppTextStyles.italic_bold_16
                    .copyWith(color: AppColors.black),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  setState(() => _isLoading = true);

                  await gemini.getGeminiResponse(query);
                  setState(() => _isLoading = false);

                  _submitQuery();
                },
                child: Text(
                  'Regenerate',
                  style: AppTextStyles.italic_bold_16.copyWith(
                    color: AppColors.mulberry,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, 'OK');
                  _updateQuillWithGeminiResponse(response);
                  Navigator.pop(context);
                },
                child: Text(
                  'OK',
                  style: AppTextStyles.italic_bold_16.copyWith(
                    color: AppColors.mulberry,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  Widget buildGeminiChat() {
    return Container(
      height: 220,
      padding: const EdgeInsets.only(right: 20, left: 20, top: 20),
      decoration: const BoxDecoration(
        color: AppColors.mulberry,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
          bottomLeft: Radius.zero,
          bottomRight: Radius.zero,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Ask Gemini AI anything",
              style: AppTextStyles.italic_bold_16),
          const SizedBox(height: 15),
          _isLoading
              ? const Center(child: AppLoading())
              : AppTextfield(
                  hintText: "Help me write...",
                  obscureText: false,
                  controller: queryController,
                  longText: true,
                  geminiAI: true,
                ),
          Center(
            child: OutlinedButton(
                onPressed: () => _submitQuery(),
                style: ButtonStyle(
                    padding: WidgetStateProperty.all(const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 0)),
                    side: const WidgetStatePropertyAll(BorderSide.none),
                    backgroundColor:
                        const WidgetStatePropertyAll(AppColors.periwinkle)),
                child: Text("Ask Gemini",
                    style: AppTextStyles.italic_bold_14
                        .copyWith(color: AppColors.black))),
          ),
        ],
      ),
    );
  }

  void showBottomPopup() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => buildGeminiChat(),
      backgroundColor: AppColors.periwinkle,
    ).then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(writeBookNotifierProvider.notifier).toggleGeminiAI();
        ref.read(writeBookNotifierProvider.notifier).setGeminiAIShown(false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final writeBookState = ref.watch(writeBookNotifierProvider);
      final isDarkMode = writeBookState.isDarkMode;
      final isWriting = writeBookState.isWriting;
      final quillController = writeBookState.quillController;
      final editorFocusNode = writeBookState.editorFocusNode;
      final enableGeminiAI = writeBookState.enableGeminiAI;
      final isGeminiAIShown = writeBookState.isGeminiAIShown;

      debugPrint(
          "enableGeminiAI: $enableGeminiAI, isGeminiAIShown: $isGeminiAIShown");

      if (enableGeminiAI && !isGeminiAIShown) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showBottomPopup();
          ref.read(writeBookNotifierProvider.notifier).setGeminiAIShown(true);
        });
      }

      return Expanded(
        child: Builder(
          builder: (context) {
            return Container(
              padding: const EdgeInsets.all(30),
              color: isDarkMode ? AppColors.mystery : AppColors.white,
              child: DefaultTextStyle(
                  style: TextStyle(
                    color: isDarkMode ? AppColors.white : AppColors.mystery,
                  ),
                  child: SizedBox(
                    key: widget.quillKey,
                    height: double.infinity,
                    child: Column(
                      children: [
                        Expanded(
                          child: QuillEditor.basic(
                            controller: quillController,
                            focusNode: editorFocusNode,
                            configurations: isWriting
                                ? QuillEditorConfigurations(
                                    placeholder: "Start writing...",
                                    textSelectionThemeData:
                                        TextSelectionThemeData(
                                      cursorColor: AppColors.periwinkle,
                                      selectionColor:
                                          AppColors.periwinkle.withOpacity(0.5),
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                  )),
            );
          },
        ),
      );
    });
  }
}
