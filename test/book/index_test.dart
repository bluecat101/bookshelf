import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bookshelf/book/index.dart';
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
    width: 1,
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

Future<void> displayDialog(WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(home: Index()));
  await tester.pumpAndSettle(); // タップする前に同期状態にする
  await tester.tap(find.byType(InkWell).at(0)); // 先頭の要素をタップする
  await tester.pumpAndSettle();
}

void main() {
  initHive(); // Hiveの初期化 & データの作成
  testWidgets('表示されている個数が合っている', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Index()));
    final bookshelf = await Hive.openBox<Book>('book');
    final books = bookshelf.values.toList();
    await tester.pumpAndSettle();
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
