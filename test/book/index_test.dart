import 'dart:io';

import 'package:bookshelf/book/show.dart';
import 'package:bookshelf/helper/image.dart';
import 'package:bookshelf/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bookshelf/book/index.dart';
import 'package:bookshelf/book/model/book.dart';
import '../mocks/image_helper_test.mocks.dart';
import '../mocks/image_helper_test_setup.dart';

late MockImageHelperImpl mockImageHelper;

const sampleLocalImage = 'test/assets/test_image.png';
// testで実際のhttpリクエストを送ると400番になるため画像はローカルに保存しておく
const sampleUrlImage = 'test/assets/test_url_image.png';

Book makeDummyBook({
  String title = 'sample title',
  String author = 'sample author',
  int pages = 100,
  int height = 20,
  int width = 10,
  String? coverImageUrl,
  String? coverImagePath,
  String? spineImagePath,
}) {
  return Book(
    title: title,
    author: author,
    pages: pages,
    height: height,
    width: width,
    coverImageUrl: coverImageUrl,
    coverImagePath: coverImagePath,
    spineImagePath: spineImagePath,
  );
}

enum BookType { hasUrl, hasImagePath, hasNoUrlAndPath }

extension BookTypeExtension on BookType {
  int get index {
    return this.index;
  }
}

Future<List<Book>> dummyBooks() async {
  return [
    // URLのみ
    makeDummyBook(coverImageUrl: sampleUrlImage),
    // 画像のpathを持っている
    makeDummyBook(
      coverImagePath: sampleLocalImage,
      spineImagePath: sampleLocalImage,
    ),
    // 画像なし
    makeDummyBook(),
  ];
}

Future<void> readyMockImageHelper({
  required bool existUrl,
  required String displayImage,
}) async {
  mockExistUrl(mockImageHelper, existUrl);
  mockCreateNetworkImage(mockImageHelper, displayImage);
}

Future<void> setupIndexWithBooks({
  Future<List<Book>>? futureBooks,
  required WidgetTester tester,
  bool existUrl = false,
  String displayImage = sampleUrlImage,
}) async {
  futureBooks ??= dummyBooks();
  await readyMockImageHelper(existUrl: existUrl, displayImage: displayImage);
  await tester.pumpWidget(MaterialApp(home: Index(booksFuture: futureBooks)));
  await tester.pumpAndSettle();
}

Finder findImageIn(WidgetTester tester, Finder parentContainer) {
  return find.descendant(of: parentContainer, matching: find.byType(Image));
}

Finder findTextIn({
  required WidgetTester tester,
  required Finder parentContainer,
  required String text,
}) {
  return find.descendant(
    of: parentContainer,
    matching: find.byWidgetPredicate(
      (widget) => widget is Text && widget.data == text,
    ),
  );
}

Future<void> tapToShowDialog(
  WidgetTester tester, {
  BookType? tapBookType,
}) async {
  final tapBookIndex = (tapBookType ?? BookType.hasUrl).index;
  await tester.tap(find.byType(InkWell).at(tapBookIndex));
  // pumpAndSettleだと処理が終わらないため
  await tester.pumpAndSettle(const Duration(seconds: 20));
}

Future<void> tapTextButton(WidgetTester tester, String textInButton) async {
  await tester.tap(find.widgetWithText(TextButton, textInButton));
  await tester.pumpAndSettle();
}

void initDI() {
  setUpAll(() async {
    mockImageHelper = MockImageHelperImpl();
    getIt.registerLazySingleton<ImageHelperImpl>(() => mockImageHelper);
  });

  tearDownAll(() async {
    getIt.reset();
  });
}

void main() {
  initDI();
  testWidgets('[成功時]表紙の画像がURLのみ登録されている時、URLの画像が表示される', (
    WidgetTester tester,
  ) async {
    //  Arrange
    // urlであるがテスト中はhttpリクエストが400番であるためAssetImageとなる
    final expectImage = FileImage(File(sampleUrlImage));
    await setupIndexWithBooks(
      tester: tester,
      existUrl: true,
      displayImage: sampleUrlImage,
    );
    // Act
    await tapToShowDialog(tester, tapBookType: BookType.hasUrl);
    // Assert
    final imageFinder = findImageIn(tester, find.byType(Dialog));
    expect(tester.widget<Image>(imageFinder).image, expectImage);
  });

  testWidgets('[成功時]表紙の画像のpathが登録されている時、その画像が表示される', (
    WidgetTester tester,
  ) async {
    // Arrange
    final expectImage = FileImage(File(sampleLocalImage));
    await setupIndexWithBooks(
      tester: tester,
      existUrl: false,
      displayImage: sampleLocalImage,
    );

    // Act
    await tapToShowDialog(tester, tapBookType: BookType.hasImagePath);

    // Assert
    final imageFinder = findImageIn(tester, find.byType(Dialog));
    expect(tester.widget<Image>(imageFinder).image, expectImage);
  });
  testWidgets('[成功時]表紙の画像のURL、pathが登録されていない時、画像が表示されずタイトルが表示される', (
    WidgetTester tester,
  ) async {
    // Arrange
    final books = dummyBooks();
    final tapIndex = 2;
    final expectText = (await books)[tapIndex].title;
    await setupIndexWithBooks(
      futureBooks: books,
      tester: tester,
      existUrl: false,
      displayImage: sampleLocalImage,
    );
    // Act
    await tapToShowDialog(tester, tapBookType: BookType.hasNoUrlAndPath);

    // Assert
    final textFinder = findTextIn(
      tester: tester,
      parentContainer: find.byType(Dialog),
      text: expectText,
    );
    expect(textFinder, findsNWidgets(2));
  });

  testWidgets('[成功時]背表紙の画像のpathが登録されている時、その画像が表示される', (
    WidgetTester tester,
  ) async {
    // Arrange
    final expectImage = FileImage(File(sampleLocalImage));
    final targetBookIndex = BookType.hasImagePath.index;
    await setupIndexWithBooks(
      tester: tester,
      existUrl: false,
      displayImage: sampleLocalImage,
    );
    // Act
    final targetBook = find.byType(InkWell).at(targetBookIndex);
    final imageFinder = findImageIn(tester, targetBook);

    // Assert
    expect(tester.widget<Image>(imageFinder).image, expectImage);
  });

  testWidgets('[成功時]背表紙の画像pathが登録されていない時、画像が表示されずタイトルが表示される', (
    WidgetTester tester,
  ) async {
    // Arrange
    final books = dummyBooks();
    final targetBookIndex = BookType.hasNoUrlAndPath.index;
    final expectText = (await books)[targetBookIndex].title;
    await setupIndexWithBooks(
      futureBooks: books,
      tester: tester,
      existUrl: false,
      displayImage: sampleLocalImage,
    );

    // Assert
    final targetBook = find.byType(InkWell).at(targetBookIndex);
    final textFinder = find.descendant(
      of: targetBook,
      matching: find.byType(Text),
    );
    for (var i = 0; i < textFinder.evaluate().length; i++) {
      final textWidget = tester.widget<Text>(textFinder.at(i));
      expect(textWidget.data, expectText[i]);
    }
  });

  testWidgets('[成功時]表示されている個数が合っている', (WidgetTester tester) async {
    // Arrange
    final books = dummyBooks();
    await tester.pumpWidget(MaterialApp(home: Index(booksFuture: books)));
    await tester.pumpAndSettle();
    // Assert
    expect(find.byType(InkWell), findsNWidgets((await books).length));
  });

  testWidgets('[成功時]widgetを押した時にダイアログの表示後、キャンセルして元の画面に戻る', (
    WidgetTester tester,
  ) async {
    // Arrange
    await setupIndexWithBooks(tester: tester);
    // Act
    await tapToShowDialog(tester);
    await tapTextButton(tester, 'Cancel');
    // Assert
    expect(find.byType(Index), findsOneWidget);
  });
  testWidgets('[成功時]widgetを押した時にダイアログの表示後、showページに遷移できる', (
    WidgetTester tester,
  ) async {
    // Arrange
    await setupIndexWithBooks(tester: tester);
    // Act
    await tapToShowDialog(tester);
    await tapTextButton(tester, 'Show');
    // Assert
    expect(find.byType(Show), findsOneWidget);
  });
}
