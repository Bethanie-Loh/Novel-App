import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_app/constants/app_strings.dart';
import 'package:novel_app/controllers/global_data_controller.dart';
import 'package:novel_app/core/service/storage_service.dart';
import 'package:novel_app/data/genres.dart';
import 'package:novel_app/data/model/book.dart';
import 'package:novel_app/data/repo/book_repo.dart';
import 'package:novel_app/screens/edit_book/edit_book_controller.dart';
import 'package:novel_app/screens/tab_container_screen.dart';
import 'package:novel_app/utils/app_alert_dialog.dart';
import 'package:novel_app/utils/app_colors.dart';
import 'package:novel_app/utils/app_genre_picker.dart';
import 'package:novel_app/utils/app_loading.dart';
import 'package:novel_app/utils/app_text_field.dart';
import 'package:novel_app/utils/app_text_styles.dart';
import 'package:novel_app/utils/app_validator.dart';
import 'package:novel_app/widgets/app_appbar.dart';
import 'package:novel_app/widgets/app_drawer.dart';
import 'package:go_router/go_router.dart';

class EditBookScreen extends StatefulWidget {
  final String bookId;

  const EditBookScreen({super.key, required this.bookId});
  static const route = 'edit_book';
  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final _globalDataController = GlobalDataController();
  final _editBookController = EditBookController();
  final _bookRepo = BookRepo();
  final TextEditingController _bookTitleController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  List<String> _selectedGenres = [];
  Book? book;
  bool _isLoading = false;
  String? _imageUrl;

  void _init() {
    _fetchBook();
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  bool _isValidUrl(String url) {
    final Uri? uri = Uri.tryParse(url);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  Future<Book?> _fetchBook() async {
    try {
      final fetchedBook =
          await _globalDataController.getBookById(widget.bookId);

      debugPrint("fetchedBook: $fetchedBook");

      setState(() {
        book = fetchedBook;
        _imageUrl = book?.cover ?? "assets/images/sky.jpg";
        _bookTitleController.text = book?.title ?? "Unknown Title";
        _summaryController.text = book?.summary ?? "This book is about...";
        _selectedGenres = book?.genres ?? ["No genres"];
        debugPrint("book after fetched: $book");
        _isLoading = false;
      });

      return fetchedBook;
    } catch (e) {
      debugPrint('Error fetching book: $e');
      setState(() => _isLoading = false);
      return null;
    }
  }

  void _uploadBookCover(WidgetRef ref) async {
    final storageService = ref.read(storageProvider.notifier);
    String imageUrl = await storageService.uploadImage();

    if (mounted) {
      if (imageUrl != 'null') {
        _editBookController.updateCover(book!, imageUrl);
        setState(() => _imageUrl = imageUrl);

        AppValidator.showSnackBar(
            context, 'Image uploaded successfully', false);
      } else {
        AppValidator.showSnackBar(context, 'Image upload failed', true);
      }
    }
  }

  void _saveEditBook() async {
    String res = "";
    if (_bookTitleController.text.isEmpty) {
      AppValidator.showSnackBar(context, 'Please enter your book title', true);
      return;
    } else if (_summaryController.text.isEmpty) {
      AppValidator.showSnackBar(
          context, 'Please enter your book summary', true);
      return;
    } else if (_imageUrl!.isEmpty) {
      AppValidator.showSnackBar(context, 'Please choose your book cover', true);
      return;
    }

    res = await _editBookController.updateBook(book!, _bookTitleController.text,
        _imageUrl!, _selectedGenres, _summaryController.text, context);

    if (!mounted) return;
    if (res == AppStrings.success) {
      AppValidator.showSnackBar(context, '${book!.title} saved', false);
      context.pushNamed(TabContainerScreen.route);
    } else {
      AppValidator.showSnackBar(
          context, 'Failed to update book, please contact the app owner', true);
    }
  }

  void _deleteBook() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AppAlertDialog(
          title: 'Confirm Deletion',
          content: 'Are you sure you want to delete "${book!.title}"?',
          textOK: 'Delete',
          onOkPressed: () async {
            String? res;

            res = await _bookRepo.deleteBook(book!.id!);

            if (!context.mounted) return;

            if (res == AppStrings.success) {
              AppValidator.showSnackBar(
                  context, 'Goodbye ${book!.title}', false);
              Navigator.of(context).pop();
              context.pushNamed(TabContainerScreen.route);
            } else {
              AppValidator.showSnackBar(
                context,
                'Failed to delete the book, please contact the app owner',
                true,
              );
              Navigator.of(context).pop();
            }
          },
          onCancelPressed: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final isUploading = ref.watch(storageProvider).isUploading;
      return Scaffold(
        backgroundColor: AppColors.mystery,
        appBar: const AppAppbar(),
        drawer: const AppDrawer(),
        body: Container(
          child: _isLoading
              ? const Center(
                  child: AppLoading(),
                )
              : book == null
                  ? const Center(
                      child: Text('Book data is unavailable',
                          style: AppTextStyles.regular_16),
                    )
                  : SingleChildScrollView(
                      child: Container(
                        margin: const EdgeInsets.all(25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            const SizedBox(height: 10),
                            Center(
                              child: Container(
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
                                child: GestureDetector(
                                    onTap: () => _uploadBookCover(ref),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: isUploading
                                          ? const AppLoading()
                                          : _imageUrl == null ||
                                                  !_isValidUrl(_imageUrl!)
                                              ? Image.asset(
                                                  "assets/images/sky.jpg",
                                                  fit: BoxFit.cover,
                                                  width: 130,
                                                  height: 180,
                                                )
                                              : Image.network(
                                                  _imageUrl!,
                                                  fit: BoxFit.cover,
                                                  width: 130,
                                                  height: 180,
                                                ),
                                    )),
                              ),
                            ),
                            const SizedBox(height: 35),
                            AppTextfield(
                                hintText: "Book Title",
                                obscureText: false,
                                controller: _bookTitleController),
                            AppGenrePicker(
                              editBook: true,
                              genres: genresList,
                              selectedGenres: _selectedGenres,
                              onGenresSelected: (selectedGenres) {
                                setState(
                                    () => _selectedGenres = selectedGenres);
                              },
                            ),
                            AppTextfield(
                                hintText: "Book Summary",
                                longText: true,
                                obscureText: false,
                                controller: _summaryController),
                            const SizedBox(height: 20),
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  OutlinedButton(
                                      onPressed: () => _deleteBook(),
                                      style: ButtonStyle(
                                          padding: WidgetStateProperty.all(
                                              const EdgeInsets.symmetric(
                                                  horizontal: 25, vertical: 0)),
                                          side: const WidgetStatePropertyAll(
                                              BorderSide.none),
                                          backgroundColor:
                                              const WidgetStatePropertyAll(
                                                  AppColors.mulberry)),
                                      child: const Text("Delete Book",
                                          style: AppTextStyles.italic_bold_16)),
                                  const SizedBox(width: 30),
                                  OutlinedButton(
                                      onPressed: () => _saveEditBook(),
                                      style: ButtonStyle(
                                          padding: WidgetStateProperty.all(
                                              const EdgeInsets.symmetric(
                                                  horizontal: 25, vertical: 0)),
                                          side: const WidgetStatePropertyAll(
                                              BorderSide.none),
                                          backgroundColor:
                                              const WidgetStatePropertyAll(
                                                  AppColors.emerald)),
                                      child: const Text("Save Editing",
                                          style: AppTextStyles.italic_bold_16)),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
        ),
      );
    });
  }
}
