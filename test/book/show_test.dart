import 'package:bookshelf/book/logic/file_upload.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bookshelf/book/show.dart';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:bookshelf/book/model/book.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'show_test.mocks.dart';

late Box<Book> bookshelf;
Future<FileUploader> mockPickFileSuccess() async {
  return FileUploader(
    state: FileSelectionState.loadSuccess,
    path: File('sample_file_path.png'),
    fileName: 'sample_file_path',
  );
}

Future<FileUploader> mockPickFileFailure() async {
  return FileUploader(state: FileSelectionState.loadFailure);
}

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

Future<void> changeTextFormField(
  WidgetTester tester,
  String targetFormLabel,
  String changedText,
) async {
  final fieldFinder = find.widgetWithText(TextFormField, targetFormLabel);
  await tester.enterText(fieldFinder, changedText);
  await tester.pumpAndSettle();
}

Future<void> uploadFile(
  WidgetTester tester,
  FinderBase<Element> uploadButton,
  Future<FileUploader> mockPickFile,
) async {
  final book = dummyBook();
  final mockFileUploader = MockFileUploader();
  when(mockFileUploader.pickFile()).thenAnswer((_) async => mockPickFile);
  await tester.pumpWidget(
    MaterialApp(home: Show(book: book, fileUploader: mockFileUploader)),
  );
  await tester.tap(uploadButton);
  await tester.pumpAndSettle();
}

Finder findTextWidgetWithText(String text) {
  // find.widgetWithText(Text, text)改行や空白はないが左のものでうまく行かないため下を起用
  return find.byWidgetPredicate(
    (widget) => widget is Text && widget.data == text,
  );
}

@GenerateMocks([FileUploader])
void main() {
  initHive();
  testWidgets('bookのカラム(title,author,height,width,pages,comment)のフォームが存在する', (
    WidgetTester tester,
  ) async {
    final book = dummyBook();
    await tester.pumpWidget(
      MaterialApp(home: Show(book: book, fileUploader: MockFileUploader())),
    );
    expect(find.widgetWithText(TextFormField, 'title'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'author'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'height'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'width'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'pages'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'comment'), findsOneWidget);
  });

  testWidgets('[成功時]表紙の画像のアップロード時、ファイル名が表示される(更新は含まない)', (
    WidgetTester tester,
  ) async {
    final String expectedFileName = (await mockPickFileSuccess()).fileName!;
    final uploadButton = find.widgetWithText(ElevatedButton, 'アップロード').at(0);

    await uploadFile(tester, uploadButton, mockPickFileSuccess());
    await tester.pumpAndSettle();
    expect(findTextWidgetWithText(expectedFileName), findsOneWidget);
  });
  testWidgets('[成功時]背表紙の画像のアップロード時、ファイル名が表示される(更新は含まない)', (
    WidgetTester tester,
  ) async {
    final String expectedFileName = (await mockPickFileSuccess()).fileName!;
    final uploadButton = find.widgetWithText(ElevatedButton, 'アップロード').at(1);

    await uploadFile(tester, uploadButton, mockPickFileSuccess());
    expect(findTextWidgetWithText(expectedFileName), findsOneWidget);
  });
  testWidgets('[失敗時]表紙の画像のアップロードの失敗時、失敗したメッセージが表示される', (
    WidgetTester tester,
  ) async {
    final String expectedText = 'アップロードに失敗しました';
    final uploadButton = find.widgetWithText(ElevatedButton, 'アップロード').at(0);
    await uploadFile(tester, uploadButton, mockPickFileFailure());

    expect(findTextWidgetWithText(expectedText), findsOneWidget);
  });
  testWidgets('[失敗時]背表紙の画像のアップロードの失敗時、失敗したメッセージが表示される', (
    WidgetTester tester,
  ) async {
    final String expectedText = 'アップロードに失敗しました';
    final uploadButton = find.widgetWithText(ElevatedButton, 'アップロード').at(1);

    await uploadFile(tester, uploadButton, mockPickFileFailure());
    expect(findTextWidgetWithText(expectedText), findsOneWidget);
  });
  testWidgets('データを更新できるか', (WidgetTester tester) async {
    final book = await getBookFirst();
    final mockFileUploader = MockFileUploader();
    final updatedTitle = 'second title';
    final updatedAuthor = 'second author';
    final updatedPages = 2;
    final updatedHeight = 2;
    final updatedWidth = 2;
    final updatedCoverImagePath = '';
    final updatedSpineImagePath = '';
    await tester.pumpWidget(
      MaterialApp(home: Show(book: book, fileUploader: mockFileUploader)),
    );
    await changeTextFormField(tester, 'title', updatedTitle);
    await changeTextFormField(tester, 'author', updatedAuthor);
    await changeTextFormField(tester, 'pages', updatedPages.toString());
    await changeTextFormField(tester, 'height', updatedHeight.toString());
    await changeTextFormField(tester, 'width', updatedWidth.toString());
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
