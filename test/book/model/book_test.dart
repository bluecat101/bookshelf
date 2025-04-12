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
  group('著者  バリデーションチェック', () {
    test('著者が空ならエラー', () {
      final result = Book.validateAuthor(null);
      expect(result, '著者を入力してください');
    });
    test('著者が空文字ならエラー', () {
      final result = Book.validateAuthor('');
      expect(result, '著者を入力してください');
    });

    test('著者が正しければ null を返す', () {
      final result = Book.validateAuthor('sample author');
      expect(result, null);
    });
  });
  group('ページ バリデーションチェック', () {
    test('ページが空ならエラー', () {
      final result = Book.validatePage(null);
      expect(result, '数字を入れてください');
    });
    test('ページが数字でないならエラー', () {
      final result = Book.validatePage('string page');
      expect(result, '数字を入れてください');
    });

    test('ページの値が0以下ならエラー', () {
      final result = Book.validatePage("0");
      expect(result, '1以上にしてください');
    });

    test('ページの値が正しければ null を返す', () {
      final result = Book.validatePage('1');
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
      final result = Book.validateHeight('1.1');
      expect(result, null);
    });
  });

  group('厚さ バリデーションチェック', () {
    test('厚さが空ならエラー', () {
      final result = Book.validateThickness(null);
      expect(result, '数字を入れてください');
    });
    test('厚さが数字でないならエラー', () {
      final result = Book.validateThickness('string.thickness'); // 小数点の.を使用
      expect(result, '数字を入れてください');
    });

    test('厚さの値が0以下ならエラー', () {
      final result = Book.validateThickness("0");
      expect(result, '1以上にしてください');
    });

    test('厚さの値が正しければ null を返す', () {
      final result = Book.validateThickness('1.1');
      expect(result, null);
    });
  });
}
