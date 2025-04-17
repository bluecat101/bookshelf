import 'package:bookshelf/book/model/book.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class Show extends StatefulWidget {
  Book book;

  Show({super.key, required this.book});
  @override
  State<Show> createState() => _ShowPageState();
}

class _ShowPageState extends State<Show> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _pageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _thicknessController = TextEditingController();
  Future<bool> _onSubmit(Book book) async {
    if (_formKey.currentState!.validate()) {
      book.title = _titleController.text;
      book.author = _authorController.text;
      book.page = int.parse(_pageController.text);
      book.height = double.parse(_heightController.text);
      book.thickness = double.parse(_thicknessController.text);
      final bookshelf = await Hive.openBox<Book>('book');
      // await book.save();
      bookshelf.add(book);
      return true;
    }
    return false;
  }

  TextFormField generateTextFormField(
    TextEditingController controller,
    String label,
    initValue,
  ) {
    return TextFormField(
      initialValue: initValue,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        helperText: controller.text != initValue ? '前回の内容: $initValue' : null,
      ),
      validator: (value) => Book.validateTitle(value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    return Scaffold(
      appBar: AppBar(title: Text('show')),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            generateTextFormField(_titleController, 'title', book.title),
            generateTextFormField(_authorController, 'author', book.author),
            generateTextFormField(_pageController, 'page', book.page),
            generateTextFormField(_heightController, 'height', book.height),
            generateTextFormField(
              _thicknessController,
              'thickness',
              book.thickness,
            ),
            ElevatedButton(
              child: Text('本棚に追加する'),
              onPressed: () async {
                if (await _onSubmit()) {
                  if (!mounted) return; // 🔒 context が使える状態か確認
                }
                ;
              },
            ),
          ],
        ),
      ),
    );
  }
}
