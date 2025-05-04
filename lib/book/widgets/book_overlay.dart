import 'dart:math';

import 'package:bookshelf/book/model/book.dart';
import 'package:bookshelf/book/widgets/book_helpers.dart';
import 'package:flutter/material.dart';

class AnimatedBookWidget extends StatefulWidget {
  final Book book;
  final Offset position;
  final VoidCallback onClose;

  const AnimatedBookWidget({
    super.key,
    required this.book,
    required this.position,
    required this.onClose,
  });

  @override
  AnimatedBookWidgetState createState() => AnimatedBookWidgetState();
}

class AnimatedBookWidgetState extends State<AnimatedBookWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _scaleAnimation;
  late final Book book;
  final double animatedScale = 2;
  @override
  void initState() {
    super.initState();
    book = widget.book;
    _setAnimationController();
    _setRotationAnimation();
    _setScaleAnimation();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setPositionAnimation();
    });
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onClose();
      }
    });
    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setPositionAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(ignoring: false, child: _buildAnimatedBook());
  }

  void _setAnimationController() {
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
  }

  void _setRotationAnimation() {
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: pi / 2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  void _setPositionAnimation() {
    final screenSize = MediaQuery.of(context).size;
    final screenCenter = Offset(
      (screenSize.width / 2) / animatedScale - resizeBookWidth(book) / 2,
      screenSize.height / 2,
    );
    final adjustedTarget = screenCenter;

    _positionAnimation = Tween<Offset>(
      begin: widget.position,
      end: adjustedTarget,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  void _setScaleAnimation() {
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: animatedScale,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
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
    return Transform.scale(
      scale: _scaleAnimation.value,
      alignment: Alignment.centerLeft,
      child: Transform.translate(
        offset: _positionAnimation.value,
        child: Transform(
          alignment: Alignment.centerLeft,
          transform:
              Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(_rotationAnimation.value),
          child: child,
        ),
      ),
    );
  }

  AnimatedBuilder _buildAnimatedBook() {
    return AnimatedBuilder(
      animation: _controller,
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
