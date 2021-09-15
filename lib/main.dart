import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_line_chart/home_page.dart';

void main() {
  querySelector(".loading")?.remove();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter line chart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}
