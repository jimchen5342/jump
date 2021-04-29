import 'package:flutter/material.dart';
import 'package:jump/calendar.dart';

void main() { // /
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '跳繩', //
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Calendar(),
    );
  }
}
