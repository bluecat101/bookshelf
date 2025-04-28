import 'package:bookshelf/book/model/book.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class Show extends StatefulWidget {
  final Book book;

  const Show({super.key, required this.book});
  @override
  State<Show> createState() => _ShowPageState();
}

class _ShowPageState extends State<Show> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _pageController;
  late TextEditingController _heightController;
  late TextEditingController _widthController;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.book.title);
    _authorController = TextEditingController(text: widget.book.author);
    _pageController = TextEditingController(text: widget.book.pages.toString());
    _heightController = TextEditingController(
      text: widget.book.height.toString(),
    );
    _widthController = TextEditingController(
      text: widget.book.width.toString(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
    _authorController.dispose();
    _pageController.dispose();
    _heightController.dispose();
    _widthController.dispose();
  }

  Future<(Box<Book>, int)> fetchBookIndex(searchedBook) async {
    final box = await Hive.openBox<Book>('book');
    return (
      box,
      box.values.toList().indexWhere((Book book) => book == searchedBook),
    );
  }

  Future<void> updateBook(Book updatedBook) async {
    final (box, index) = await fetchBookIndex(updatedBook);
    if (index != -1) {
      await box.put(index, updatedBook);
    }
  }

  Future<bool> _deleteBook(Book deletedBook) async {
    final (box, index) = await fetchBookIndex(deletedBook);
    if (index != -1) {
      box.delete(index);
      return true;
    }
    return false;
  }

  Future<bool> _onSubmit(Book book) async {
    if (_formKey.currentState!.validate()) {
      book.title = _titleController.text;
      book.author = _authorController.text;
      book.pages = int.parse(_pageController.text);
      book.height = int.parse(_heightController.text);
      book.width = int.parse(_widthController.text);
      await updateBook(book);
      return true;
    }
    return false;
  }

  String? getHelperTextForComparison(String lastText, String currentText) {
    // 数値比較のための共通関数
    String? compareTextValues<T>(T lastValue, T currentValue) {
      return lastValue != currentValue ? '前回の内容: $lastValue' : null;
    }

    // 数値（int, int）と文字列を比較
    if (int.tryParse(lastText) != null && int.tryParse(currentText) != null) {
      return compareTextValues<int>(
        int.parse(lastText),
        int.parse(currentText),
      );
    }

    // 文字列として直接比較
    return compareTextValues<String>(lastText, currentText);
  }

  TextFormField generateTextFormField(
    // initValueを関数内で定義すると、controller.textと一緒になるため、外部で定義して渡す
    TextEditingController controller,
    String label,
    String? initValue,
  ) {
    return TextFormField(
      controller: controller,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        helperStyle: TextStyle(color: const Color.fromARGB(255, 25, 104, 233)),
        helperText: getHelperTextForComparison(
          initValue.toString(),
          controller.text,
        ),
      ),
      onChanged: (text) {
        setState(() {});
      },
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
            generateTextFormField(
              _pageController,
              'page',
              book.pages?.toString(),
            ),
            generateTextFormField(
              _heightController,
              'height',
              book.height?.toString(),
            ),
            generateTextFormField(
              _widthController,
              'width',
              book.width?.toString(),
            ),
            Row(
              children: [
                ElevatedButton(
                  child: Text('戻る'),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  child: Text('削除する'),
                  onPressed: () async {
                    if (await _deleteBook(book)) {
                      if (!mounted) return;
                      Navigator.pop(context);
                    }
                  },
                ),
                ElevatedButton(
                  child: Text('更新する'),
                  onPressed: () async {
                    if (await _onSubmit(book)) {
                      if (!mounted) return;
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
