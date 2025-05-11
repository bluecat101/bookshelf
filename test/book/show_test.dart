import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bookshelf/book/show.dart';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:bookshelf/book/model/book.dart';
import '../mocks/file_upload_test.mocks.dart';
import '../mocks/file_upload_test_setup.dart';

final mockFileUploader = MockFileUploader();
late Box<Book> bookshelf;
// ダミーデータの作成
Book dummyBook() {
  return Book(
    title: 'sample title',
    author: 'sample author',
    pages: 1,
    height: 1,
    width: 1,
    comment: 'sample comment',
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
  final testDir = Directory(hiveDirPath);
  if (testDir.existsSync()) {
    testDir.deleteSync(recursive: true); // ← 完全削除
  }
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

Future<void> readyShow({required WidgetTester tester, Book? book}) async {
  book ??= dummyBook();
  mockFunctionInit(mockFileUploader); // showを初期化する際に関数が呼ばれるので関数をMockする
  await tester.pumpWidget(
    MaterialApp(home: Show(book: book, fileUploader: mockFileUploader)),
  );
  await tester.pumpAndSettle();
}

Future<void> fileUpload(
  WidgetTester tester,
  FinderBase<Element> uploadButton,
) async {
  await tester.tap(uploadButton);
  await tester.pumpAndSettle();
}

Finder findTextWidgetWithText(String text) {
  // find.widgetWithText(Text, text)改行や空白はないが左のものでうまく行かないため下を起用
  return find.byWidgetPredicate(
    (widget) => widget is Text && widget.data == text,
  );
}

void main() {
  initHive();
  testWidgets('bookのカラム(title,author,height,width,pages,comment)のフォームが存在する', (
    WidgetTester tester,
  ) async {
    mockPickFileSuccess(mockFileUploader);
    final book = dummyBook();
    await tester.pumpWidget(
      MaterialApp(home: Show(book: book, fileUploader: mockFileUploader)),
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
    final String expectedFileName = 'sample_cover_file_path.png';
    await readyShow(tester: tester);
    mockPickFileSuccess(mockFileUploader, filePath: expectedFileName);
    final uploadButton = find.widgetWithText(ElevatedButton, 'アップロード').at(0);
    await fileUpload(tester, uploadButton);
    expect(findTextWidgetWithText(expectedFileName), findsOneWidget);
  });

  testWidgets('[成功時]背表紙の画像のアップロード時、ファイル名が表示される(更新は含まない)', (
    WidgetTester tester,
  ) async {
    final String expectedFileName = 'sample_spine_file_path.png';
    await readyShow(tester: tester);
    mockPickFileSuccess(mockFileUploader, filePath: expectedFileName);

    final uploadButton = find.widgetWithText(ElevatedButton, 'アップロード').at(1);
    await fileUpload(tester, uploadButton);

    expect(findTextWidgetWithText(expectedFileName), findsOneWidget);
  });

  testWidgets('[失敗時]表紙の画像のアップロードの失敗時、失敗したメッセージが表示される', (
    WidgetTester tester,
  ) async {
    final String expectedText = 'アップロードに失敗しました';
    await readyShow(tester: tester);
    mockPickFileFailure(mockFileUploader);

    final uploadButton = find.widgetWithText(ElevatedButton, 'アップロード').at(0);
    await fileUpload(tester, uploadButton);
    expect(findTextWidgetWithText(expectedText), findsOneWidget);
  });
  testWidgets('[失敗時]背表紙の画像のアップロードの失敗時、失敗したメッセージが表示される', (
    WidgetTester tester,
  ) async {
    final String expectedText = 'アップロードに失敗しました';
    await readyShow(tester: tester);
    mockPickFileFailure(mockFileUploader);

    final uploadButton = find.widgetWithText(ElevatedButton, 'アップロード').at(1);
    await fileUpload(tester, uploadButton);

    expect(findTextWidgetWithText(expectedText), findsOneWidget);
  });
  testWidgets('データを更新できるか', (WidgetTester tester) async {
    final book = await getBookFirst();
    await readyShow(tester: tester, book: book);
    final expectedTitle = 'second title';
    final expectedAuthor = 'second author';
    final expectedPages = 2;
    final expectedHeight = 2;
    final expectedWidth = 2;
    final expectedComment = 'second comment';
    final uploadedCoverImagePath = 'sample_cover_image_path.png';
    final uploadedSpineImagePath = 'sample_spine_image_path.png';
    final expectedImagePath = 'sample_image_path.png';
    final coverImageUpdateButton = find
        .widgetWithText(ElevatedButton, 'アップロード')
        .at(0);
    final spineImageUpdateButton = find
        .widgetWithText(ElevatedButton, 'アップロード')
        .at(1);

    await changeTextFormField(tester, 'title', expectedTitle);
    await changeTextFormField(tester, 'author', expectedAuthor);
    await changeTextFormField(tester, 'pages', expectedPages.toString());
    await changeTextFormField(tester, 'height', expectedHeight.toString());
    await changeTextFormField(tester, 'width', expectedWidth.toString());
    await changeTextFormField(tester, 'comment', expectedComment.toString());
    // 2回同じ関数を使って別の返り値を欲するため、ここでmockする
    mockPickFileSuccess(mockFileUploader, filePath: uploadedCoverImagePath);
    await fileUpload(tester, coverImageUpdateButton);
    mockPickFileSuccess(mockFileUploader, filePath: uploadedSpineImagePath);
    await fileUpload(tester, spineImageUpdateButton);
    // アップロード時のMock(同じ関数が連続で実行されるためmockは一度のみでcoverとspineを分けない)
    mockPickFileSuccess(mockFileUploader, resultFilePath: expectedImagePath);
    // スクロールしてから更新ボタンをクリック
    final updateButton = find.widgetWithText(ElevatedButton, '更新する');

    await tester.scrollUntilVisible(
      updateButton,
      100.0,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(updateButton);
    await tester.pumpAndSettle();

    final updatedBook = await getBookFirst();
    expect(updatedBook.title, expectedTitle);
    expect(updatedBook.author, expectedAuthor);
    expect(updatedBook.pages, expectedPages);
    expect(updatedBook.height, expectedHeight);
    expect(updatedBook.width, expectedWidth);
    expect(updatedBook.comment, expectedComment);
    expect(updatedBook.coverImagePath, expectedImagePath);
    expect(updatedBook.spineImagePath, expectedImagePath);
  });
}
