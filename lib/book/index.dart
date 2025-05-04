import 'package:bookshelf/book/show.dart';
import 'package:bookshelf/book/widgets/book_helpers.dart';
import 'package:bookshelf/book/widgets/book_item.dart';
import 'package:bookshelf/book/widgets/book_overlay.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'model/book.dart';

class Index extends StatefulWidget {
  const Index({super.key});

  @override
  State<Index> createState() => _IndexPageState();
}

class _IndexPageState extends State<Index> {
  final Set<Book> _readBook = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Index')),
      body: FutureBuilder<Box<Book>>(
        future: Hive.openBox<Book>('book'), // 非同期でHiveにアクセス

        builder: (BuildContext context, AsyncSnapshot<Box<Book>> snapshot) {
          if (!snapshot.hasData) {
            // 非同期が完了していなければ、ローディング画面を表示する
            return Center(child: CircularProgressIndicator());
          }

          final box = snapshot.data!; // 非同期でアクセスしたデータを取得
          final books = box.values.toList();
          return Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: _buildBookListItems(books),
          );
        },
      ),
    );
  }

  void _navigateToShow(BuildContext context, Book book) async {
    Navigator.pop(context);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return Show(book: book);
        },
      ),
    );
  }

  AlertDialog _showBookInfoDialog(Book book) {
    return AlertDialog(
      title: Text(book.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('著者:${book.author}'),
          Text('説明: 説明が入ります'), // 本の説明を入れる(まだカラムを未実装)
        ],
      ),
      actions: [
        TextButton(
          child: Text("Cancel"),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: Text("Show"),
          onPressed: () {
            _navigateToShow(context, book);
            setState(() {});
          },
        ),
      ],
    );
  }

  void openBookAnimation(Book book, Offset position) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder:
          (context) => AnimatedBookWidget(
            book: book,
            position: position,
            onClose: () {
              entry.remove();
            },
            showDialog: _showBookInfoDialog,
          ),
    );

    overlay.insert(entry);
  }

  InkWell _buildBookItem(Book book) {
    if (_readBook.contains(book)) {
      // 読まれている本であるため、領域のみ確保(表示なし)
      return InkWell(
        child: SizedBox(
          width: resizeBookThickness(book),
          height: resizeBookHeight(book),
        ),
      );
    }
    final itemKey = GlobalKey();
    final bookItem = BookItem(book: book, itemKey: itemKey);
    return InkWell(
      onTap: () {
        setState(() {
          _readBook.add(book); // 非表示にする
        });
        final context = itemKey.currentContext;
        final box = context!.findRenderObject() as RenderBox;
        final position = box.localToGlobal(Offset.zero);
        debugPrint(position.toString());
        openBookAnimation(book, position);
      },
      child: bookItem,
    );
  }

  List<ConstrainedBox> _buildBookListItems(List<Book> books) {
    return books.map((book) {
      return ConstrainedBox(
        constraints: BoxConstraints(minWidth: 10),
        child: _buildBookItem(book),
      );
    }).toList();
  }
}
