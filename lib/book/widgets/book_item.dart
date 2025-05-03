import 'package:bookshelf/book/model/book.dart';
import 'package:bookshelf/book/widgets/book_helpers.dart';
import 'package:flutter/material.dart';

class BookItem extends StatefulWidget {
  final Book book;

  const BookItem({required this.book});

  @override
  _BookItemState createState() => _BookItemState();
}

class _BookItemState extends State<BookItem> {
  late final Book book;

  @override
  void initState() {
    super.initState();
    book = widget.book;
  }

  @override
  Widget build(BuildContext context) {
    return _bookItemInfo();
  }

  SizedBox bookInBookshelf() {
    return SizedBox(
      width: 110,
      height: 150,
      child: Stack(
        children: [
          // 背表紙
          Positioned(left: 0, child: bookSpineContainer()),
          // 表紙
          Positioned(left: 10, child: bookCoverContainer()),
        ],
      ),
    );
  }

  Container _bookItemInfo() {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      width: 10,
      height: screenHeight / 2 - AppBar().preferredSize.height,
      child: bookInBookshelf(),
    );
  }
}
