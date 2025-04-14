import 'dart:math';
import 'package:bookshelf/book/show.dart';
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
        future: Hive.openBox<Book>('book'), // 非同期でHiveにアクセス

        builder: (BuildContext context, AsyncSnapshot<Box<Book>> snapshot) {
          if (!snapshot.hasData) {
            // 非同期が完了していなければ、ローディング画面を表示する
            return Center(child: CircularProgressIndicator());
          }

          final box = snapshot.data!; // 非同期でアクセスしたデータを取得
          final books = box.values.toList();
          if (books.isEmpty) {
            debugPrint('からです');
          }
          return Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children:
                books.map((book) {
                  return InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(book.title),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text('著者:${book.author}'),
                                Text('説明: 説明が入ります'), // 本の説明を入れる(まだカラムを未実装)
                              ],
                            ),
                            actions: [
                              TextButton(
                                child: Text("Cancel"),
                                onPressed: () => Navigator.pop(context),
                              ),
                              TextButton(
                                child: Text("Show"),
                                onPressed:
                                    () => {
                                      Navigator.pop(context),
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => Show(),
                                        ),
                                      ),
                                    },
                              ),
                            ],
                          );
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
