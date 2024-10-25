import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_app/data/model/book.dart';
import 'package:novel_app/provider/write_book_provider.dart';
import 'package:novel_app/screens/read/read_screen.dart';
import 'package:novel_app/screens/write/write_screen.dart';
import 'package:novel_app/utils/app_colors.dart';
import 'package:novel_app/utils/app_text_styles.dart';
import 'package:go_router/go_router.dart';

class BookDrawer extends StatelessWidget {
  final Book? book;
  final bool write;
  final VoidCallback? onRenameBookTitle;

  const BookDrawer(
      {super.key, this.book, required this.write, this.onRenameBookTitle});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final watchBookState = ref.watch(writeBookNotifierProvider);
      final bookTitle = watchBookState.bookTitle;
      final chapterTitle = watchBookState.chapterTitle;

      return Drawer(
        backgroundColor: AppColors.periwinkle,
        child: Column(
          children: [
            DrawerHeader(
              child: write
                  ? Center(
                      child: GestureDetector(
                        onTap: () => onRenameBookTitle,
                        child: SizedBox(
                          width: double.infinity,
                          child: Text(
                            bookTitle,
                            style: AppTextStyles.bold_24,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Flexible(
                        child: Text(
                          bookTitle,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bold_24,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                        ),
                      ),
                    ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: book!.chapters.length,
              itemBuilder: (context, index) {
                return ListTile(
                  selectedTileColor: AppColors.mulberry,
                  selectedColor: AppColors.white,
                  title: Text(
                    book!.chapters[index].title,
                    style: AppTextStyles.bold_20,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                  onTap: () {
                    debugPrint("CURRENT INDEX: $index");
                    debugPrint(
                        "CURRENT CHAPTER ID INSIDE DRAWER: ${book!.chapters[index].id}");
                    Navigator.popUntil(context, (route) => route.isFirst);
                    write
                        ? context.pushNamed(WriteScreen.route, pathParameters: {
                            'bookId': book!.id!,
                            'chapterId': book!.chapters[index].id.toString()
                          }, extra: {
                            'chapterTitle': chapterTitle,
                          })
                        : context.pushNamed(
                            ReadScreen.route,
                            pathParameters: {
                              'bookId': book!.id!,
                              'chapterId': book!.chapters[index].id.toString()
                            },
                            extra: {'newReading': false},
                          );
                  },
                );
              },
            ),
          ],
        ),
      );
    });
  }
}
