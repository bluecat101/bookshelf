import 'package:bookshelf/book/logic/file_upload.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bookshelf/book/show.dart';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:bookshelf/book/model/book.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart';

import 'show_test.mocks.dart';

late Box<Book> bookshelf;
Future<FileUploader> mockPickFileSuccess({
  String filePath = 'sample_file_path.png',
}) async {
  final fileName = basename(filePath);
  return FileUploader(
    state: FileSelectionState.loadSuccess,
    path: File(filePath),
    fileName: fileName,
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

Future<void> readyShow({
  required WidgetTester tester,
  Book? book,
  Future<FileUploader>? mockPickFile,
}) async {
  book ??= dummyBook();
  mockPickFile ??= mockPickFileSuccess();
  final mockFileUploader = MockFileUploader();
  await tester.pumpWidget(
    MaterialApp(home: Show(book: book, fileUploader: mockFileUploader)),
  );
  when(mockFileUploader.pickFile()).thenAnswer((_) => mockPickFile!);
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
    await readyShow(tester: tester);

    final uploadButton = find.widgetWithText(ElevatedButton, 'アップロード').at(0);
    await fileUpload(tester, uploadButton);

    expect(findTextWidgetWithText(expectedFileName), findsOneWidget);
  });
  testWidgets('[成功時]背表紙の画像のアップロード時、ファイル名が表示される(更新は含まない)', (
    WidgetTester tester,
  ) async {
    final String expectedFileName = (await mockPickFileSuccess()).fileName!;
    await readyShow(tester: tester);

    final uploadButton = find.widgetWithText(ElevatedButton, 'アップロード').at(1);
    await fileUpload(tester, uploadButton);

    expect(findTextWidgetWithText(expectedFileName), findsOneWidget);
  });
  testWidgets('[失敗時]表紙の画像のアップロードの失敗時、失敗したメッセージが表示される', (
    WidgetTester tester,
  ) async {
    final String expectedText = 'アップロードに失敗しました';
    await readyShow(tester: tester, mockPickFile: mockPickFileFailure());

    final uploadButton = find.widgetWithText(ElevatedButton, 'アップロード').at(0);
    await fileUpload(tester, uploadButton);

    expect(findTextWidgetWithText(expectedText), findsOneWidget);
  });
  testWidgets('[失敗時]背表紙の画像のアップロードの失敗時、失敗したメッセージが表示される', (
    WidgetTester tester,
  ) async {
    final String expectedText = 'アップロードに失敗しました';
    await readyShow(tester: tester, mockPickFile: mockPickFileFailure());

    final uploadButton = find.widgetWithText(ElevatedButton, 'アップロード').at(1);
    await fileUpload(tester, uploadButton);

    expect(findTextWidgetWithText(expectedText), findsOneWidget);
  });
  testWidgets('データを更新できるか', (WidgetTester tester) async {
    final book = await getBookFirst();
    final mockFileUploader = MockFileUploader();
    await tester.pumpWidget(
      MaterialApp(home: Show(book: book, fileUploader: mockFileUploader)),
    );
    await tester.pumpAndSettle();
    final updatedTitle = 'second title';
    final updatedAuthor = 'second author';
    final updatedPages = 2;
    final updatedHeight = 2;
    final updatedWidth = 2;
    final updatedComment = 'second comment';
    final updatedCoverImagePath = 'sample_cover_image_path.png';
    final updatedSpineImagePath = 'sample_spine_image_path.png';
    final coverImageUpdateButton = find
        .widgetWithText(ElevatedButton, 'アップロード')
        .at(0);
    final spineImageUpdateButton = find
        .widgetWithText(ElevatedButton, 'アップロード')
        .at(1);
    await changeTextFormField(tester, 'title', updatedTitle);
    await changeTextFormField(tester, 'author', updatedAuthor);
    await changeTextFormField(tester, 'pages', updatedPages.toString());
    await changeTextFormField(tester, 'height', updatedHeight.toString());
    await changeTextFormField(tester, 'width', updatedWidth.toString());
    await changeTextFormField(tester, 'comment', updatedComment.toString());
    // 2回同じ関数を使って別の返り値を欲するため、ここでmockする
    when(
      mockFileUploader.pickFile(),
    ).thenAnswer((_) => mockPickFileSuccess(filePath: updatedCoverImagePath));
    await fileUpload(tester, coverImageUpdateButton);
    when(
      mockFileUploader.pickFile(),
    ).thenAnswer((_) => mockPickFileSuccess(filePath: updatedSpineImagePath));
    await fileUpload(tester, spineImageUpdateButton);
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
    expect(updatedBook.title, updatedTitle);
    expect(updatedBook.author, updatedAuthor);
    expect(updatedBook.pages, updatedPages);
    expect(updatedBook.height, updatedHeight);
    expect(updatedBook.width, updatedWidth);
    expect(updatedBook.comment, updatedComment);
    expect(updatedBook.coverImagePath, updatedCoverImagePath);
    expect(updatedBook.spineImagePath, updatedSpineImagePath);
  });
}
