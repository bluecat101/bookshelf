import 'package:flutter_test/flutter_test.dart';
import 'package:bookshelf/apis/national_diet_library_api.dart';

void main() {
  group('[正常系]fetchBookInfoThroughNationalDietLibraryのテスト', () {
    test('apiを取得後NdlBookの型である', () async {
      final testBookTitle = '達人プログラマ';
      final books = await fetchBookInfoThroughNationalDietLibrary(
        testBookTitle,
      );
      expect(books, isA<List<NdlBook>>());
    });
    test('値が入っている', () async {
      final testBookTitle = '達人プログラマ';
      final books = await fetchBookInfoThroughNationalDietLibrary(
        testBookTitle,
      );
      final oneBook = books.first;
      expect(oneBook.title, isNotNull);
      expect(oneBook.author, isNotNull);
      expect(oneBook.link, isNotNull);
      expect(oneBook.isbn, isNotNull);
    });
  });
}
