import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bookshelf/book/model/book.dart';
import 'package:bookshelf/apis/national_diet_library_api.dart';
import 'dart:math';

class NewBook extends StatefulWidget {
  const NewBook({super.key});

  @override
  State<NewBook> createState() => _NewBookPageState();
}

class _NewBookPageState extends State<NewBook> {
  final _formKey = GlobalKey<FormState>();
  final _titleKey = GlobalKey<FormFieldState>();
  List<NdlBook> searchedBooks = [];

  // DBにbookを追加する関数
  void _addBook(NdlBook ndlBook, BookSize bookSize) async {
    final bookshelf = await Hive.openBox<Book>('book');
    final book = Book(
      title: ndlBook.title,
      author: ndlBook.author,
      width: bookSize.width!,
      height: bookSize.height!,
      page: bookSize.pages!,
    );
    bookshelf.add(book);
  }

  // Indexに遷移する関数
  void _navigateToIndex() {
    Navigator.pop(context);
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => NewBook(),
        transitionDuration: Duration.zero, // 遷移時のアニメーションをなくす
      ),
    );
  }

  // 本の追加処理をまとめたメソッド
  Future<void> _handleBookButtonPress(
    BuildContext context,
    NdlBook book,
  ) async {
    var bookSize = await fetchBookSize(book);

    if (!bookSize.isAllNull) {
      _addBook(book, bookSize);
      _navigateToIndex();
      return;
    }

    // nullの部分を入力させるダイアログを表示
    if (mounted) {
      showDialog(
        context: context,
        builder: (_) {
          return _buildDialog(book, bookSize);
        },
      );
    }
  }

  //表示する1つの本を作成する
  Widget _buildBookRow(NdlBook book) {
    return Row(
      children: [
        Image.network(book.imageUrl, height: 100, fit: BoxFit.fitHeight),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(book.title, overflow: TextOverflow.ellipsis, maxLines: 1),
              Text(book.author, overflow: TextOverflow.ellipsis, maxLines: 1),
            ],
          ),
        ),
      ],
    );
  }

  // bookSizeの値がnullの場合に入力用ダイアログ
  AlertDialog _buildDialog(book, BookSize bookSize) {
    // bookSizeがnullのものの入力用TextField
    List<SizedBox> buildTextFields(
      BookSize bookSize,
      TextEditingController widthController,
      TextEditingController heightController,
      TextEditingController pagesController,
    ) {
      List<SizedBox> textFields = [];
      TextField generateTextField(
        TextEditingController controller,
        String label,
      ) {
        return TextField(
          keyboardType: TextInputType.number,
          controller: controller,
          decoration: InputDecoration(labelText: label),
        );
      }

      // 幅を制御するためにSizeBoxを使用する
      SizedBox buildSizeBox(String label, TextEditingController controller) {
        final containerWidth =
            min(MediaQuery.of(context).size.width / 2 * 0.75, 100).toDouble();
        return SizedBox(
          width: containerWidth,
          child: generateTextField(controller, label),
        );
      }

      if (bookSize.width == null) {
        textFields.add(buildSizeBox('width', widthController));
      }
      if (bookSize.height == null) {
        textFields.add(buildSizeBox('height', heightController));
      }
      if (bookSize.pages == null) {
        textFields.add(buildSizeBox('pages', pagesController));
      }
      return textFields;
    }

    // controllerを初期化する
    final widthController = TextEditingController(
      text: bookSize.width?.toString(),
    );
    final heightController = TextEditingController(
      text: bookSize.height?.toString(),
    );
    final pagesController = TextEditingController(
      text: bookSize.pages?.toString(),
    );
    return AlertDialog(
      actions: <Widget>[
        Row(
          children: [
            Column(
              children: buildTextFields(
                bookSize,
                widthController,
                heightController,
                pagesController,
              ),
            ),
            TextButton(
              child: Text("追加する"),
              onPressed:
                  () => {
                    if (widthController.text.isNotEmpty &&
                        heightController.text.isNotEmpty &&
                        pagesController.text.isNotEmpty)
                      {_addBook(book, bookSize), _navigateToIndex()},
                  },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('newBook')),
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
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children:
                    searchedBooks
                        .map(
                          (book) => TextButton(
                            onPressed:
                                () => _handleBookButtonPress(context, book),
                            child: _buildBookRow(book),
                          ),
                        )
                        .toList(),
              ),
            ),
            ElevatedButton(
              child: Text("検索する"),
              onPressed: () async {
                if (!_formKey.currentState!.validate()) {
                  return;
                }
                final title = _titleKey.currentState!.value!;
                searchedBooks = await fetchBookInfoThroughNationalDietLibrary(
                  title,
                );
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
}
