import 'package:flutter_test/flutter_test.dart';
import 'package:bookshelf/apis/google_book_api.dart';

void main() {
  group('[正常系]parseBooksThroughGoogleのテスト', () {
    test('apiを取得後BookDTOの型に変換されている', () async {
      final _testBookTitle = 'テスト';
      final books = await fetchBookThroughGoogle(_testBookTitle);
      expect(books, isA<List<BookDTO>>());
    });
    test('値が入っている', () async {
      final _testBookTitle = 'テスト';
      final books = await fetchBookThroughGoogle(_testBookTitle);
      final oneBook = books.first;
      expect(oneBook.title, isNotNull);
      expect(oneBook.author, isNotNull);
      expect(oneBook.page, isNotNull);
      expect(oneBook.isbn, isNotNull);
      expect(oneBook.thumbnailUrl, isNotNull);
    });
  });
}
