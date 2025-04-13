import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'model/book.dart';

class Index extends StatefulWidget {
  const Index({super.key});

  @override
  State<Index> createState() => _IndexPageState();
}

class _IndexPageState extends State<Index> {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Index')),
      body: FutureBuilder<Box<Book>>(
        // 非同期で Hive の 'book' Box を開く
        future: Hive.openBox<Book>('book'),

        // snapshot は future の状態を表す
        builder: (context, snapshot) {
          // まだデータ（Box）が読み込まれていないときはローディング表示
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          // Box が取得できたら snapshot.data に入っているので取り出す
          final box = snapshot.data!;

          // Hive Box から保存されている本のリストを取得
          final books = box.values.toList();
          if (books.isEmpty) {
            debugPrint('からです');
          }
          return Wrap(
            spacing: 8.0, // アイテム間の横方向のスペース
            runSpacing: 8.0, // 行間のスペース
            children:
                books.map((book) {
                  return InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(title: Text('著者:${book.author}'));
                        },
                      );
                    },
                    child: Container(
                      width: 100, // 必須！サイズ指定しないと見えないことが多い
                      height: 100,
                      color: Color(
                        (Random().nextDouble() * 0xFFFFFF).toInt() << 0,
                      ).withValues(alpha: 1.0),
                      child: Text(
                        book.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          );
        },
      ),
    );
  }
}
