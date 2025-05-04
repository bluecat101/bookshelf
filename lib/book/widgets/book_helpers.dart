import 'package:bookshelf/book/model/book.dart';
import 'package:flutter/material.dart';

Container bookSpineContainer(book) {
  return Container(
    width: resizeBookThickness(book),
    height: resizeBookHeight(book),
    color: Colors.brown,
  );
}

Container bookCoverContainer(Book book) {
  return Container(
    width: resizeBookWidth(book),
    height: resizeBookHeight(book),
    color: Colors.blue,
    child: Center(child: Text("本")),
  );
}

const double widthFactor = 5;
const double heightFactor = 5;
const double pagesFactor = 1 / 30;

double resizeBookWidth(Book book) {
  return book.width * widthFactor;
}

double resizeBookHeight(Book book) {
  return book.height * heightFactor;
}

double resizeBookThickness(Book book) {
  return book.pages * pagesFactor;
}
