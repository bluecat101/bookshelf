import 'package:bookshelf/book/index.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bookshelf/book/model/book.dart';
import 'package:bookshelf/apis/national_diet_library_api.dart';
import 'dart:math';
import 'package:bookshelf/main.dart';

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
      imageUrl: ndlBook.imageUrl,
      width: bookSize.width!,
      height: bookSize.height!,
      pages: bookSize.pages!,
    );
    bookshelf.add(book);
  }

  // Indexに遷移する関数
  void _navigateToIndex(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder:
            (_, __, ___) => Index(
              booksFuture: Hive.openBox<Book>(
                'book',
              ).then((box) => box.values.toList()),
            ),
        transitionDuration: Duration.zero, // 遷移時のアニメーションをなくす
      ),
    );
  }

  // 本の追加処理をまとめたメソッド
  Future<void> _handleBookButtonPress(
    BuildContext context,
    NdlBook book,
  ) async {
    final BookFetcher bookFetcher = getIt<BookFetcher>();
    var bookSize = await bookFetcher.fetchBookSize(book);

    if (!bookSize.isAllNull) {
      _addBook(book, bookSize);
      _navigateToIndex(context);
      return;
    }

    // nullの部分を入力させるダイアログを表示
    if (mounted) {
      showDialog(
        context: context,
        builder: (_) {
          return _buildDialog(book, bookSize, context);
        },
      );
    }
  }

  Widget setBookImage(NdlBook book) {
    if (book.imageUrl == null) {
      return Container(
        width: 70,
        height: 100,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Text(book.title, style: TextStyle(fontSize: 7)),
      );
    }
    return Image.network(book.imageUrl!, height: 100, fit: BoxFit.fitHeight);
  }

  //表示する1つの本を作成する
  Widget _buildBookRow(NdlBook book) {
    return Row(
      children: [
        setBookImage(book),
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
  AlertDialog _buildDialog(
    NdlBook book,
    BookSize bookSize,
    BuildContext context,
  ) {
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
                    bookSize.width = int.tryParse(widthController.text),
                    bookSize.height = int.tryParse(heightController.text),
                    bookSize.pages = int.tryParse(pagesController.text),
                    if (!bookSize.isAllNull)
                      {_addBook(book, bookSize), _navigateToIndex(context)},
                  },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final BookFetcher bookFetcher = getIt<BookFetcher>();

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
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.zero, // ホバー時に周りを丸くしない
                              ),
                            ),
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
                searchedBooks = await bookFetcher
                    .fetchBookInfoThroughNationalDietLibrary(title);
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
}
