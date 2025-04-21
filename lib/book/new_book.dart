import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bookshelf/book/model/book.dart';
import 'index.dart';

class NewBook extends StatefulWidget {
  const NewBook({super.key});

  @override
  State<NewBook> createState() => _NewBookPageState();
}

class _NewBookPageState extends State<NewBook> {
  final _formKey = GlobalKey<FormState>();
  final _titleKey = GlobalKey<FormFieldState>();

  Future<bool> _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      final title =
          _titleKey.currentState!.value!; // validateの中でnullチェックをしているため!を使用
      final bookshelf = await Hive.openBox<Book>('book');
      final book = Book(title: title);
      bookshelf.add(book);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text('newBook')),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              key: _titleKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(labelText: "title"),
              validator: (value) => Book.validateTitle(value),
            ),
            ElevatedButton(
              child: Text('本棚に追加する'),
              onPressed: () async {
                if (await _onSubmit()) {
                  if (!mounted) return; // 🔒 context が使える状態か確認

                  // 追加する or 本棚を見に行くのダイアログの表示
                  showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        actions: <Widget>[
                          // ボタン領域
                          TextButton(
                            child: Text("追加する"),
                            onPressed:
                                () => {
                                  Navigator.pop(context),
                                  Navigator.of(context).pushReplacement(
                                    PageRouteBuilder(
                                      pageBuilder: (_, __, ___) => NewBook(),
                                      transitionDuration:
                                          Duration.zero, // アニメーションをゼロに
                                    ),
                                  ),
                                },
                          ),

                          TextButton(
                            child: Text("本棚を見に行く"),
                            onPressed:
                                () => {
                                  Navigator.pop(context),
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => Index(),
                                    ),
                                  ),
                                },
                          ),
                        ],
                      );
                    },
                  );
                }
                // Form配下の全てのTextFormFieldのonSavedプロパティが対象（呼び出し）
              },
              // },
            ),
          ],
        ),
      ),
    );
  }
}
