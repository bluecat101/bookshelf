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

  void addBook(NdlBook ndlBook, BookSize bookSize) async {
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

  List<Container> returnTextFiledToNullColumn(
    BookSize bookSize,
    TextEditingController widthController,
    TextEditingController heightController,
    TextEditingController pageController,
  ) {
    List<String> label = [];
    List<Container> containers = [];
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

    final containerWidth =
        min(MediaQuery.of(context).size.width / 2 * 0.75, 100).toDouble();
    if (bookSize.width == null) {
      label.add('width');
      containers.add(
        Container(
          width: containerWidth,
          child: generateTextField(widthController, 'width'),
        ),
      );
    }
    if (bookSize.height == null) {
      label.add('height');
      containers.add(
        Container(
          width: containerWidth,
          child: generateTextField(heightController, 'height'),
        ),
      );
    }
    if (bookSize.pages == null) {
      label.add('page');
      containers.add(
        Container(
          width: containerWidth,
          child: generateTextField(pageController, 'page'),
        ),
      );
    }
    debugPrint(containers.toString());
    debugPrint(
      bookSize.width.toString() +
          bookSize.height.toString() +
          bookSize.pages.toString(),
    );

    return containers;
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
                            onPressed: () async {
                              var bookSize = await fetchBookSize(book);
                              if (!bookSize.isAllNull) {
                                addBook(book, bookSize);
                                return;
                              }
                              final _widthController = TextEditingController(
                                text: bookSize.width?.toString(),
                              );
                              final _heightController = TextEditingController(
                                text: bookSize.height?.toString(),
                              );
                              final _pageController = TextEditingController(
                                text: bookSize.pages?.toString(),
                              );
                              showDialog(
                                context: context,
                                builder: (_) {
                                  return AlertDialog(
                                    actions: <Widget>[
                                      Row(
                                        children: [
                                          Column(
                                            children:
                                                returnTextFiledToNullColumn(
                                                  bookSize,
                                                  _widthController,
                                                  _heightController,
                                                  _pageController,
                                                ),
                                          ),

                                          // ボタン領域
                                          TextButton(
                                            child: Text("追加する"),
                                            onPressed:
                                                () => {
                                                  if ([
                                                    _widthController.text,
                                                    _heightController.text,
                                                    _pageController.text,
                                                  ].every((e) => e != ""))
                                                    {
                                                      addBook(book, bookSize),
                                                      Navigator.pop(context),
                                                      Navigator.of(
                                                        context,
                                                      ).pushReplacement(
                                                        PageRouteBuilder(
                                                          pageBuilder:
                                                              (_, __, ___) =>
                                                                  NewBook(),
                                                          transitionDuration:
                                                              Duration
                                                                  .zero, // アニメーションをゼロに
                                                        ),
                                                      ),
                                                    },
                                                },
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Row(
                              children: [
                                Image.network(
                                  book.imageUrl,
                                  height: 100,
                                  fit: BoxFit.fitHeight,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        book.title,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      Text(
                                        book.author,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
