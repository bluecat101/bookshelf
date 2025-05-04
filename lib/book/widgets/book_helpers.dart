import 'dart:math';

import 'package:bookshelf/book/model/book.dart';
import 'package:bookshelf/helper.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

FutureBuilder bookSpineContainer(book) {
  // 画像から主な色を取得
  Future<Color> getDominantColor(String? imageUrl) async {
    if (imageUrl != null && await existUrl(imageUrl)) {
      final paletteGenerator = await PaletteGenerator.fromImageProvider(
        NetworkImage(imageUrl),
      );
      return paletteGenerator.dominantColor?.color ?? Colors.grey;
    }
    return Colors.white;
  }

  // 黒系の色かを判定
  bool isDarkColor(Color color) {
    final r = color.r;
    final g = color.g;
    final b = color.b;
    // r,g,bが0~1.0であるため255をかける。その他の計算はサイトを参考
    return ((((r * 255 * 299) + (g * 255 * 587) + (b * 255 * 114)) / 1000) <
        128);
  }

  const minimumFontSize = 10;
  final fontSize = max(
    resizeBookHeight(book) / book.title.length,
    minimumFontSize,
  );
  final spineTitle = book.title.substring(
    0,
    min(fontSize / 1.4, book.title.length - 1).toInt(),
  );

  return FutureBuilder<Color>(
    future: getDominantColor(book.imageUrl),
    builder: (BuildContext context, AsyncSnapshot<Color> snapshot) {
      var spineColor = Colors.white;
      if (snapshot.connectionState == ConnectionState.waiting ||
          snapshot.hasError) {
        spineColor = Colors.white;
      } else {
        spineColor = snapshot.data!;
      }
      final textColor = isDarkColor(spineColor) ? Colors.white : Colors.black;
      return Container(
        width: resizeBookThickness(book),
        height: resizeBookHeight(book),
        color: spineColor,
        child: Column(
          children: // 縦書きにする
              spineTitle.split('').map<Widget>((char) {
                return Text(
                  char,
                  style: TextStyle(
                    fontSize: fontSize.toDouble(),
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                );
              }).toList(),
        ),
      );
    },
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
