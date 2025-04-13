import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bookshelf/book/newBook.dart';
import 'package:bookshelf/book/index.dart';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:bookshelf/book/model/book.dart';

Future<void> enterInvalidFormInput(WidgetTester tester) async {
  final titleField = find.widgetWithText(TextFormField, 'title');
  final authorField = find.widgetWithText(TextFormField, 'author');
  final pageField = find.widgetWithText(TextFormField, 'page');
  final heightField = find.widgetWithText(TextFormField, 'height');
  final thicknessField = find.widgetWithText(TextFormField, 'thickness');
  await tester.enterText(titleField, 'sample title');
  await tester.enterText(authorField, 'sample author');
  await tester.enterText(pageField, 'sample page');
  await tester.enterText(heightField, 'sample height');
  await tester.enterText(thicknessField, 'sample thickness');
}

Future<void> enterValidFormInput(WidgetTester tester) async {
  final titleField = find.widgetWithText(TextFormField, 'title');
  final authorField = find.widgetWithText(TextFormField, 'author');
  final pageField = find.widgetWithText(TextFormField, 'page');
  final heightField = find.widgetWithText(TextFormField, 'height');
  final thicknessField = find.widgetWithText(TextFormField, 'thickness');
  await tester.enterText(titleField, 'sample title');
  await tester.enterText(authorField, 'sample author');
  await tester.enterText(pageField, '1');
  await tester.enterText(heightField, '1');
  await tester.enterText(thicknessField, '1');
}

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
  initHive();
  testWidgets('タイトルのフォームが機能するかの確認', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: NewBook()));
    final titleField = find.widgetWithText(TextFormField, 'title');
    await tester.enterText(titleField, 'sample title');
    expect(find.text('sample title'), findsOneWidget);
  });
  testWidgets('著者のフォームが機能するかの確認', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: NewBook()));
    final authorField = find.widgetWithText(TextFormField, 'author');
    await tester.enterText(authorField, 'sample author');
    expect(find.text('sample author'), findsOneWidget);
  });
  testWidgets('ページのフォームが機能するかの確認', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: NewBook()));
    final pageField = find.widgetWithText(TextFormField, 'page');
    await tester.enterText(pageField, '1');
    expect(find.text('1'), findsOneWidget);
  });
  testWidgets('高さのフォームが機能するかの確認', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: NewBook()));
    final heightField = find.widgetWithText(TextFormField, 'height');
    await tester.enterText(heightField, '1');
    expect(find.text('1'), findsOneWidget);
  });
  testWidgets('厚さのフォームが機能するかの確認', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: NewBook()));
    final thicknessField = find.widgetWithText(TextFormField, 'thickness');
    await tester.enterText(thicknessField, '1');
    expect(find.text('1'), findsOneWidget);
  });
  testWidgets('バリデーションの確認', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: NewBook()));
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(find.text('タイトルを入力してください'), findsOneWidget);
    expect(find.text('著者を入力してください'), findsOneWidget);
    expect(find.text('数字を入れてください'), findsNWidgets(3));
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
    // expect(find.text('本棚を見に行く'), findsOneWidget);
  });
}
