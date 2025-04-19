import 'package:hive/hive.dart';
import 'dart:typed_data';

//Entity生成用
part 'book.g.dart';

//モデルごとの識別子の設定
@HiveType(typeId: 1)
class Book {
  Book({
    required this.title,
    required this.author,
    required this.page,
    required this.height,
    required this.thickness,
    this.image,
  });
  @HiveField(0)
  String title;

  @HiveField(1)
  String author;

  @HiveField(2)
  int page;

  @HiveField(3)
  double height;

  @HiveField(4)
  double thickness;

  // 数が増えると画像をここに保存せずにpathを保存し呼び出す。
  @HiveField(5)
  Uint8List? image;

  static String? validateTitle(String? value) {
    if (value == null || value.isEmpty) return 'タイトルを入力してください';
    return null;
  }

  static String? validateAuthor(String? value) {
    if (value == null || value.isEmpty) return '著者を入力してください';
    return null;
  }

  static String? validatePage(String? value) {
    if (value == null || int.tryParse(value) == null) return '数字を入れてください';
    final parsedValue = int.parse(value);
    if (parsedValue < 1) return '1以上にしてください';
    return null;
  }

  static String? validateHeight(String? value) {
    if (value == null || double.tryParse(value) == null) return '数字を入れてください';
    final parsedValue = double.parse(value);
    if (parsedValue < 1) return '1以上にしてください';
    return null;
  }

  static String? validateThickness(String? value) {
    if (value == null || double.tryParse(value) == null) return '数字を入れてください';
    final parsedValue = double.parse(value);
    if (parsedValue < 1) return '1以上にしてください';
    return null;
  }
}
