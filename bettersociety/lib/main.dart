import 'package:bettersociety/pages/home.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "BetterSociety",
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}
