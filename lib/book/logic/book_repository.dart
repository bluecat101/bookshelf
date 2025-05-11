import 'package:bookshelf/book/model/book.dart';
import 'package:hive/hive.dart';

class BookRepository {
  Future<List<Book>> fetchBooks() async {
    final box = await Hive.openBox<Book>('book');
    return box.values.toList();
  }
}
