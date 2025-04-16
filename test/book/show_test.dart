import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bookshelf/book/show.dart';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:bookshelf/book/model/book.dart';

// ダミーデータの作成
Future<void> createDummyData() async {
  final bookshelf = await Hive.openBox<Book>('book');
  final book = Book(
    title: 'sample title',
    author: 'sample author',
    page: 1,
    height: 1,
    thickness: 1,
  );
  bookshelf.add(book);
}

// Hiveを初期化する
initHive() {
  final hiveDirPath = 'test/book/model/hive_test';
  setUpAll(() async {
    // テスト用の一時ディレクトリを用意
    Hive.init(hiveDirPath);
    Hive.registerAdapter(BookAdapter());
    // Boxを開く
    await Hive.openBox<Book>('book');
    // データを作成する
    await createDummyData();
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
  initHive(); // Hiveの初期化
  testWidgets('タイトルのフォームが機能するかの確認', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Show()));
    final titleField = find.widgetWithText(TextFormField, 'title');
    await tester.enterText(titleField, 'second title');
    expect(find.text('second title'), findsOneWidget);
    expect(find.text('前回の入力: sample title'), findsOneWidget);
  });
  testWidgets('著者のフォームが機能するかの確認', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Show()));
    final authorField = find.widgetWithText(TextFormField, 'author');
    await tester.enterText(authorField, 'second author');
    expect(find.text('second author'), findsOneWidget);
    expect(find.text('前回の入力: sample author'), findsOneWidget);
  });
  testWidgets('ページのフォームが機能するかの確認', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Show()));
    final pageField = find.widgetWithText(TextFormField, 'page');
    await tester.enterText(pageField, '2');
    expect(find.text('2'), findsOneWidget);
    expect(find.text('前回の入力: 1'), findsOneWidget);
  });
  testWidgets('高さのフォームが機能するかの確認', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Show()));
    final heightField = find.widgetWithText(TextFormField, 'height');
    await tester.enterText(heightField, '2');
    expect(find.text('2'), findsOneWidget);
    expect(find.text('前回の入力: 1'), findsOneWidget);
  });
  testWidgets('厚さのフォームが機能するかの確認', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Show()));
    final thicknessField = find.widgetWithText(TextFormField, 'thickness');
    await tester.enterText(thicknessField, '2');
    expect(find.text('2'), findsOneWidget);
    expect(find.text('前回の入力: 1'), findsOneWidget);
  });
  // これより下は、単体でテストする場合にはinitHive()を実行してください
  testWidgets('データを更新できるか', (WidgetTester tester) async {
    final title = 'second title';
    final author = 'second author';
    final page = '2';
    final height = '2';
    final thickness = '2';
    await tester.pumpWidget(MaterialApp(home: Show()));
    final titleField = find.widgetWithText(TextFormField, 'title');
    final authorField = find.widgetWithText(TextFormField, 'author');
    final pageField = find.widgetWithText(TextFormField, 'page');
    final heightField = find.widgetWithText(TextFormField, 'height');
    final thicknessField = find.widgetWithText(TextFormField, 'thickness');
    await tester.enterText(titleField, title);
    await tester.enterText(authorField, author);
    await tester.enterText(pageField, page);
    await tester.enterText(heightField, height);
    await tester.enterText(thicknessField, thickness);
    await tester.tap(find.byType(ElevatedButton)); // 更新ボタンをクリック
    await tester.pumpAndSettle();
    final bookshelf = await Hive.openBox<Book>('book');
    final books = bookshelf.values.toList();
    expect(books[0].title, title);
    expect(books[0].author, author);
    expect(books[0].page, page);
    expect(books[0].height, height);
    expect(books[0].thickness, thickness);
  });
}
