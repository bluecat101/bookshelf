import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:http/http.dart' as http;

class NdlBook {
  final String title;
  final String author;
  final String link;
  final int isbn;

  const NdlBook({
    required this.title,
    required this.author,
    required this.link,
    required this.isbn,
  });
}

List<NdlBook> parseNdlBooks(String xmlString, String searchedTitle) {
  final document = XmlDocument.parse(xmlString);
  final items = document.findAllElements('item');
  final List<NdlBook> ndlBooks = [];
  for (final item in items) {
    final category =
        item.getElement('category')?.innerText == '図書'
            ? '図書'
            : null; // 図書であるかを判定する用
    final title = item.getElement('title')?.innerText;
    final author = item.getElement('author')?.innerText;
    final link = item.getElement('link')?.innerText;
    if (category == null ||
        title == null ||
        searchedTitle.contains(title) ||
        author == null ||
        link == null) {
      continue;
    }

    final identifiers = item.findElements('dc:identifier');
    debugPrint('identifiers: $identifiers');
    int? isbn;

    for (final id in identifiers) {
      final typeAttr = id.getAttribute('xsi:type');
      debugPrint(typeAttr);
      if (typeAttr == 'dcndl:ISBN') {
        final isbnStr = id.innerText;
        debugPrint('isbn: $isbnStr');
        isbn = int.tryParse(isbnStr.replaceAll('-', ''));
        break;
      }
    }

    if (isbn != null) {
      ndlBooks.add(
        NdlBook(title: title, author: author, link: link, isbn: isbn),
      );
    }
  }

  return ndlBooks;
}

void parseBooksThroughNationalDietLibrary(String responseBody) {}

Future<List<NdlBook>> fetchBookInfoThroughNationalDietLibrary(
  String title,
) async {
  final encodedTitle = Uri.encodeFull(title);
  final url =
      'https://ndlsearch.ndl.go.jp/api/opensearch?cnt=100&title=$encodedTitle';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    return parseNdlBooks(response.body, title);
  } else {
    throw Exception('Failed to fetch data');
  }
}
