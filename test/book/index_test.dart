import 'package:bookshelf/helper/url.dart';
import 'package:bookshelf/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bookshelf/book/index.dart';
import 'package:bookshelf/book/show.dart';
import 'package:bookshelf/book/model/book.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'index_test.mocks.dart';

late MockUrlHelperImpl mockUrlHelperImpl;

Book makeDummyBook({
  String title = 'sample title',
  String author = 'sample author',
  int pages = 1,
  int height = 1,
  int width = 1,
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

Future<void> mockExistUrl({required bool result}) async {
  when(mockUrlHelperImpl.existUrl(any)).thenAnswer((_) async => result);
}

Future<List<Book>> dummyBooks() async {
  return [
    // URLのみ
    makeDummyBook(coverImageUrl: 'https://picsum.photos/200/300'),

    // 画像のpathを持っている
    // makeDummyBook(
    //   coverImagePath: '/assets/sample.png',
    //   spineImagePath: '/assets/spine_sample.png',
    // ),

    // // 画像なし
    // makeDummyBook(),
  ];
}

Future<void> displayDialog(WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(home: Index(booksFuture: dummyBooks())));
  await tester.pumpAndSettle(); // タップする前に同期状態にする
  await tester.tap(find.byType(InkWell).at(0)); // 先頭の要素をタップする
  await tester.pumpAndSettle();
}

void initDI() {
  setUpAll(() async {
    mockUrlHelperImpl = MockUrlHelperImpl();
    getIt.registerLazySingleton<UrlHelperImpl>(() => mockUrlHelperImpl);
  });

  tearDownAll(() async {
    getIt.reset();
  });
}

@GenerateMocks([UrlHelperImpl])
void main() {
  initDI();
  testWidgets('[成功時]表紙の画像が登録されている時はその画像が表示される', (WidgetTester tester) async {
    mockExistUrl(result: true);
    await tester.pumpWidget(
      MaterialApp(home: Index(booksFuture: dummyBooks())),
    );
    await tester.pumpAndSettle();
    final targetBook = find.byType(SizedBox).at(0);
    await tester.tap(targetBook);
    await tester.pumpAndSettle();

    // final imageFinder = find.descendant(
    //   of: find.byType(Dialog),
    //   matching: find.byType(Image),
    // );
    // final imageWidget = tester.widget<Image>(imageFinder); // ← ここでWidgetに変換

    // final provider = imageWidget.image as NetworkImage;
    // expect(provider.url, equals('https://example.com/image.png'));
  });

  // testWidgets(
  //   '[成功時]表紙の画像が登録されていない時は画像URLの画像が表示される',
  //   (WidgetTester tester) async {},
  // );
  // testWidgets(
  //   '[成功時]表紙の画像が登録されておらず、画像URLがない場合は画像が表示されずタイトルが表示される',
  //   (WidgetTester tester) async {},
  // );

  // testWidgets(
  //   '[成功時]背表紙の画像が登録されておらず、画像URLがない場合は画像が表示されずタイトルが表示される',
  //   (WidgetTester tester) async {},
  // );

  // testWidgets(
  //   '[成功時]背表紙の画像が登録されておらず、画像URLがない場合は画像が表示されずタイトルが表示される',
  //   (WidgetTester tester) async {},
  // );

  // testWidgets(
  //   '[成功時]背表紙の画像が登録されておらず、画像URLがない場合は画像が表示されずタイトルが表示される',
  //   (WidgetTester tester) async {},
  // );

  testWidgets('表示されている個数が合っている', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: Index(booksFuture: dummyBooks())),
    );
    await tester.pumpAndSettle();
    final books = await dummyBooks();
    expect(find.byType(InkWell), findsNWidgets(books.length));
  });

  testWidgets('widgetを押した時にダイアログの表示後、キャンセルして元の画面に戻る', (
    WidgetTester tester,
  ) async {
    await displayDialog(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(Index), findsOneWidget);
  });
  testWidgets('widgetを押した時にダイアログの表示後、showページに遷移できる', (
    WidgetTester tester,
  ) async {
    await displayDialog(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Show'));
    await tester.pumpAndSettle();
    expect(find.byType(Show), findsOneWidget);
  });
}
