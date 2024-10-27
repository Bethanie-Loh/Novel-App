import 'package:flutter/material.dart';
import 'package:novel_app/data/model/book.dart';
import 'package:novel_app/screens/read/read_screen.dart';
import 'package:novel_app/screens/view_book.dart/view_book_screen.dart';
import 'package:novel_app/screens/write/write_screen.dart';
import 'package:novel_app/utils/app_colors.dart';
import 'package:novel_app/utils/app_loading.dart';
import 'package:novel_app/utils/app_text_styles.dart';
import 'package:go_router/go_router.dart';

class AppDisplayBooks extends StatelessWidget {
  final String sectionName;
  final Stream<List<Book>> books;
  final bool continueWriting;
  final bool viewBook;
  final bool isSaved;
  final String emptyMessage;

  const AppDisplayBooks({
    super.key,
    required this.sectionName,
    required this.books,
    required this.continueWriting,
    required this.viewBook,
    required this.isSaved,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    void navigateToWriteScreen(String bookId, int lastChapterId) {
      debugPrint(
          "Book Id in navigateToWriteScreen from display books: $bookId");
      try {
        if (bookId.isNotEmpty) {
          context.pushNamed(
            WriteScreen.route,
            pathParameters: {
              'bookId': bookId,
              'chapterId': lastChapterId.toString(),
            },
            extra: {'newBook': false},
          );
        } else {
          debugPrint("No book id to navigate to write screen");
        }
      } catch (e) {
        debugPrint(
            "Error in getting book id to navigate to write screen. Error: $e");
      }
    }

    void navigateToReadScreen(String bookId) {
      debugPrint("im sending this $bookId");
      context.pushNamed(
        ReadScreen.route,
        pathParameters: {'bookId': bookId, 'chapterId': '1'},
        extra: {'newReading': false},
      );
    }

    void navigateToViewBook(String bookId) {
      context.pushNamed(
        ViewBookScreen.route,
        pathParameters: {'bookId': bookId},
        extra: {'isSaved': false, 'isWriting': false},
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(
            sectionName,
            style: AppTextStyles.bold_18,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: StreamBuilder(
              stream: books,
              builder: (context, asyncData) {
                if (asyncData.connectionState == ConnectionState.waiting) {
                  return const Center(child: AppLoading());
                }

                if (asyncData.hasError) {
                  return const Center(
                    child: Text("Error fetching books",
                        style: AppTextStyles.italic_16),
                  );
                }

                if (!asyncData.hasData || asyncData.data!.isEmpty) {
                  return Center(
                    child: Text(emptyMessage, style: AppTextStyles.italic_16),
                  );
                }

                final books = asyncData.data!;
                return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: books.length,
                    itemBuilder: (context, index) => GestureDetector(
                        onTap: () {
                          int lastChapterIndex =
                              books[index].chapters.length - 1;
                          continueWriting
                              ? navigateToWriteScreen(books[index].id!,
                                  books[index].chapters[lastChapterIndex].id!)
                              : viewBook
                                  ? navigateToViewBook(books[index].id!)
                                  : navigateToReadScreen(books[index].id!);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          AppColors.periwinkle.withOpacity(0.3),
                                      blurRadius: 4,
                                      spreadRadius: 3,
                                      offset: const Offset(2, 3),
                                    ),
                                  ],
                                ),
                                child: SizedBox(
                                  width: 100,
                                  height: 150,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: books[index].cover != null &&
                                            books[index].cover!.isNotEmpty
                                        ? Image.network(
                                            books[index].cover!,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          )
                                        : Image.asset(
                                            "assets/images/sky.jpg",
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: 100,
                                child: SizedBox(
                                  child: Text(
                                    books[index].title ?? "Unknown Title",
                                    style: AppTextStyles.regular_12,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )));
              }),
        ),
      ],
    );
  }
}
