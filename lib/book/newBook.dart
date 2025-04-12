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
  final _authorKey = GlobalKey<FormFieldState>();
  final _pageKey = GlobalKey<FormFieldState>();
  final _heightKey = GlobalKey<FormFieldState>();
  final _thicknessKey = GlobalKey<FormFieldState>();

  Future<bool> _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      final title =
          _titleKey.currentState!.value!; // validateの中でnullチェックをしているため!を使用
      debugPrint(title);
      final author = _authorKey.currentState!.value!;
      final page = int.parse(_pageKey.currentState!.value!);

      final height = double.parse(_heightKey.currentState!.value!);
      final thickness = double.parse(_thicknessKey.currentState!.value!);
      final bookshelf = await Hive.openBox<Book>('book');
      final book = Book(
        title: title,
        author: author,
        page: page,
        height: height,
        thickness: thickness,
      );
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
            TextFormField(
              key: _authorKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(labelText: "author"),
              validator: (value) => Book.validateAuthor(value),
            ),
            TextFormField(
              key: _pageKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(labelText: "page"),
              validator: (value) => Book.validatePage(value),
            ),
            TextFormField(
              key: _heightKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(labelText: "height"),
              validator: (value) => Book.validateHeight(value),
            ),
            TextFormField(
              key: _thicknessKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(labelText: "thickness"),
              validator: (value) => Book.validateThickness(value),
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
