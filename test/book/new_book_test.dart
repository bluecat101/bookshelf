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

NdlBook mockNdlBook(String title, String author) {
  // linkはテストしないので定数とする
  return NdlBook(title: title, author: author, link: 'sample link');
}

Future<List<NdlBook>> mockNdlBooks(NdlBook book) async {
  return [book];
}

Future<BookSize> mockEmptyBookSize() async {
  return BookSize();
}

Future<BookSize> mockValidBookSize() async {
  return BookSize(width: 1, height: 1, pages: 1);
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
    // Boxを開く
    await Hive.openBox<Book>('book');
    // DI
    getIt.registerLazySingleton<BookFetcher>(() => MockBookFetcher());
  });

  // 終了後にHiveを閉じる
  tearDownAll(() async {
    final testDir = Directory(hiveDirPath);
    if (testDir.existsSync()) {
      testDir.deleteSync(recursive: true); // ← 完全削除
    }
    // DI
    getIt.reset();
  });
}

@GenerateMocks([BookFetcher])
void main() {
  initHive(); // Hiveの初期化
  // testWidgets('タイトルのフォームが機能するかの確認', (WidgetTester tester) async {
  //   await tester.pumpWidget(MaterialApp(home: NewBook()));
  //   final titleField = find.widgetWithText(TextFormField, 'title');
  //   await tester.enterText(titleField, 'sample title');
  //   expect(find.text('sample title'), findsOneWidget);
  // });
  // testWidgets('バリデーションの確認', (WidgetTester tester) async {
  //   await tester.pumpWidget(MaterialApp(home: NewBook()));
  //   await tester.tap(find.byType(ElevatedButton));
  //   await tester.pump();
  //   expect(find.text('タイトルを入力してください'), findsOneWidget);
  // });
  // // これより下は、単体でテストする場合にはinitHive()を実行してください
  // testWidgets('データが保存されるかどうか', (WidgetTester tester) async {
  //   final title = 'sample title';
  //   await tester.pumpWidget(MaterialApp(home: NewBook()));
  //   await enterValidFormInput(tester);
  //   await tester.tap(find.byType(ElevatedButton));
  //   await tester.pumpAndSettle();
  //   final bookshelf = await Hive.openBox<Book>('book');
  //   final books = bookshelf.values.toList();
  //   expect(books[0].title, title);
  // });

  testWidgets('[成功時]検索ボタンを押したときに本が表示、クリック後にIndexに遷移する(本のサイズが元々入っている)', (
    WidgetTester tester,
  ) async {
    // DI
    final mockBookFetcher = getIt<BookFetcher>();
    // Mock
    final title = 'sample title';
    final author = 'sample author';
    final book = mockNdlBook(title, author);

    when(
      mockBookFetcher.fetchBookInfoThroughNationalDietLibrary(title),
    ).thenAnswer((_) async => await mockNdlBooks(book));
    when(
      mockBookFetcher.fetchBookSize(book),
    ).thenAnswer((_) => mockValidBookSize());
    // Assert
    // 検索ボタンのクリック
    await tester.pumpWidget(MaterialApp(home: NewBook()));
    await enterValidFormInput(tester, title);
    await tester.tap(find.widgetWithText(ElevatedButton, '検索する'));
    await tester.pumpAndSettle();
    // 本の表示
    expect(find.byType(TextButton), findsAtLeast(1));
    expect(
      find.textContaining(title),
      findsAtLeast(2),
    ); // formの入力欄、画像がないときは文字を表示するため2つ以上とする
    expect(find.textContaining(author), findsOneWidget);
    expect(
      find.widgetWithText(TextButton, title),
      findsAtLeast(1),
    ); // 画像がない場合にTextButtonの中にtitleが2つ表示されることがあるため、1以上とする

    // 本の追加
    final firstTextButton = find.byType(TextButton).at(0);
    await tester.tap(firstTextButton);
    await tester.pumpAndSettle();
    expect(find.byType(Index), findsOneWidget);
  });
  testWidgets('[成功時]本のサイズを入力するダイアログが表示され入力後Indexに遷移する', (
    WidgetTester tester,
  ) async {
    // DI
    final mockBookFetcher = getIt<BookFetcher>();
    // Mock
    final title = 'sample title';
    final author = 'sample author';
    final book = mockNdlBook(title, author);
    when(
      mockBookFetcher.fetchBookInfoThroughNationalDietLibrary(title),
    ).thenAnswer((_) async => await mockNdlBooks(book));
    when(
      mockBookFetcher.fetchBookSize(book),
    ).thenAnswer((_) => mockEmptyBookSize());
    // Assert
    // 検索ボタンのクリック
    await tester.pumpWidget(MaterialApp(home: NewBook()));
    await enterValidFormInput(tester, title);
    await tester.tap(find.widgetWithText(ElevatedButton, '検索する'));
    await tester.pumpAndSettle();

    // 本の追加
    final firstTextButton = find.byType(TextButton).at(0);
    await tester.tap(firstTextButton);
    await tester.pumpAndSettle();
    // ダイアログのテスト
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      findsNWidgets(3),
    );

    final widthField = find.widgetWithText(TextField, 'width');
    final heightField = find.widgetWithText(TextField, 'height');
    final pagesField = find.widgetWithText(TextField, 'pages');
    expect(widthField, findsOneWidget);
    expect(heightField, findsOneWidget);
    expect(pagesField, findsOneWidget);
    await tester.enterText(widthField, '1');
    await tester.enterText(heightField, '1');
    await tester.enterText(pagesField, '1');
    await tester.tap(find.widgetWithText(TextButton, '追加する'));
    await tester.pumpAndSettle();
    expect(find.byType(Index), findsOneWidget);
  });
  // testWidgets('[失敗時]検索ボタンを押しても本が表示されない', (WidgetTester tester) async {
  //   await tester.pumpWidget(MaterialApp(home: NewBook()));
  //   await enterInvalidFormInput(tester);
  //   await tester.tap(find.byType(ElevatedButton));
  //   await tester.pumpAndSettle();
  //   expect(find.byType(TextButton), findsNothing);
  // });
  // testWidgets('[失敗時]本のサイズを入力せずに追加ボタンを押すとIndexに遷移しない', (
  //   WidgetTester tester,
  // ) async {
  //   await tester.pumpWidget(MaterialApp(home: NewBook()));
  //   await enterValidFormInput(tester);
  //   await tester.tap(find.widgetWithText(ElevatedButton, '検索する'));
  //   await tester.pumpAndSettle();
  //   final firstButtonFinder = find.byType(TextButton).at(0);
  //   await tester.tap(firstButtonFinder);
  //   await tester.pumpAndSettle();

  //   // ダイアログの確認
  //   await tester.tap(find.widgetWithText(TextButton, '追加する'));
  //   await tester.pumpAndSettle();
  //   expect(find.byType(Index), findsOneWidget);
  // });
}
