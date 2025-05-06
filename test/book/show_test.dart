import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bookshelf/book/show.dart';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:bookshelf/book/model/book.dart';

late Box<Book> bookshelf;

// ダミーデータの作成
Book dummyBook() {
  return Book(
    title: 'sample title',
    author: 'sample author',
    pages: 1,
    height: 1,
    width: 1,
  );
}

Future<void> createBookForDB() async {
  bookshelf.add(dummyBook());
}

Future<Book> getBookFirst() async {
  return bookshelf.values.first;
}

// Hiveを初期化する
initHive() {
  final hiveDirPath = 'test/book/model/hive_test';
  setUpAll(() async {
    Hive.init(hiveDirPath);
    Hive.registerAdapter(BookAdapter());
    // Boxを開く
    bookshelf = await Hive.openBox<Book>('book');
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

Future<void> changeFormText(
  WidgetTester tester,
  String targetFormLabel,
  String changedText,
) async {
  final fieldFinder = find.widgetWithText(TextFormField, targetFormLabel);
  await tester.enterText(fieldFinder, changedText);
  await tester.pumpAndSettle();
}

void main() {
  initHive();
  testWidgets('タイトルのフォームが機能するかの確認', (WidgetTester tester) async {
    final book = dummyBook();
    final changedText = 'second title';
    await tester.pumpWidget(MaterialApp(home: Show(book: book)));

    await changeFormText(tester, 'title', changedText);
    expect(find.text('前回の内容: ${book.title}'), findsOneWidget);
  });
  testWidgets('著者のフォームが機能するかの確認', (WidgetTester tester) async {
    final book = dummyBook();
    final changedText = 'second author';
    await tester.pumpWidget(MaterialApp(home: Show(book: book)));

    await changeFormText(tester, 'author', changedText);
    expect(find.text('前回の内容: ${book.author}'), findsOneWidget);
  });
  testWidgets('ページのフォームが機能するかの確認', (WidgetTester tester) async {
    final book = dummyBook();
    final changedText = 'second pages';
    await tester.pumpWidget(MaterialApp(home: Show(book: book)));

    await changeFormText(tester, 'page', changedText);
    expect(find.text('前回の内容: ${book.pages}'), findsOneWidget);
  });
  testWidgets('高さのフォームが機能するかの確認', (WidgetTester tester) async {
    final book = dummyBook();
    final changedText = 'second height';
    await tester.pumpWidget(MaterialApp(home: Show(book: book)));

    await changeFormText(tester, 'height', changedText);
    expect(find.text('前回の内容: ${book.height}'), findsOneWidget);
  });
  testWidgets('横幅のフォームが機能するかの確認', (WidgetTester tester) async {
    final book = dummyBook();
    final changedText = 'second width';
    await tester.pumpWidget(MaterialApp(home: Show(book: book)));

    await changeFormText(tester, 'width', changedText);
    expect(find.text('前回の内容: ${book.width}'), findsOneWidget);
  });
  testWidgets('commentのフォームが存在するか確認', (WidgetTester tester) async {
    final book = dummyBook();
    await tester.pumpWidget(MaterialApp(home: Show(book: book)));
    expect(find.widgetWithText(TextFormField, 'comment'), findsOneWidget);
  });

  testWidgets('表紙の画像をuploadできる(更新は含まない)', (WidgetTester tester) async {
    // 表紙の画像をアップロードするボタンが表示されている
    // 選択した画像のファイル名が表示される(mockCoverImageFileを使う)
    // final fieldFinder = find.widgetWithText(TextButton, '表紙の画像をアップロードする');
    final filePath = '';
    expect(find.text(filePath), findsOneWidget);
  });
  testWidgets('背表紙の画像をuploadできる(更新は含まない)', (WidgetTester tester) async {
    // 背表紙の画像をアップロードするボタンが表示されている
    // 選択した画像のファイル名が表示される(mockSpineImageFileを使う)
    // final fieldFinder = find.widgetWithText(TextButton, '背表紙の画像をアップロードする');
    final filePath = '';
    expect(find.text(filePath), findsOneWidget);
  });
  testWidgets('データを更新できるか', (WidgetTester tester) async {
    final book = await getBookFirst();
    final updatedTitle = 'second title';
    final updatedAuthor = 'second author';
    final updatedPages = 2;
    final updatedHeight = 2;
    final updatedWidth = 2;
    final updatedCoverImagePath = '';
    final updatedSpineImagePath = '';
    await tester.pumpWidget(MaterialApp(home: Show(book: book)));
    await changeFormText(tester, 'title', updatedTitle);
    await changeFormText(tester, 'author', updatedAuthor);
    await changeFormText(tester, 'page', updatedPages.toString());
    await changeFormText(tester, 'height', updatedHeight.toString());
    await changeFormText(tester, 'width', updatedWidth.toString());
    await tester.tap(find.widgetWithText(ElevatedButton, '更新する')); // 更新ボタンをクリック
    await tester.pumpAndSettle();
    final updatedBook = await getBookFirst();
    expect(updatedBook.title, updatedTitle);
    expect(updatedBook.author, updatedAuthor);
    expect(updatedBook.pages, updatedPages);
    expect(updatedBook.height, updatedHeight);
    expect(updatedBook.width, updatedWidth);
    expect(updatedBook.coverImagePath, updatedCoverImagePath);
    expect(updatedBook.spineImagePath, updatedSpineImagePath);
  });
}
