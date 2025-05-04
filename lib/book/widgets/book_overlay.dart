import 'dart:math';

import 'package:bookshelf/book/model/book.dart';
import 'package:bookshelf/book/widgets/book_helpers.dart';
import 'package:flutter/material.dart';

class AnimatedBookWidget extends StatefulWidget {
  final Book book;
  final Offset position;
  final VoidCallback onClose;
  final Function(Book book) showDialog;

  const AnimatedBookWidget({
    super.key,
    required this.book,
    required this.position,
    required this.onClose,
    required this.showDialog,
  });

  @override
  AnimatedBookWidgetState createState() => AnimatedBookWidgetState();
}

class AnimatedBookWidgetState extends State<AnimatedBookWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _bookController;
  late Animation<double> _bookRotationAnimation;
  late Animation<Offset> _bookPositionAnimation;
  late final Book book;

  @override
  void initState() {
    super.initState();
    book = widget.book;
    _setAnimationController();
    _setRotationAnimation();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setPositionAnimation();
    });
    _bookController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setPositionAnimation();
  }

  @override
  void dispose() {
    _bookController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(ignoring: false, child: _buildAnimatedBook());
  }

  void _setAnimationController() {
    _bookController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
  }

  void _setRotationAnimation() {
    _bookRotationAnimation = Tween<double>(
      begin: 0,
      end: pi / 2,
    ).animate(CurvedAnimation(parent: _bookController, curve: Curves.linear));
  }

  void _setPositionAnimation() {
    final screenSize = MediaQuery.of(context).size;
    final screenCenter = Offset(
      screenSize.width / 2 -
          resizeBookThickness(book) +
          resizeBookWidth(book) / 2,
      screenSize.height / 2,
    );
    final adjustedTarget = screenCenter;

    _bookPositionAnimation = Tween<Offset>(
      begin: widget.position,
      end: adjustedTarget,
    ).animate(
      CurvedAnimation(parent: _bookController, curve: Curves.easeInOut),
    );
  }

  Positioned _bookSpineWidget() {
    return Positioned(left: 0, child: bookSpineContainer(book));
  }

  Positioned _bookCoverWidget() {
    return Positioned(
      left: resizeBookThickness(book),
      child: Transform(
        alignment: Alignment.centerLeft,
        transform: Matrix4.identity()..setRotationY(-pi / 2),
        child: bookCoverContainer(book),
      ),
    );
  }

  Transform _bookAnimation(child) {
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
  }

  AnimatedBuilder _buildAnimatedBook() {
    return AnimatedBuilder(
      animation: _bookController,
      builder: (context, child) {
        return _bookAnimation(child);
      },
      child: SizedBox(
        width: resizeBookWidth(book),
        height: resizeBookHeight(book),
        child: Stack(children: [_bookSpineWidget(), _bookCoverWidget()]),
      ),
    );
  }
}
