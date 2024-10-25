import 'package:flutter_quill/quill_delta.dart';

class Chapter {
  int? id;
  final String title;
  final Delta content;
  final int totalPages;

  Chapter(
      {this.id,
      required this.title,
      required this.content,
      required this.totalPages});

  factory Chapter.fromMap(Map<String, dynamic> chapter) {
    return Chapter(
      id: chapter['id'] as int?,
      title: chapter['title'] as String,
      content: Delta.fromJson(chapter['content']),
      totalPages: chapter['totalPages'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content.toJson(),
      'totalPages': totalPages,
    };
  }

  Chapter copyWith({
    int? id,
    String? title,
    Delta? content,
    int? totalPages,
  }) {
    return Chapter(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  @override
  String toString() {
    return 'Chapter(id: $id, title: $title, content: $content, totalPages: $totalPages)';
  }
}
