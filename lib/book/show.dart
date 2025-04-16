import 'package:bookshelf/book/model/book.dart';
import 'package:flutter/material.dart';

class Show extends StatefulWidget {
  final Book book;

  const Show({super.key, required this.book});
  @override
  State<Show> createState() => _ShowPageState();
}

class _ShowPageState extends State<Show> {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Show')),
      body: Center(child: Text("show")),
    );
  }
}
