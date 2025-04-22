import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bookshelf/book/new_book.dart';
import 'package:bookshelf/book/index.dart';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:bookshelf/book/model/book.dart';

// 失敗時の入力フォーム
Future<void> enterInvalidFormInput(WidgetTester tester) async {
  final titleField = find.widgetWithText(TextFormField, 'title');
  await tester.enterText(titleField, '');
}

// 成功時の入力フォーム
Future<void> enterValidFormInput(
  WidgetTester tester, {
  String title = "sample title",
}) async {
  final titleField = find.widgetWithText(TextFormField, 'title');
  await tester.enterText(titleField, title);
}

// Hiveを初期化する
void initHive() {
  final hiveDirPath = 'test/book/model/hive_test';
  setUpAll(() async {
    // テスト用の一時ディレクトリを用意

    Hive.init(hiveDirPath);
    Hive.registerAdapter(BookAdapter());
    // Boxを開く
    await Hive.openBox<Book>('book');
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
    await tester.pumpWidget(MaterialApp(home: NewBook()));
    final titleField = find.widgetWithText(TextFormField, 'title');
    await tester.enterText(titleField, 'sample title');
    expect(find.text('sample title'), findsOneWidget);
  });
  testWidgets('バリデーションの確認', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: NewBook()));
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(find.text('タイトルを入力してください'), findsOneWidget);
  });
  // これより下は、単体でテストする場合にはinitHive()を実行してください
  testWidgets('データが保存されるかどうか', (WidgetTester tester) async {
    final title = "sample title";
    await tester.pumpWidget(MaterialApp(home: NewBook()));
    await enterValidFormInput(tester);
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    final bookshelf = await Hive.openBox<Book>('book');
    final books = bookshelf.values.toList();
    expect(books[0].title, title);
  });
  testWidgets('(失敗時)submitボタンを押してもダイアログが表示されない', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: NewBook()));
    await enterInvalidFormInput(tester);
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('(成功時)「追加する」を選択したときに新しい入力フォームが現れる', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: NewBook()));
    await enterValidFormInput(tester);
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, '追加する'));
    await tester.pump();
    expect(find.byType(NewBook), findsOneWidget);
  });
  testWidgets('(成功時)「本棚を見に行く」を選択したときに画面が遷移する', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: NewBook()));
    await enterValidFormInput(tester);
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, '本棚を見に行く'));
    await tester.pumpAndSettle();
    expect(find.byType(Index), findsOneWidget);
  });
}
