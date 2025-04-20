import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class BookDTO {
  final String? title;
  final String? author;
  final int? page;
  final double? height;
  final double? width;
  final int? isbn;
  final String? thumbnailUrl;

  const BookDTO({
    this.title,
    this.author,
    this.page,
    this.height,
    this.width,
    this.isbn,
    this.thumbnailUrl,
  });
}

List<BookDTO> parseBooksThroughGoogle(String responseBody) {
  List<BookDTO> books = [];
  final parsedData = jsonDecode(responseBody);
  final items = parsedData['items'];
  items.forEach((item) {
    try {
      final volumeInfo = item['volumeInfo'] as Map<String, dynamic>?;
      if (volumeInfo == null) return;

      final identifiers = volumeInfo['industryIdentifiers'] as List<dynamic>?;
      if (identifiers == null) return;

      final isbn10Entry = identifiers
          .whereType<Map<String, dynamic>>()
          .firstWhere((id) => id['type'] == 'ISBN_10', orElse: () => {});
      final isbnStr = isbn10Entry['identifier'];
      if (isbnStr == null) return;

      final title = volumeInfo['title'] as String;
      final authors = volumeInfo['authors'] as List<dynamic>;
      final pageCount = volumeInfo['pageCount'];
      final imageLinks = volumeInfo['imageLinks'] as Map<String, dynamic>;
      final thumbnail = imageLinks['thumbnail'];

      books.add(
        BookDTO(
          title: title,
          author: authors.first.toString(),
          page: int.parse(pageCount.toString()),
          isbn: int.parse(isbnStr.toString()),
          thumbnailUrl: thumbnail?.toString(),
        ),
      );
    } catch (_) {}
  });
  return books;
}

Future<List<BookDTO>> fetchBookThroughGoogle(String bookTitle) async {
  final response = await http.Client().get(
    Uri.parse('https://www.googleapis.com/books/v1/volumes?q=$bookTitle'),
  );
  return parseBooksThroughGoogle(response.body);
}
