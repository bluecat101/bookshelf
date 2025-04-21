import 'package:xml/xml.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

const bookSize = {
  15: {"width": 8},
  19: {"width": 13},
  21: {"width": 15},
  23: {"width": 15},
  24: {"width": 16},
  30: {"width": 21},
};

class NdlBook {
  final String title;
  final String author;
  final String link;
  final String imageUrl;

  const NdlBook({
    required this.title,
    required this.author,
    required this.link,
    required this.imageUrl,
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
    String? imageUrl;

    for (final id in identifiers) {
      final typeAttr = id.getAttribute('xsi:type');
      if (typeAttr == 'dcndl:ISBN') {
        final isbnStr = id.innerText;
        final isbn = int.tryParse(isbnStr.replaceAll('-', ''));
        imageUrl = 'https://ndlsearch.ndl.go.jp/thumbnail/$isbn.jpg';
        break;
      }
    }
    if (imageUrl != null) {
      ndlBooks.add(
        NdlBook(title: title, author: author, link: link, imageUrl: imageUrl),
      );
    }
  }
  return ndlBooks;
}

({int? width, int? height, int? page}) parseNdlBookSize(String htmlString) {
  final document = parse(htmlString);
  // 大きさ等が書いてある
  final elements = document.getElementsByClassName(
    'base-layout-column pages-books-meta-panel',
  );
  final infoItems = elements[0].getElementsByClassName('base-layout-row');
  final text = infoItems[6].getElementsByTagName("span")[0].text;
  final regex = RegExp(r'(\d+)p\s*;\s*(\d+)cm');
  final match = regex.firstMatch(text.toString());
  if (match != null) {
    final page = int.parse(match.group(1)!);
    final height = int.parse(match.group(2)!);
    if (bookSize[height] == null) {
      return (width: null, height: height, page: page);
    }
    final width = bookSize[height]?['width'];
    return (width: width, height: height, page: page);
  }
  return (width: null, height: null, page: null);
}

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

Future<({int? width, int? height, int? page})> fetchBookSize(
  NdlBook ndlBook,
) async {
  final response = await http.get(Uri.parse(ndlBook.link));
  if (response.statusCode == 200) {
    final size = parseNdlBookSize(response.body);
    return (width: size.height!, height: size.width!, page: size.page!);
  } else {
    throw Exception('Failed to fetch data');
  }
}
