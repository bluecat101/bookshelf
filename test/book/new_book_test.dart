import 'package:bookshelf/apis/national_diet_library_api.dart';
import 'package:bookshelf/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bookshelf/book/new_book.dart';
import 'package:bookshelf/book/index.dart';
import 'package:mockito/annotations.dart';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:bookshelf/book/model/book.dart';
import 'package:mockito/mockito.dart';
import 'new_book_test.mocks.dart';

NdlBook mockNdlBook({
  String title = 'sample title',
  String author = 'sample author',
  String link = 'sample url',
}) {
  // linkはテストしないので定数とする
  return NdlBook(title: title, author: author, link: link);
}

Future<List<NdlBook>> mockNdlBooks(NdlBook? book) async {
  if (book == null) {
    return [mockNdlBook()];
  }
  return [book];
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

// 失敗時の入力フォーム
Future<void> enterInvalidFormInput(WidgetTester tester) async {
  final titleField = find.widgetWithText(TextFormField, 'title');
  await tester.enterText(titleField, '');
}

// 成功時の入力フォーム
Future<void> enterValidFormInput(WidgetTester tester, String title) async {
  final titleField = find.widgetWithText(TextFormField, 'title');
  await tester.enterText(titleField, title);
}

// Hiveを初期化する
void initHive() {
  // テスト用の一時ディレクトリを用意
  final hiveDirPath = 'test/book/model/hive_test';
  setUpAll(() async {
    Hive.init(hiveDirPath);
    Hive.registerAdapter(BookAdapter());
    await Hive.openBox<Book>('book');
    // DI
    getIt.registerLazySingleton<BookFetcher>(() => MockBookFetcher());
  });

  tearDownAll(() async {
    // Hiveを閉じる
    final testDir = Directory(hiveDirPath);
    if (testDir.existsSync()) {
      testDir.deleteSync(recursive: true);
    }
    getIt.reset();
  });
}

Future<void> prepareSearchResult({
  required WidgetTester tester,
  NdlBook? book,
  Future<BookSize>? funcMockBookSize,
}) async {
  book ??= mockNdlBook();
  funcMockBookSize ??= mockValidBookSize();
  // DI
  final mockBookFetcher = getIt<BookFetcher>();
  when(
    mockBookFetcher.fetchBookInfoThroughNationalDietLibrary(book.title),
  ).thenAnswer((_) async => await mockNdlBooks(book));
  when(
    mockBookFetcher.fetchBookSize(book),
  ).thenAnswer((_) => funcMockBookSize!);

  await tester.pumpWidget(MaterialApp(home: NewBook()));
  await enterValidFormInput(tester, book.title);
  await tester.tap(find.widgetWithText(ElevatedButton, '検索する'));
  await tester.pumpAndSettle();
}

Future<void> tapFirstBook(WidgetTester tester) async {
  final firstTextButton = find.byType(TextButton).at(0);
  await tester.tap(firstTextButton);
  await tester.pumpAndSettle();
}

Future<void> enterBookSize({
  required WidgetTester tester,
  BookSize? bookSize,
}) async {
  bookSize ??= await mockValidBookSize();
  final widthField = find.widgetWithText(TextField, 'width');
  final heightField = find.widgetWithText(TextField, 'height');
  final pagesField = find.widgetWithText(TextField, 'pages');
  await tester.enterText(widthField, bookSize.width.toString());
  await tester.enterText(heightField, bookSize.height.toString());
  await tester.enterText(pagesField, bookSize.pages.toString());
}

Future<void> tapAddBookButton(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(TextButton, '追加する'));
  await tester.pumpAndSettle();
}

@GenerateMocks([BookFetcher])
void main() {
  initHive(); // Hiveの初期化
  testWidgets('タイトルのフォームが機能するかの確認', (WidgetTester tester) async {
    final title = 'sample title';
    await tester.pumpWidget(MaterialApp(home: NewBook()));
    final titleField = find.widgetWithText(TextFormField, 'title');
    await tester.enterText(titleField, title);
    expect(find.text(title), findsOneWidget);
  });
  testWidgets('バリデーションの確認', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: NewBook()));
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(find.text('タイトルを入力してください'), findsOneWidget);
  });
  testWidgets('[成功時]検索ボタンのタップ時、本の情報が表示される', (WidgetTester tester) async {
    final title = 'sample title';
    final author = 'sample author';
    final book = mockNdlBook(title: title, author: author);
    await prepareSearchResult(tester: tester, book: book);

    // Assert
    expect(find.byType(TextButton), findsOneWidget); // 本用のボタンがあるか
    expect(
      find.descendant(
        of: find.byType(TextButton),
        matching: find.textContaining(title),
      ),
      findsAtLeast(2),
    ); // タイトルが表示されているか(画像がないときは文字を表示するため2つ以上とする)
    expect(find.textContaining(author), findsOneWidget); // 著者があるか
  });
  testWidgets('[成功時]検索結果のタップ時、DBに正しく保存される', (WidgetTester tester) async {
    final title = 'sample title';
    final author = 'sample author';
    final width = 1;
    final height = 1;
    final pages = 1;
    final book = mockNdlBook(title: title, author: author);
    await prepareSearchResult(
      tester: tester,
      book: book,
      funcMockBookSize: mockValidBookSize(
        width: width,
        height: height,
        pages: pages,
      ),
    );
    // Act
    // 本の追加
    await tapFirstBook(tester);
    final bookshelf = await Hive.openBox<Book>('book');
    final createdBook = bookshelf.values.toList().first;
    // 登録された本の内容が正しい
    expect(createdBook.title, title);
    expect(createdBook.author, author);
    expect(createdBook.width, width);
    expect(createdBook.height, height);
    expect(createdBook.page, pages);
  });
  testWidgets('[成功時]検索結果のタップ時、Indexに遷移する', (WidgetTester tester) async {
    await prepareSearchResult(tester: tester);
    await tapFirstBook(tester);
    // Assert
    expect(find.byType(Index), findsOneWidget);
  });

  testWidgets('[成功時]本のサイズの未取得時、入力欄を含むダイアログが表示される', (WidgetTester tester) async {
    await prepareSearchResult(
      tester: tester,
      funcMockBookSize: mockEmptyBookSize(),
    );
    await tapFirstBook(tester);
    // ダイアログの表示
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      findsNWidgets(3),
    );
  });

  testWidgets('[成功時]本のサイズの入力後の追加ボタンのタップ時、DBに正しく保存される', (
    WidgetTester tester,
  ) async {
    final title = 'sample title';
    final author = 'sample author';
    final width = 1;
    final height = 1;
    final pages = 1;
    final book = mockNdlBook(title: title, author: author);
    final bookSize = BookSize(width: width, height: height, pages: pages);
    await prepareSearchResult(
      tester: tester,
      book: book,
      funcMockBookSize: mockEmptyBookSize(),
    ); // 本のサイズは未取得
    await tapFirstBook(tester);
    await enterBookSize(tester: tester, bookSize: bookSize);
    await tapAddBookButton(tester);

    // Assert
    final bookshelf = await Hive.openBox<Book>('book');
    final createdBook = bookshelf.values.toList().first;
    // 登録された本の内容が正しい
    expect(createdBook.title, title);
    expect(createdBook.author, author);
    expect(createdBook.width, width);
    expect(createdBook.height, height);
    expect(createdBook.page, pages);
  });

  testWidgets('[成功時]本のサイズの入力後の追加ボタンのタップ時、Indexに遷移する', (
    WidgetTester tester,
  ) async {
    await prepareSearchResult(
      tester: tester,
      funcMockBookSize: mockEmptyBookSize(),
    );
    await tapFirstBook(tester);
    await enterBookSize(tester: tester);
    await tapAddBookButton(tester);
    // Assert
    expect(find.byType(Index), findsOneWidget);
  });

  testWidgets('[失敗時]検索ボタンを押しても本が表示されない', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: NewBook()));
    await enterInvalidFormInput(tester);
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(find.byType(TextButton), findsNothing);
  });
  testWidgets('[失敗時]本のサイズの未入力の追加ボタンのタップ時、本の追加に失敗する', (
    WidgetTester tester,
  ) async {
    final bookshelf = await Hive.openBox<Book>('book');
    List<Book> books = bookshelf.values.toList();
    final expectedBooksLen = books.length;
    await prepareSearchResult(
      tester: tester,
      funcMockBookSize: mockEmptyBookSize(),
    ); // 本のサイズは未取得
    await tapFirstBook(tester);
    await tapAddBookButton(tester);
    // Assert
    books = bookshelf.values.toList();
    // 登録された本がない
    expect(books.length, expectedBooksLen);
  });
  testWidgets('[失敗時]本のサイズの未入力の追加ボタンのタップ時、Indexに遷移しない', (
    WidgetTester tester,
  ) async {
    await prepareSearchResult(
      tester: tester,
      funcMockBookSize: mockEmptyBookSize(),
    ); // 本のサイズは未取得
    await tapFirstBook(tester);
    await tapAddBookButton(tester);

    // Assert
    expect(find.byType(Index), findsNothing);
  });
}
