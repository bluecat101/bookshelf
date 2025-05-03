import 'dart:math';

import 'package:bookshelf/book/model/book.dart';
import 'package:bookshelf/book/widgets/book_helpers.dart';
import 'package:flutter/material.dart';

class AnimatedBookWidget extends StatefulWidget {
  final Book book;
  final VoidCallback onClose;
  final Function(Book book) showDialog;

  const AnimatedBookWidget({
    required this.book,
    required this.onClose,
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
    return IgnorePointer(ignoring: false, child: _buildAnimatedBook());
  }

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

  Positioned bookSpineWidget() {
    return Positioned(left: 0, child: bookSpineContainer());
  }

  Positioned bookCoverWidget() {
    return Positioned(
      left: 10,
      child: Transform(
        alignment: Alignment.centerLeft,
        transform: Matrix4.identity()..setRotationY(-pi / 2),
        child: bookCoverContainer(),
      ),
    );
  }

  Transform bookAnimation(child) {
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
        return bookAnimation(child);
      },
      child: SizedBox(
        width: 110,
        height: 150,
        child: Stack(children: [bookSpineWidget(), bookCoverWidget()]),
      ),
    );
  }
}
