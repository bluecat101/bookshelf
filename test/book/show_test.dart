import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bookshelf/book/show.dart';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:bookshelf/book/model/book.dart';

// ダミーデータの作成
Book mockBook() {
  return Book(
    title: 'sample title',
    author: 'sample author',
    pages: 1,
    height: 1,
    width: 1,
  );
}

Future<void> createBookForDB() async {
  final bookshelf = await Hive.openBox<Book>('book');
  bookshelf.add(mockBook());
}

Future<Book> getBookFirst() async {
  final bookshelf = await Hive.openBox<Book>('book');
  return bookshelf.values.first;
}

// Hiveを初期化する
initHive() {
  final hiveDirPath = 'test/book/model/hive_test';
  setUpAll(() async {
    Hive.init(hiveDirPath);
    Hive.registerAdapter(BookAdapter());
    // Boxを開く
    await Hive.openBox<Book>('book');
    createBookForDB();
  });

  // 終了後にHiveを閉じる
  tearDownAll(() async {
    final testDir = Directory(hiveDirPath);
    if (testDir.existsSync()) {
      testDir.deleteSync(recursive: true); // ← 完全削除
    }
  });
}

void main() {
  initHive();
  testWidgets('タイトルのフォームが機能するかの確認', (WidgetTester tester) async {
    final book = mockBook();
    await tester.pumpWidget(MaterialApp(home: Show(book: book)));
    final titleField = find.widgetWithText(TextFormField, 'title');
    await tester.enterText(titleField, 'second title');
    await tester.pumpAndSettle();
    expect(find.text('second title'), findsOneWidget);
    expect(find.text('前回の内容: ${book.title}'), findsOneWidget);
  });
  testWidgets('著者のフォームが機能するかの確認', (WidgetTester tester) async {
    final book = mockBook();
    await tester.pumpWidget(MaterialApp(home: Show(book: book)));
    final authorField = find.widgetWithText(TextFormField, 'author');
    await tester.enterText(authorField, 'second author');
    await tester.pumpAndSettle();
    expect(find.text('second author'), findsOneWidget);
    expect(find.text('前回の内容: ${book.author}'), findsOneWidget);
  });
  testWidgets('ページのフォームが機能するかの確認', (WidgetTester tester) async {
    final book = mockBook();
    await tester.pumpWidget(MaterialApp(home: Show(book: book)));
    final pageField = find.widgetWithText(TextFormField, 'page');
    await tester.enterText(pageField, '2');
    await tester.pumpAndSettle();
    expect(find.text('2'), findsOneWidget);
    expect(find.text('前回の内容: ${book.pages}'), findsOneWidget);
  });
  testWidgets('高さのフォームが機能するかの確認', (WidgetTester tester) async {
    final book = mockBook();
    await tester.pumpWidget(MaterialApp(home: Show(book: book)));
    final heightField = find.widgetWithText(TextFormField, 'height');
    await tester.enterText(heightField, '2');
    await tester.pumpAndSettle();
    expect(find.text('2'), findsOneWidget);
    expect(find.text('前回の内容: ${book.height}'), findsOneWidget);
  });
  testWidgets('横幅のフォームが機能するかの確認', (WidgetTester tester) async {
    final book = mockBook();
    await tester.pumpWidget(MaterialApp(home: Show(book: book)));
    final widthField = find.widgetWithText(TextFormField, 'width');
    await tester.enterText(widthField, '2');
    await tester.pumpAndSettle();
    expect(find.text('2'), findsOneWidget);
    expect(find.text('前回の内容: ${book.width}'), findsOneWidget);
  });
  testWidgets('データを更新できるか', (WidgetTester tester) async {
    final title = 'second title';
    final author = 'second author';
    final pages = 2;
    final height = 2;
    final width = 2;
    final book = await getBookFirst();
    await tester.pumpWidget(MaterialApp(home: Show(book: book)));
    final titleField = find.widgetWithText(TextFormField, 'title');
    final authorField = find.widgetWithText(TextFormField, 'author');
    final pageField = find.widgetWithText(TextFormField, 'page');
    final heightField = find.widgetWithText(TextFormField, 'height');
    final widthField = find.widgetWithText(TextFormField, 'width');
    await tester.enterText(titleField, title);
    await tester.enterText(authorField, author);
    await tester.enterText(pageField, pages.toString());
    await tester.enterText(heightField, height.toString());
    await tester.enterText(widthField, width.toString());
    await tester.tap(find.widgetWithText(ElevatedButton, '更新する')); // 更新ボタンをクリック
    await tester.pumpAndSettle();
    final bookshelf = await Hive.openBox<Book>('book');
    final books = bookshelf.values.toList();
    expect(books[0].title, title);
    expect(books[0].author, author);
    expect(books[0].pages, pages);
    expect(books[0].height, height);
    expect(books[0].width, width);
  });
}
