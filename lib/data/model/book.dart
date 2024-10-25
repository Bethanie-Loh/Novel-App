import 'package:novel_app/data/model/chapter.dart';
import 'package:novel_app/data/model/review.dart';

class Book {
  String? id; // Core book information
  final String? title;
  final String? author;
  final String? summary;
  final String? cover;
  final List<String>? genres;

  final List<Chapter> chapters; // Content details
  final int totalPages;

  final List<String>? likedUserIds; // User interaction
  final List<Review>? reviews;
  final List<String>? savedUserIds;
  final List<String>? savedUsersFinishedReading;

  final String? dateBookCreated; // Publishing and status
  final String? datePublished;
  bool isPublished = false;

  Book({
    this.id,
    this.title,
    this.author,
    this.summary,
    this.cover,
    this.genres,
    required this.chapters,
    required this.totalPages,
    this.likedUserIds,
    this.reviews,
    this.savedUserIds,
    this.savedUsersFinishedReading,
    this.dateBookCreated,
    this.datePublished,
    required this.isPublished,
  });

  factory Book.fromMap(Map<String, dynamic> book) {
    return Book(
        id: book['id'] as String?,
        title: book['title'] as String?,
        author: book['author'] as String?,
        summary: book['summary'] as String?,
        cover: book['cover'] as String?,
        genres: book['genres'] != null
            ? List<String>.from(book['genres'] as List)
            : [],
        chapters: book['chapters'] != null
            ? (book['chapters'] as List)
                .map((chapterMap) => Chapter.fromMap(chapterMap))
                .toList()
            : [],
        totalPages: book['totalPages'] != null
            ? int.tryParse(book['totalPages'].toString()) ?? 0
            : 0,
        likedUserIds: book['likedUserIds'] != null
            ? List<String>.from(book['likedUserIds'] as List)
            : [],
        reviews: book['reviews'] != null
            ? (book['reviews'] as List)
                .map((reviewMap) => Review.fromMap(reviewMap))
                .toList()
            : [],
        savedUserIds: book['savedUserIds'] != null
            ? List<String>.from(book['savedUserIds'] as List)
            : [],
        savedUsersFinishedReading: book['savedUsersFinishedReading'] != null
            ? List<String>.from(book['savedUsersFinishedReading'] as List)
            : [],
        dateBookCreated: book['dateBookCreated'] as String?,
        datePublished: book['datePublished'] as String?,
        isPublished: book['isPublished'] as bool);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'summary': summary,
      'cover': cover,
      'genres': genres,
      'chapters': chapters.map((chapter) => chapter.toMap()).toList(),
      'totalPages': totalPages,
      'likedUserIds': likedUserIds,
      'reviews': reviews?.map((review) => review.toMap()).toList(),
      'savedUserIds': savedUserIds,
      'savedUsersFinishedReading': savedUsersFinishedReading,
      'dateBookCreated': dateBookCreated,
      'datePublished': datePublished,
      'isPublished': isPublished,
    };
  }

  @override
  String toString() {
    return 'Book{id: $id, title: $title, author: $author, summary: $summary, cover: $cover, genres: $genres, chapters: $chapters, totalPages: $totalPages, likedUserIds: $likedUserIds, reviews: $reviews, saved: $savedUserIds, savedUsersFinishedReading: $savedUsersFinishedReading, dateBookCreated: $dateBookCreated, datePublished: $datePublished, isPublished: $isPublished,}';
  }

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? summary,
    String? cover,
    List<String>? genres,
    List<Chapter>? chapters,
    int? totalPages,
    List<String>? likedUserIds,
    List<Review>? reviews,
    List<String>? savedUserIds,
    List<String>? savedUsersFinishedReading,
    String? dateBookCreated,
    String? datePublished,
    bool? isPublished,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      summary: summary ?? this.summary,
      cover: cover ?? this.cover,
      genres: genres ?? this.genres,
      chapters: chapters ?? this.chapters,
      totalPages: totalPages ?? this.totalPages,
      likedUserIds: likedUserIds ?? this.likedUserIds,
      reviews: reviews ?? this.reviews,
      savedUserIds: savedUserIds ?? this.savedUserIds,
      savedUsersFinishedReading:
          savedUsersFinishedReading ?? this.savedUsersFinishedReading,
      dateBookCreated: dateBookCreated ?? this.dateBookCreated,
      datePublished: datePublished ?? this.datePublished,
      isPublished: isPublished ?? this.isPublished,
    );
  }
}
