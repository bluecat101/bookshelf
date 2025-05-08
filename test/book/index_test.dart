import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bookshelf/book/index.dart';
import 'package:bookshelf/book/show.dart';
import 'package:bookshelf/book/model/book.dart';

// ダミーデータの作成
Future<List<Book>> dummyBooks() {
  final books = [
    Book(
      title: 'sample title1',
      author: 'sample author1',
      pages: 1,
      height: 1,
      width: 1,
      coverImageUrl: 'https://picsum.photos/200/300',
    ),
    Book(
      title: 'sample title1',
      author: 'sample author1',
      pages: 2,
      height: 2,
      width: 2,
      comment: 'sample comment',
      coverImageUrl: 'https://picsum.photos/200/300',
    ),
  ];
  return Future.value(books);
}

Future<void> displayDialog(WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(home: Index(booksFuture: dummyBooks())));
  await tester.pumpAndSettle(); // タップする前に同期状態にする
  await tester.tap(find.byType(InkWell).at(0)); // 先頭の要素をタップする
  await tester.pumpAndSettle();
}

void main() {
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
