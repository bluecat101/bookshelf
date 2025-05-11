import 'package:bookshelf/book/logic/book_repository.dart';
import 'package:bookshelf/book/logic/file_upload.dart';
import 'package:bookshelf/book/show.dart';
import 'package:bookshelf/book/widgets/book_helpers.dart';
import 'package:bookshelf/book/widgets/book_item.dart';
import 'package:bookshelf/book/widgets/book_overlay.dart';
import 'package:flutter/material.dart';
import 'model/book.dart';

class Index extends StatefulWidget {
  final BookRepository repository;
  const Index({super.key, required this.repository});

  @override
  State<Index> createState() => _IndexPageState();
}

class _IndexPageState extends State<Index> {
  final Set<Book> _readBook = {};
  late bool isAnimating = false;
  late Future<List<Book>> booksFuture;
  @override
  void initState() {
    super.initState();
    booksFuture = widget.repository.fetchBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Index')),
      body: FutureBuilder<List<Book>>(
        future: booksFuture,
        builder: (BuildContext context, AsyncSnapshot<List<Book>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('エラー: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Text('本が見つかりません');
          } else {
            final books = snapshot.data!;
            return Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _buildBookListItems(books),
            );
          }
        },
      ),
    );
  }

  void _navigateToShow(BuildContext context, Book book) async {
    Navigator.pop(context);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return Show(book: book, fileUploader: FileUploader());
        },
      ),
    );
    setState(() {
      booksFuture = widget.repository.fetchBooks();
    });
  }

  Future<void> _confirmBookActionDialog(Book book) {
    final String author =
        book.author.contains(',') ? book.author.split(',')[0] : book.author;
    book.comment ??= '';
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(book.title, overflow: TextOverflow.ellipsis),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              bookCoverContainer(book),
              Text('著者: $author', overflow: TextOverflow.ellipsis),
              Text('説明\n${book.comment}'),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed:
                  () => {
                    _readBook.remove(book),
                    Navigator.pop(context),
                    setState(() {}),
                  },
            ),
            TextButton(
              child: Text("Show"),
              onPressed: () {
                _navigateToShow(context, book);
              },
            ),
          ],
        );
      },
    ).then((value) {
      if (value == null || value == 'cancel') {
        _readBook.remove(book);
        setState(() {});
      }
    });
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
              isAnimating = false;
              _confirmBookActionDialog(book);
            },
          ),
    );

    overlay.insert(entry);
  }

  Widget _buildBookItem(Book book) {
    if (_readBook.contains(book)) {
      // 読まれている本であるため、領域のみ確保(表示なし)
      return SizedBox(
        width: resizeBookThickness(book),
        height: resizeBookHeight(book),
      );
    }
    final itemKey = GlobalKey();
    final bookItem = BookItem(book: book, itemKey: itemKey);
    return IgnorePointer(
      ignoring: isAnimating,
      child: InkWell(
        onTap: () {
          setState(() {
            _readBook.add(book); // 非表示にする
            isAnimating = true;
          });
          final context = itemKey.currentContext;
          final box = context!.findRenderObject() as RenderBox;
          final position = box.localToGlobal(Offset.zero);
          openBookAnimation(book, position);
        },
        child: bookItem,
      ),
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
