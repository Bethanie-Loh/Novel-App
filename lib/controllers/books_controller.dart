import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:novel_app/core/service/auth_service.dart';
import 'package:novel_app/data/model/book.dart';
import 'package:novel_app/data/model/user.dart';
import 'package:novel_app/data/repo/book_repo.dart';
import 'package:novel_app/data/repo/user_repo.dart';
import 'package:novel_app/utils/app_date.dart';

class BooksController {
  final AuthService authService = AuthService();
  final _bookRepo = BookRepo();
  final _userRepo = UserRepo();
  String? _userName;

  BooksController() {
    fetchUserName();
  }

  void fetchUserName() {
    _userRepo.getUserStream().listen((user) {
      debugPrint("User at fetchUserName: $user");
      if (user != null) {
        _userName = user.name;
      } else {
        _userName = 'User not found';
      }
    });
  }

  Stream<List<Book>> getBooks() => _bookRepo.getBooks();

  Future<List<Book>> getSearchedBooks(String query) async {
    try {
      final allBooks = await _bookRepo.getBooks().first;
      final lowerCaseQuery = query.toLowerCase();

      return allBooks.where((book) {
        return book.isPublished == true &&
                (book.title?.toLowerCase().contains(lowerCaseQuery) ?? false) ||
            (book.author?.toLowerCase().contains(lowerCaseQuery) ?? false) ||
            (book.genres?.any(
                    (genre) => genre.toLowerCase().contains(lowerCaseQuery)) ??
                false);
      }).toList();
    } catch (e) {
      debugPrint('Error in searching books: $e');
      return [];
    }
  }

  Stream<List<Book>> getIncompleteBooks() async* {
    debugPrint("_userName at getIncompleteBooks: $_userName");
    try {
      yield* getBooks().asyncMap((books) {
        return books
            .where(
                (book) => book.isPublished == false && book.author == _userName)
            .toList();
      });
    } catch (e) {
      debugPrint('Error in getting incomplete books: $e');
      yield [];
    }
  }

  Stream<List<Book>> getSavedBooks() async* {
    final String? userId = authService.getUid();

    try {
      if (userId == null) {
        yield [];
        return;
      }

      yield* getBooks().asyncMap((books) {
        return books
            .where((book) =>
                book.savedUserIds?.contains(userId) == true &&
                book.isPublished == true)
            .toList();
      });
    } catch (e) {
      debugPrint('Error in getting saved books: $e');
      yield [];
    }
  }

  Stream<List<Book>> getFavouriteGenreBooks() async* {
    final String? userId = authService.getUid();

    try {
      if (userId == null) {
        yield [];
        return;
      }

      final AppUser? user = await _userRepo.getUserById(userId);
      if (user == null) {
        yield [];
        return;
      }
      final List<String> favouriteGenres = user.favouriteGenres;

      yield* getBooks().asyncMap((books) {
        return books
            .where((book) =>
                book.isPublished == true &&
                book.genres?.any((genre) => favouriteGenres.contains(genre)) ==
                    true)
            .toList();
      });
    } catch (e) {
      debugPrint('Error in getting favourite genre books: $e');
      yield [];
    }
  }

  //YOUR BOOKS PAGE
  Stream<List<Book>> getYourPublishedBooks() async* {
    try {
      yield* getBooks().asyncMap((books) {
        return books
            .where(
                (book) => book.isPublished == true && book.author == _userName)
            .toList();
      });
    } catch (e) {
      debugPrint('Error in getting published books: $e');
      yield [];
    }
  }

//LIBRARY PAGE
  Stream<List<Book>> getUnfinishedReadingBooks() async* {
    final String? userId = authService.getUid();

    try {
      if (userId == null) {
        yield [];
        return;
      }

      yield* getBooks().asyncMap((books) {
        return books
            .where((book) =>
                book.savedUserIds?.contains(userId) == true &&
                (book.savedUsersFinishedReading?.contains(userId) != true) &&
                book.isPublished == true)
            .toList();
      });
    } catch (e) {
      debugPrint('Error in getting unfinished reading books: $e');
      yield [];
    }
  }

  Stream<List<Book>> getFinishedReadingBooks() async* {
    final String? userId = authService.getUid();

    try {
      if (userId == null) {
        yield [];
        return;
      }

      yield* getBooks().asyncMap((books) {
        return books
            .where((book) =>
                book.savedUserIds?.contains(userId) == true &&
                book.savedUsersFinishedReading?.contains(userId) == true &&
                book.isPublished == true)
            .toList();
      });
    } catch (e) {
      debugPrint('Error in getting finished reading books: $e');
      yield [];
    }
  }

//SEARCH PAGE
  Stream<List<Book>> getLatestBooks() async* {
    try {
      yield* getBooks().asyncMap((books) {
        final DateTime now = DateTime.now();
        final DateTime oneWeekAgo = now.subtract(const Duration(days: 7));

        return books.where((book) {
          DateTimeResult result = AppDate().parseDateTime(book.datePublished);

          return book.isPublished == true &&
              result.date != null &&
              result.date!.isAfter(oneWeekAgo) &&
              result.date!.isBefore(now);
        }).toList();
      });
    } catch (e) {
      debugPrint('Error in getting latest books: $e');
      yield [];
    }
  }

  Stream<List<Book>> getPopularBooks() async* {
    try {
      yield* getBooks().asyncMap((books) {
        books.sort((a, b) => (b.likedUserIds?.length ?? 0)
            .compareTo(a.likedUserIds?.length ?? 0));
        return books
            .where((book) => book.isPublished == true)
            .take(10)
            .toList();
      });
    } catch (e) {
      debugPrint('Error in getting popular books: $e');
      yield [];
    }
  }
}
