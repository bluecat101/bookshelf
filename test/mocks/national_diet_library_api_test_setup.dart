import 'package:bookshelf/apis/national_diet_library_api.dart';
import 'package:mockito/mockito.dart';

import 'national_diet_library_api_test.mocks.dart';

Future<void> mockFetchBookInfoThroughNationalDietLibrary(
  MockBookFetcher mockBookFetcher,
  Future<List<NdlBook>> books,
) async {
  when(
    mockBookFetcher.fetchBookInfoThroughNationalDietLibrary(any),
  ).thenAnswer((_) async => books);
}

Future<void> mockFetchBookSize(
  MockBookFetcher mockBookFetcher,
  Future<BookSize> bookSizeResult,
) async {
  when(mockBookFetcher.fetchBookSize(any)).thenAnswer((_) => bookSizeResult);
}

Future<BookSize> mockEmptyBookSize() async {
  return BookSize();
}

Future<BookSize> mockValidBookSize({
  int width = 1,
  int height = 1,
  int pages = 1,
}) async {
  return BookSize(width: width, height: height, pages: pages);
}
