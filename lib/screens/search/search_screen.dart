import 'package:flutter/material.dart';
import 'package:novel_app/controllers/books_controller.dart';
import 'package:novel_app/data/model/book.dart';
import 'package:novel_app/screens/view_book.dart/view_book_screen.dart';
import 'package:novel_app/utils/app_colors.dart';
import 'package:novel_app/utils/app_loading.dart';
import 'package:novel_app/utils/app_text_field.dart';
import 'package:novel_app/utils/app_text_styles.dart';
import 'package:novel_app/widgets/app_display_books.dart';
import 'package:go_router/go_router.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final BooksController _booksController = BooksController();

  late Stream<List<Book>> _latestBooks;
  late Stream<List<Book>> _popularBooks;
  bool _isLoading = true;

  List<Book> _filteredBooks = [];
  bool _isSearching = false;

  @override
  void initState() {
    _init();
    super.initState();
  }

  void _init() {
    _handleSearch();
    _fetchBooks();
  }

  void _fetchBooks() async {
    setState(() => _isLoading = true);

    try {
      setState(() {
        _latestBooks = _booksController.getLatestBooks();
        _popularBooks = _booksController.getPopularBooks();
      });
    } catch (e) {
      debugPrint("Error fetching latest books and popular books: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleSearch() {
    _searchController.addListener(() async {
      final query = _searchController.text;
      if (query.isNotEmpty) {
        final results = await _booksController.getSearchedBooks(query);
        setState(() {
          _filteredBooks = results;
          _isSearching = true;
        });
      } else {
        setState(() {
          _filteredBooks = [];
          _isSearching = false;
        });
      }
    });
  }

  void _navigateToViewBook(String bookId) {
    context.pushNamed(
      ViewBookScreen.route,
      pathParameters: {'bookId': bookId},
      extra: {'isAuthor': false, 'isSaved': false, 'isWriting': false},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mystery,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Center(
                child: Text("Discover", style: AppTextStyles.bold_white_20)),
            const SizedBox(height: 20),
            AppTextfield(
                hintText: "Search by title, author, genres",
                obscureText: false,
                controller: _searchController),
            const SizedBox(height: 20),
            if (_isSearching && _filteredBooks.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredBooks.length,
                itemBuilder: (context, index) {
                  final book = _filteredBooks[index];
                  return Card(
                    elevation: 5,
                    color: AppColors.periwinkle.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                        selectedTileColor: AppColors.periwinkle,
                        title: Text(book.title ?? "Unknown Title",
                            style: AppTextStyles.bold_16),
                        subtitle: Text(book.author ?? "Unknown Author",
                            style: AppTextStyles.italic_14),
                        onTap: () => _navigateToViewBook(book.id!)),
                  );
                },
              ),
            const SizedBox(height: 40),
            _isLoading
                ? const AppLoading()
                : AppDisplayBooks(
                    sectionName: "Latest Books",
                    books: _latestBooks,
                    isSaved: false,
                    viewBook: true,
                    continueWriting: false,
                    emptyMessage: "No one has posted any new books lately",
                  ),
            const SizedBox(height: 20),
            AppDisplayBooks(
              sectionName: "Popular Books",
              books: _popularBooks,
              viewBook: true,
              isSaved: false,
              continueWriting: false,
              emptyMessage: "No one has liked any books yet",
            ),
          ],
        ),
      ),
    );
  }
}
