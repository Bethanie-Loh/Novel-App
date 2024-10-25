import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:novel_app/utils/app_colors.dart';
import 'package:novel_app/utils/app_text_styles.dart';

class AppQuillToolbar extends StatelessWidget {
  final QuillController controller;
  final FocusNode focusNode;
  final bool topToolbar;
  const AppQuillToolbar(
      {super.key,
      required this.controller,
      required this.focusNode,
      required this.topToolbar});

  @override
  Widget build(BuildContext context) {
    return topToolbar
        ? Container(
            decoration: BoxDecoration(
                border: Border.all(color: AppColors.white, width: 1),
                borderRadius: BorderRadius.circular(15)),
            child: QuillToolbar.simple(
                controller: controller,
                configurations: QuillSimpleToolbarConfigurations(
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(15)),
                    showBoldButton: false,
                    showItalicButton: false,
                    showUnderLineButton: false,
                    showStrikeThrough: false,
                    showSubscript: false,
                    showSuperscript: false,
                    showInlineCode: false,
                    showCodeBlock: false,
                    showColorButton: false,
                    showBackgroundColorButton: false,
                    showListBullets: false,
                    showListNumbers: false,
                    showListCheck: false,
                    showQuote: false,
                    showIndent: false,
                    showLink: false,
                    showSearchButton: false,
                    showClipboardCut: false,
                    showClipboardCopy: false,
                    showClipboardPaste: false,
                    color: AppColors.white,
                    dialogTheme: QuillDialogTheme(
                      buttonTextStyle: AppTextStyles.bold_14,
                      labelTextStyle: AppTextStyles.bold_14,
                      dialogBackgroundColor: AppColors.white,
                      inputTextStyle: AppTextStyles.bold_14,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    fontSizesValues: const {
                      '14': '14.0',
                      '16': '16.0',
                      '18': '18.0',
                      '20': '20.0',
                      '22': '22.0',
                      '24': '24.0',
                      '26': '26.0',
                      '28': '28.0',
                      '30': '30.0',
                      '35': '35.0',
                      '40': '40.0'
                    },
                    multiRowsDisplay: false,
                    buttonOptions: const QuillSimpleToolbarButtonOptions(
                        base: QuillToolbarBaseButtonOptions(
                            iconTheme: QuillIconTheme(
                          iconButtonSelectedData: IconButtonData(
                              color: AppColors.white,
                              style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(
                                      AppColors.periwinkle))),
                        )),
                        backgroundColor: QuillToolbarColorButtonOptions(
                          dialogBarrierColor: AppColors.mulberry,
                        )))))
        : Container(
            child: QuillToolbar.simple(
                controller: controller,
                configurations: const QuillSimpleToolbarConfigurations(
                    showUndo: false,
                    showRedo: false,
                    showFontFamily: false,
                    showClearFormat: false,
                    showFontSize: false,
                    showSubscript: false,
                    showSuperscript: false,
                    showStrikeThrough: false,
                    showInlineCode: false,
                    showCodeBlock: false,
                    showBackgroundColorButton: false,
                    showAlignmentButtons: true,
                    showHeaderStyle: false,
                    showLink: false,
                    showSearchButton: false,
                    showClipboardCut: false,
                    showClipboardCopy: false,
                    showClipboardPaste: false,
                    color: AppColors.periwinkle,
                    multiRowsDisplay: false,
                    buttonOptions: QuillSimpleToolbarButtonOptions(
                        base: QuillToolbarBaseButtonOptions(
                            iconTheme: QuillIconTheme(
                          iconButtonSelectedData: IconButtonData(
                              color: AppColors.white,
                              style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(
                                      AppColors.periwinkle))),
                        )),
                        backgroundColor: QuillToolbarColorButtonOptions(
                          dialogBarrierColor: AppColors.white,
                        )))));
  }
}
