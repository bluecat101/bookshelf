import 'package:bookshelf/book/model/book.dart';
import 'package:bookshelf/helper.dart';
import 'package:flutter/material.dart';

Container bookSpineContainer(book) {
  return Container(
    width: resizeBookThickness(book),
    height: resizeBookHeight(book),
    color: Colors.brown,
  );
}

Widget bookCoverContainer(Book book) {
  final width = resizeBookWidth(book);
  final height = resizeBookHeight(book);
  final Future<bool> urlCheck =
      book.imageUrl == null ? Future.value(false) : existUrl(book.imageUrl!);
  return FutureBuilder<bool>(
    future: urlCheck,
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(strokeWidth: 1),
        );
      }

      final urlExists = snapshot.data!;
      if (book.imageUrl == null || !urlExists) {
        return Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: Text(book.title, style: const TextStyle(fontSize: 7)),
        );
      } else {
        return Image.network(
          book.imageUrl!,
          width: width,
          height: height,
          fit: BoxFit.fitHeight,
        );
      }
    },
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
