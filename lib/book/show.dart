import 'package:flutter/material.dart';

class Show extends StatefulWidget {
  const Show({super.key});

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
