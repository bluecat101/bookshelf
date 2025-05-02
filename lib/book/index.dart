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

class _IndexPageState extends State<Index> with SingleTickerProviderStateMixin {
  late AnimationController _bookController;
  late Animation<double> _bookRotationAnimation;
  late Animation<Offset> _bookPositionAnimation;
  late Object bookObject; // Bookオブジェクトの参照
  bool mode_change_switch = true;

  Future<void> setAnimation() async {
    _bookController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
  }

  void setPositionAnimation() {
    final screenSize = MediaQuery.of(context).size;
    final screenCenter = Offset(screenSize.width / 2, screenSize.height / 2);
    final adjustedTarget = screenCenter;
    // final adjustedTarget = screenCenter - Offset(110 / 2, 150 / 2);
    // final adjustedTarget = screenCenter - Offset(300, 150 / 2);

    _bookPositionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: adjustedTarget,
    ).animate(
      CurvedAnimation(parent: _bookController, curve: Curves.easeInOut),
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
                child: Container(width: 10, height: 150, color: Colors.brown),
              ),
            ),
            // 表紙（最初は横向きで見えない）
            Positioned(
              left: 10,
              child: Transform(
                alignment: Alignment.centerLeft,
                transform:
                    Matrix4.identity()..setRotationY(-pi / 2), // ← 表紙だけ初期角度を与える
                child: Container(
                  width: 100,
                  height: 150,
                  color: Colors.blue,
                  child: Center(child: Text("本")),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    // },
    // );
  }

  Container _bookItemInfo(
    Book book,
    double translateX,
    double translateY,
    double translateZ,
  ) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      width: double.infinity,
      height: screenHeight / 2 - AppBar().preferredSize.height,
      child: bookWidget(),
      // child: Stack(
      //   children: [
      //     // 背表紙
      //     // bookSpine(),
      //     // bookCover(translateX, translateY, translateZ),
      //     bookWidget(),
      //     // 表紙
      //   ],
      // ),
    );
  }
  // }

  InkWell _buildBookItem(
    Book book,
    double translateX,
    double translateY,
    double translateZ,
  ) {
    return InkWell(
      onTap: () {
        if (mode_change_switch) {
          _bookController.forward();
        } else {
          _bookController.reverse();
        }
        mode_change_switch = !mode_change_switch;
      },
      child: _bookItemInfo(book, translateX, translateY, translateZ),
    );
  }

  List<InkWell> _buildBookListItems(List<Book> books) {
    var translateX = 0.0;
    var translateY = 0.0;
    var translateZ = 0.0;

    return books.map((book) {
      // translateX -= 5;
      return _buildBookItem(book, translateX, translateY, translateZ);
    }).toList();
  }

  @override
  void initState() {
    super.initState();

    _bookController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _bookRotationAnimation = Tween<double>(
      begin: 0,
      end: pi / 2,
    ).animate(CurvedAnimation(parent: _bookController, curve: Curves.linear));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setPositionAnimation();
    });
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
