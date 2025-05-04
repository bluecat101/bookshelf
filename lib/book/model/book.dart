import 'package:hive/hive.dart';
part 'book.g.dart';

@HiveType(typeId: 1)
class Book {
  Book({
    required this.title,
    required this.author,
    required this.pages,
    required this.height,
    required this.width,
    this.comment,
    this.imageUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
  @HiveField(0)
  String title;

  @HiveField(1)
  String author;

  @HiveField(2)
  int pages;

  @HiveField(3)
  int height;

  @HiveField(4)
  int width;

  @HiveField(5)
  String? comment;

  @HiveField(6)
  String? imageUrl;

  @HiveField(7)
  DateTime createdAt;

  static String? validateTitle(String? value) {
    if (value == null || value.isEmpty) return 'タイトルを入力してください';
    return null;
  }

  static String? validatePages(String? value) {
    if (value == null || int.tryParse(value) == null) return '数字を入れてください';
    final parsedValue = int.parse(value);
    if (parsedValue < 1) return '1以上にしてください';
    return null;
  }

  static String? validateHeight(String? value) {
    if (value == null || int.tryParse(value) == null) return '数字を入れてください';
    final parsedValue = int.parse(value);
    if (parsedValue < 1) return '1以上にしてください';
    return null;
  }

  static String? validateWidth(String? value) {
    if (value == null || int.tryParse(value) == null) return '数字を入れてください';
    final parsedValue = int.parse(value);
    if (parsedValue < 1) return '1以上にしてください';
    return null;
  }
}
