import 'package:flutter/material.dart';
import 'package:novel_app/data/model/book.dart';
import 'package:novel_app/data/repo/book_repo.dart';

class GlobalDataController {
  final _bookRepo = BookRepo();

  Future<Book?> getBookById(String id) async {
    try {
      debugPrint("Book id at global data controller: $id");
      if (id.isNotEmpty) {
        return await _bookRepo.getBookById(id);
      } else {
        debugPrint("There's no book id at global data controller");
        return null;
      }
    } catch (e) {
      debugPrint(
          "Error in getting book at getBookById at global data controller. Error: $e");
      return null;
    }
  }
}
