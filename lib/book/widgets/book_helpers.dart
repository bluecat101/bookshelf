import 'package:flutter/material.dart';

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
