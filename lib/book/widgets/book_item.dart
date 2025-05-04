import 'package:bookshelf/book/model/book.dart';
import 'package:bookshelf/book/widgets/book_helpers.dart';
import 'package:flutter/material.dart';

class BookItem extends StatefulWidget {
  final Book book;
  final GlobalKey itemKey;

  const BookItem({super.key, required this.book, required this.itemKey});
  @override
  BookItemState createState() => BookItemState();
}

class BookItemState extends State<BookItem> {
  late final Book book;

  @override
  void initState() {
    super.initState();
    book = widget.book;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: widget.itemKey,
      width: resizeBookThickness(book),
      height: resizeBookHeight(book),
      child: bookSpineContainer(book),
    );
  }
}
