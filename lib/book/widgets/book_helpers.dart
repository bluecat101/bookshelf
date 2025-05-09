import 'dart:math';

import 'package:bookshelf/book/model/book.dart';
import 'package:bookshelf/helper/url.dart';
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

  // 背表紙のタイトルを調整する（省略あり）
  const double minimumFontSize = 10;
  const double paddingRatio = 0.2;

  /// 高さと文字数から適切なフォントサイズを計算（最小サイズ考慮）
  double calculateFontSize(double height, int charCount) {
    // 以下の式は、widgetの高さ = 文字数*(fontSize+余白)+余白についてfontSizeを解く式
    final fontSize = height / (charCount * (1 + paddingRatio) + paddingRatio);
    return fontSize < minimumFontSize ? minimumFontSize : fontSize;
  }

  /// フォントサイズと高さから、収まる最大文字数を計算
  int calculateMaxCharCount(double height, double fontSize) {
    final padding = fontSize * paddingRatio;
    // 以下の式は、widgetの高さ = 文字数*(fontSize+余白)+余白について文字数を解く式
    return ((height - padding) / (fontSize + padding)).floor();
  }

  final fontSize = calculateFontSize(resizeBookHeight(book), book.title.length);
  final maxChars = calculateMaxCharCount(resizeBookHeight(book), fontSize);
  // 背表紙のテキスト
  final bookSpineTitle =
      fontSize == minimumFontSize && book.title.length > maxChars
          ? book.title.substring(0, maxChars)
          : book.title;

  return FutureBuilder<Color>(
    future: getDominantColor(book.coverImageUrl),
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
              bookSpineTitle.split('').map<Widget>((char) {
                return Text(
                  char,
                  style: TextStyle(
                    fontSize: fontSize.toDouble(),
                    height: (1 + paddingRatio),
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
      book.coverImageUrl == null
          ? Future.value(false)
          : existUrl(book.coverImageUrl!);
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
      if (book.coverImageUrl == null || !urlExists) {
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
          book.coverImageUrl!,
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
  return max(book.width, 15) * widthFactor;
}

double resizeBookHeight(Book book) {
  return max(book.height, 15) * heightFactor;
}

double resizeBookThickness(Book book) {
  return max(book.pages, 300) * pagesFactor;
}
