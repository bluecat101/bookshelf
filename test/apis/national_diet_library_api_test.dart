import 'package:bookshelf/helper/image.dart';
import 'package:bookshelf/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bookshelf/apis/national_diet_library_api.dart';
import 'package:mockito/annotations.dart';

import '../mocks/image_helper_test.mocks.dart';
import '../mocks/image_helper_test_setup.dart';

@GenerateMocks([BookFetcher])
late MockImageHelperImpl mockImageHelper;

NdlBook getSampleBook() {
  return NdlBook(
    title: '達人プログラマ',
    author: 'David Thomas',
    link: 'https://ndlsearch.ndl.go.jp/books/R100000002-I030738986',
    imageUrl: 'https://ndlsearch.ndl.go.jp/thumbnail/9784274226298.jpg',
  );
}

Future<void> readyUrlHelperMock() async {
  mockExistUrl(mockImageHelper, true);
}

void initDI() {
  setUpAll(() async {
    mockImageHelper = MockImageHelperImpl();
    getIt.registerLazySingleton<ImageHelperImpl>(() => mockImageHelper);
  });

  tearDownAll(() async {
    getIt.reset();
  });
}

void main() {
  initDI();
  group('[正常系]fetchBookInfoThroughNationalDietLibraryのテスト', () {
    test('apiを取得後NdlBookの型である', () async {
      final testBookTitle = '達人プログラマ';
      final bookFetcher = BookFetcher();
      readyUrlHelperMock();
      final books = await bookFetcher.fetchBookInfoThroughNationalDietLibrary(
        testBookTitle,
      );
      expect(books, isA<List<NdlBook>>());
    });
    test('値が入っている', () async {
      final testBookTitle = '達人プログラマ';
      final bookFetcher = BookFetcher();
      final books = await bookFetcher.fetchBookInfoThroughNationalDietLibrary(
        testBookTitle,
      );
      final oneBook = books.first;
      expect(oneBook.title, isNotNull);
      expect(oneBook.author, isNotNull);
      expect(oneBook.link, isNotNull);
      expect(oneBook.imageUrl, isNotNull);
    });
  });
  group('[正常系]fetchBookSizeのテスト', () {
    test('apiを取得後NdlBookの型である', () async {
      final bookFetcher = BookFetcher();
      final size = await bookFetcher.fetchBookSize(getSampleBook());
      expect(size, isA<BookSize>());
    });
  });
}
