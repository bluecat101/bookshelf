import 'package:hive/hive.dart';
import 'dart:typed_data';

//Entity生成用
part 'book.g.dart';

//モデルごとの識別子の設定
@HiveType(typeId: 1)
class Book {
  const Book({
    required this.title,
    required this.author,
    required this.page,
    required this.height,
    required this.thickness,
    this.image,
  });
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String author;

  @HiveField(2)
  final int page;

  @HiveField(3)
  final double height;

  @HiveField(4)
  final double thickness;

  // 数が増えると画像をここに保存せずにpathを保存し呼び出す。
  @HiveField(5)
  final Uint8List? image;
}
