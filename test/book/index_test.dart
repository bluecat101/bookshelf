import 'package:bookshelf/book/show.dart';
import 'package:bookshelf/helper/image.dart';
import 'package:bookshelf/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bookshelf/book/index.dart';
import 'package:bookshelf/book/model/book.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'index_test.mocks.dart';

late MockImageHelperImpl mockUrlHelperImpl;

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
    return this.index; // enum のインデックス番号（0, 1, 2...）
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
  when(mockUrlHelperImpl.existUrl(any)).thenAnswer((_) async => existUrl);
  when(
    mockUrlHelperImpl.createNetworkImage(any),
  ).thenReturn(AssetImage(sampleUrlImage));
}

Future<void> setupIndexWithBooks({
  Future<List<Book>>? futureBooks,
  required WidgetTester tester,
  required bool existUrl,
  required String displayImage,
}) async {
  futureBooks ??= dummyBooks();
  await readyMockImageHelper(existUrl: existUrl, displayImage: displayImage);
  await tester.pumpWidget(MaterialApp(home: Index(booksFuture: futureBooks)));
  await tester.pumpAndSettle();
}

ImageProvider findImageIn(WidgetTester tester, Finder parentContainer) {
  final imageFinder = find.descendant(
    of: parentContainer,
    matching: find.byType(Image),
  );
  return tester.widget<Image>(imageFinder).image;
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
  tapBookType ??= BookType.hasUrl;
  final tapBookIndex = tapBookType.index;
  await tester.tap(find.byType(InkWell).at(tapBookIndex));
  // pumpAndSettleだと処理が終わらないため
  await tester.pumpAndSettle(const Duration(seconds: 20));
}

void initDI() {
  setUpAll(() async {
    mockUrlHelperImpl = MockImageHelperImpl();
    getIt.registerLazySingleton<ImageHelperImpl>(() => mockUrlHelperImpl);
  });

  tearDownAll(() async {
    getIt.reset();
  });
}

@GenerateMocks([ImageHelperImpl])
void main() {
  initDI();
  testWidgets('[成功時]表紙の画像がURLのみ登録されている時、URLの画像が表示される', (
    WidgetTester tester,
  ) async {
    // urlであるがテスト中はhttpリクエストが400番であるためAssetImageとなる
    final expectImage = AssetImage(sampleUrlImage);
    await setupIndexWithBooks(
      tester: tester,
      existUrl: true,
      displayImage: sampleUrlImage,
    );
    await tapToShowDialog(tester, tapBookType: BookType.hasUrl);
    final image = findImageIn(tester, find.byType(Dialog));

    expect(image, expectImage);
  });

  testWidgets('[成功時]表紙の画像のpathが登録されている時、その画像が表示される', (
    WidgetTester tester,
  ) async {
    final expectImage = AssetImage(sampleLocalImage);
    await setupIndexWithBooks(
      tester: tester,
      existUrl: false,
      displayImage: sampleLocalImage,
    );
    await tapToShowDialog(tester, tapBookType: BookType.hasImagePath);
    final image = findImageIn(tester, find.byType(Dialog));

    expect(image, expectImage);
  });
  testWidgets('[成功時]表紙の画像のURL、pathが登録されていない時、画像が表示されずタイトルが表示される', (
    WidgetTester tester,
  ) async {
    final books = dummyBooks();
    final tapIndex = 2;
    final expectText = (await books)[tapIndex].title;
    await setupIndexWithBooks(
      futureBooks: books,
      tester: tester,
      existUrl: false,
      displayImage: sampleLocalImage,
    );
    await tapToShowDialog(tester, tapBookType: BookType.hasNoUrlAndPath);

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
    final expectImage = AssetImage(sampleLocalImage);
    final targetBookIndex = BookType.hasImagePath.index;
    await setupIndexWithBooks(
      tester: tester,
      existUrl: false,
      displayImage: sampleLocalImage,
    );

    final targetBook = find.byType(ConstrainedBox).at(targetBookIndex);
    final image = findImageIn(tester, targetBook);
    expect(image, expectImage);
  });

  testWidgets('[成功時]背表紙の画像pathが登録されていない時、画像が表示されずタイトルが表示される', (
    WidgetTester tester,
  ) async {
    final books = dummyBooks();
    final targetBookIndex = BookType.hasNoUrlAndPath.index;
    // final bookHeight = (await books)[targetBookIndex].height;
    final expectText = (await books)[targetBookIndex].title;
    await setupIndexWithBooks(
      futureBooks: books,
      tester: tester,
      existUrl: false,
      displayImage: sampleLocalImage,
    );
    final targetBook = find.byType(ConstrainedBox).at(targetBookIndex);

    final textFinder = find.descendant(
      of: targetBook,
      matching: find.byType(Text),
    );
    for (var i = 0; i < textFinder.evaluate().length; i++) {
      final textWidget = tester.widget<Text>(textFinder.at(i));
      expect(textWidget.data, expectText[i]);
    }
  });

  testWidgets('表示されている個数が合っている', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: Index(booksFuture: dummyBooks())),
    );
    await tester.pumpAndSettle();
    final books = await dummyBooks();
    expect(find.byType(InkWell), findsNWidgets(books.length));
  });

  testWidgets('widgetを押した時にダイアログの表示後、キャンセルして元の画面に戻る', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: Index(booksFuture: dummyBooks())),
    );
    await tester.pumpAndSettle();
    await tapToShowDialog(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(Index), findsOneWidget);
  });
  testWidgets('widgetを押した時にダイアログの表示後、showページに遷移できる', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: Index(booksFuture: dummyBooks())),
    );
    await tester.pumpAndSettle();
    await tapToShowDialog(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Show'));
    await tester.pumpAndSettle();
    expect(find.byType(Show), findsOneWidget);
  });
}
