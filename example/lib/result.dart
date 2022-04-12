import 'dart:typed_data';

import 'package:flutter/material.dart';

class Result extends StatefulWidget {
  const Result({key, required this.uint8list}) : super(key: key);

  final Uint8List uint8list;

  @override
  _ResultState createState() => _ResultState();
}

class _ResultState extends State<Result> {
  @override
  Widget build(BuildContext context) {
    return Image.memory(widget.uint8list);
  }
}
