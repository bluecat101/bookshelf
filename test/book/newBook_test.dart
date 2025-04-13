import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bookshelf/book/newBook.dart';

void main() {
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
    await tester.enterText(pageField, 'sample page');
    expect(find.text('sample page'), findsOneWidget);
  });
  testWidgets('高さのフォームが機能するかの確認', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: NewBook()));
    final heightField = find.widgetWithText(TextFormField, 'height');
    await tester.enterText(heightField, 'sample height');
    expect(find.text('sample height'), findsOneWidget);
  });
  testWidgets('厚さのフォームが機能するかの確認', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: NewBook()));
    final thicknessField = find.widgetWithText(TextFormField, 'thickness');
    await tester.enterText(thicknessField, 'sample thickness');
    expect(find.text('sample thickness'), findsOneWidget);
  });
  testWidgets('バリデーションの確認', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: NewBook()));
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(find.text('タイトルを入力してください'), findsOneWidget);
    expect(find.text('著者を入力してください'), findsOneWidget);
    expect(find.text('数字を入れてください'), findsNWidgets(3));
  });
}
