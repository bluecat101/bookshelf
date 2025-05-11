import 'package:bookshelf/book/model/book.dart';
import 'package:mockito/mockito.dart';

import 'book_repository.mocks.dart';

const sampleImageLocalPath = 'test/test_image.png';
const sampleImageStoragePath = 'test/assets/test_image.png';

const sampleLocalImage = 'test/assets/test_image.png';
// testで実際のhttpリクエストを送ると400番になるため画像はローカルに保存しておく
const sampleUrlImage = 'test/assets/test_url_image.png';

Future<void> mockFetchBooks(
  MockBookRepository mockBookRepository, {
  Future<List<Book>>? books,
}) async {
  books ??= dummyBooks();
  when(mockBookRepository.fetchBooks()).thenAnswer((_) => books!);
}

Book makeDummyBook({
  String title = 'sample title',
  String author = 'sample author',
  int pages = 100,
  int height = 20,
  int width = 10,
  String? coverImageUrl,
  String? coverImagePath,
  String? spineImagePath,
}) {
  return Book(
    title: title,
    author: author,
    pages: pages,
    height: height,
    width: width,
    coverImageUrl: coverImageUrl,
    coverImagePath: coverImagePath,
    spineImagePath: spineImagePath,
  );
}

enum BookType { hasUrl, hasImagePath, hasNoUrlAndPath }

extension BookTypeExtension on BookType {
  int get index {
    return this.index;
  }
}

Future<List<Book>> dummyBooks() async {
  return [
    // URLのみ
    makeDummyBook(coverImageUrl: sampleUrlImage),
    // 画像のpathを持っている
    makeDummyBook(
      coverImagePath: sampleLocalImage,
      spineImagePath: sampleLocalImage,
    ),
    // 画像なし
    makeDummyBook(),
  ];
}
