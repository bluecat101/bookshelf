import 'package:flutter_test/flutter_test.dart';
import 'package:bookshelf/book/model/book.dart';

void main() {
  group('タイトル バリデーションチェック', () {
    test('タイトルが空ならエラー', () {
      final result = Book.validateTitle(null);
      expect(result, 'タイトルを入力してください');
    });

    test('タイトルが空文字ならエラー', () {
      final result = Book.validateTitle('');
      expect(result, 'タイトルを入力してください');
    });

    test('タイトルが正しければ null を返す', () {
      final result = Book.validateTitle('sample title');
      expect(result, null);
    });
  });

  group('ページ バリデーションチェック', () {
    test('ページが空ならエラー', () {
      final result = Book.validatePages(null);
      expect(result, '数字を入れてください');
    });
    test('ページが数字でないならエラー', () {
      final result = Book.validatePages('string page');
      expect(result, '数字を入れてください');
    });

    test('ページの値が0以下ならエラー', () {
      final result = Book.validatePages("0");
      expect(result, '1以上にしてください');
    });

    test('ページの値が正しければ null を返す', () {
      final result = Book.validatePages('1');
      expect(result, null);
    });
  });

  group('高さ バリデーションチェック', () {
    test('高さが空ならエラー', () {
      final result = Book.validateHeight(null);
      expect(result, '数字を入れてください');
    });
    test('高さが数字でないならエラー', () {
      final result = Book.validateHeight('string.height'); // 小数点の.を使用
      expect(result, '数字を入れてください');
    });

    test('高さの値が0以下ならエラー', () {
      final result = Book.validateHeight("0");
      expect(result, '1以上にしてください');
    });

    test('高さの値が正しければ null を返す', () {
      final result = Book.validateHeight('1');
      expect(result, null);
    });
  });

  group('厚さ バリデーションチェック', () {
    test('厚さが空ならエラー', () {
      final result = Book.validateWidth(null);
      expect(result, '数字を入れてください');
    });
    test('厚さが数字でないならエラー', () {
      final result = Book.validateWidth('string.width'); // 小数点の.を使用
      expect(result, '数字を入れてください');
    });

    test('厚さの値が0以下ならエラー', () {
      final result = Book.validateWidth("0");
      expect(result, '1以上にしてください');
    });

    test('厚さの値が正しければ null を返す', () {
      final result = Book.validateWidth('1');
      expect(result, null);
    });
  });
}
