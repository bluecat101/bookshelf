import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bookshelf/book/model/book.dart';
import 'index.dart';
import 'package:bookshelf/apis/national_diet_library_api.dart';

class NewBook extends StatefulWidget {
  const NewBook({super.key});

  @override
  State<NewBook> createState() => _NewBookPageState();
}

class _NewBookPageState extends State<NewBook> {
  final _formKey = GlobalKey<FormState>();
  final _titleKey = GlobalKey<FormFieldState>();
  List<NdlBook> searchedBooks = [];

  void addBook(NdlBook ndlBook, int width, int height, int page) async {
    final bookshelf = await Hive.openBox<Book>('book');
    final book = Book(
      title: ndlBook.title,
      author: ndlBook.author,
      width: width,
      height: height,
      page: page,
    );
    bookshelf.add(book);
  }

  List<TextField> returnTextFiledToNullColumn(
    int? width,
    int? height,
    int? page,
    TextEditingController widthController,
    TextEditingController heightController,
    TextEditingController pageController,
  ) {
    List<String> label = [];
    List<TextField> TextFields = [];
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

    if (width == null) {
      label.add('width');
      TextFields.add(generateTextField(widthController, 'width'));
    }
    if (height == null) {
      label.add('height');
      TextFields.add(generateTextField(heightController, 'height'));
    }
    if (page == null) {
      label.add('page');
      TextFields.add(generateTextField(pageController, 'page'));
    }
    return TextFields;
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
                // physics: NeverScrollableScrollPhysics(),
                // Column(
                children:
                    searchedBooks
                        .map(
                          (book) => TextButton(
                            onPressed: () async {
                              final size = await fetchBookSize(book);
                              if (size.width != null &&
                                  size.height != null &&
                                  size.page != null) {
                                addBook(
                                  book,
                                  size.width!,
                                  size.height!,
                                  size.page!,
                                );
                                return;
                              }
                              final _widthController = TextEditingController(
                                text: size.width?.toString(),
                              );
                              final _heightController = TextEditingController(
                                text: size.height?.toString(),
                              );
                              final _pageController = TextEditingController(
                                text: size.page?.toString(),
                              );
                              showDialog(
                                context: context,
                                builder: (_) {
                                  return AlertDialog(
                                    actions: <Widget>[
                                      Row(
                                        children: returnTextFiledToNullColumn(
                                          size.width,
                                          size.height,
                                          size.page,
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
                                                  addBook(
                                                    book,
                                                    size.width!,
                                                    size.height!,
                                                    size.page!,
                                                  ),
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
            // ElevatedButton(
            //   child: Text('本棚に追加する'),
            //   onPressed: () async {
            //     if (await _onSubmit()) {
            //       if (!mounted) return; // 🔒 context が使える状態か確認

            //       // 追加する or 本棚を見に行くのダイアログの表示
            //       showDialog(
            //         context: context,
            //         builder: (_) {
            //           return AlertDialog(
            //             actions: <Widget>[
            //               // ボタン領域
            //               TextButton(
            //                 child: Text("追加する"),
            //                 onPressed:
            //                     () => {
            //                       Navigator.pop(context),
            //                       Navigator.of(context).pushReplacement(
            //                         PageRouteBuilder(
            //                           pageBuilder: (_, __, ___) => NewBook(),
            //                           transitionDuration:
            //                               Duration.zero, // アニメーションをゼロに
            //                         ),
            //                       ),
            //                     },
            //               ),

            //               TextButton(
            //                 child: Text("本棚を見に行く"),
            //                 onPressed:
            //                     () => {
            //                       Navigator.pop(context),
            //                       Navigator.of(context).push(
            //                         MaterialPageRoute(
            //                           builder: (context) => Index(),
            //                         ),
            //                       ),
            //                     },
            //               ),
            //             ],
            //           );
            //         },
            //       );
            //     }
            //     // Form配下の全てのTextFormFieldのonSavedプロパティが対象（呼び出し）
            //   },
            //   // },
            // ),
          ],
        ),
      ),
    );
  }
}
