import 'dart:math';
import 'package:bookshelf/book/show.dart';
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

  Container bookSpineContainer() {
    return Container(width: 10, height: 150, color: Colors.brown);
  }

  Container bookCoverContainer() {
    return Container(
      width: 100,
      height: 150,
      color: Colors.blue,
      child: Center(child: Text("本")),
    );
  }

  SizedBox bookWidget() {
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

  Container _bookItemInfo(Book book) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      width: 10,
      height: screenHeight / 2 - AppBar().preferredSize.height,
      child: bookWidget(),
    );
  }

  void showBook(Book book) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder:
          (context) => AnimatedBookWidget(
            book: book,
            onClose: () {
              entry.remove();
            },
            bookSpineContainer: bookSpineContainer,
            bookCoverContainer: bookCoverContainer,
            showDialog: _showBookInfoDialog,
          ),
    );

    overlay.insert(entry);
  }

  InkWell _buildBookItem(Book book) {
    if (_readBook.contains(book)) {
      return InkWell(child: SizedBox(width: 10, height: 150));
    }

    return InkWell(
      onTap: () {
        setState(() {
          _readBook.add(book); // 非表示にする
        });
        showBook(book);
      },
      child: _bookItemInfo(book),
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
}

class AnimatedBookWidget extends StatefulWidget {
  final Book book;
  final VoidCallback onClose;
  final Container Function() bookSpineContainer;
  final Container Function() bookCoverContainer;
  final Function(Book book) showDialog;

  const AnimatedBookWidget({
    required this.book,
    required this.onClose,
    required this.bookSpineContainer,
    required this.bookCoverContainer,
    required this.showDialog,
  });

  @override
  _AnimatedBookWidgetState createState() => _AnimatedBookWidgetState();
}

class _AnimatedBookWidgetState extends State<AnimatedBookWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _bookController;
  late Animation<double> _bookRotationAnimation;
  late Animation<Offset> _bookPositionAnimation;

  void setAnimationController() {
    _bookController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
  }

  void setRotationAnimation() {
    _bookRotationAnimation = Tween<double>(
      begin: 0,
      end: pi / 2,
    ).animate(CurvedAnimation(parent: _bookController, curve: Curves.linear));
  }

  void setPositionAnimation() {
    final screenSize = MediaQuery.of(context).size;
    final screenCenter = Offset(screenSize.width / 2, screenSize.height / 2);
    final adjustedTarget = screenCenter;

    _bookPositionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: adjustedTarget,
    ).animate(
      CurvedAnimation(parent: _bookController, curve: Curves.easeInOut),
    );
  }

  @override
  void initState() {
    super.initState();
    setAnimationController();
    setRotationAnimation();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setPositionAnimation();
    });
    _bookController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setPositionAnimation();
  }

  @override
  void dispose() {
    _bookController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(ignoring: false, child: bookWidget());
  }

  AnimatedBuilder bookWidget() {
    return AnimatedBuilder(
      animation: _bookController,
      builder: (context, child) {
        return Transform.translate(
          offset: _bookPositionAnimation.value,
          child: Transform(
            alignment: Alignment.centerLeft,
            transform:
                Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(_bookRotationAnimation.value),
            child: child,
          ),
        );
      },
      child: SizedBox(
        width: 110,
        height: 150,
        child: Stack(
          children: [
            // 背表紙（常に見えてる）
            Positioned(
              left: 0,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity(), // ← 初期角度そのまま
                child: widget.bookSpineContainer(),
              ),
            ),
            // 表紙（最初は横向きで見えない）
            Positioned(
              left: 10,
              child: Transform(
                alignment: Alignment.centerLeft,
                transform:
                    Matrix4.identity()..setRotationY(-pi / 2), // ← 表紙だけ初期角度を与える
                child: widget.bookCoverContainer(),
              ),
            ),
          ],
        ),
      ),
    );
    // },
    // );
  }
}
