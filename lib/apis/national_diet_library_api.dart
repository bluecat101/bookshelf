import 'package:xml/xml.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class NdlBook {
  final String title;
  final String author;
  final String link;
  final String? imageUrl;

  const NdlBook({
    required this.title,
    required this.author,
    required this.link,
    this.imageUrl,
  });
  static Future<bool> _existUrl(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static bool _isUniqueTitle(String newTitle, List<NdlBook> books) {
    return books.every((book) => book.title != newTitle);
  }

  static Future<List<NdlBook>> _parseNdlBooks(
    String xmlString,
    String searchedTitle,
  ) async {
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

      // 既に検索済みのタイトルと一致している場合もcontinue
      if (category == null ||
          title == null ||
          searchedTitle.contains(title) ||
          author == null ||
          link == null ||
          !_isUniqueTitle(title, ndlBooks)) {
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
      if (imageUrl != null && !(await _existUrl(imageUrl))) {
        imageUrl = null;
      }
      ndlBooks.add(
        NdlBook(title: title, author: author, link: link, imageUrl: imageUrl),
      );
    }
    return ndlBooks;
  }
}

class BookSize {
  final int? width;
  final int? height;
  final int? pages;

  const BookSize({this.width, this.height, this.pages});

  bool get isAllNull => width == null && height == null && pages == null;
  static const bookSizeFromHeight = {
    15: {"width": 8},
    19: {"width": 13},
    21: {"width": 15},
    23: {"width": 15},
    24: {"width": 16},
    30: {"width": 21},
  };

  static BookSize _parseNdlBookSize(String htmlString) {
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
      final pages = int.parse(match.group(1)!);
      final height = int.parse(match.group(2)!);
      final width = bookSizeFromHeight[height]?['width'];
      return BookSize(width: width, height: height, pages: pages);
    }
    return BookSize();
  }
}

class BookFetcher {
  // 本のデータを取得する
  Future<List<NdlBook>> fetchBookInfoThroughNationalDietLibrary(
    String title,
  ) async {
    final encodedTitle = Uri.encodeFull(title);
    final url =
        'https://ndlsearch.ndl.go.jp/api/opensearch?cnt=100&title=$encodedTitle';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return await NdlBook._parseNdlBooks(response.body, title);
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  // 本のサイズを取得する
  Future<BookSize> fetchBookSize(NdlBook ndlBook) async {
    final response = await http.get(Uri.parse(ndlBook.link));
    if (response.statusCode == 200) {
      return BookSize._parseNdlBookSize(response.body);
    } else {
      throw Exception('Failed to fetch data');
    }
  }
}
