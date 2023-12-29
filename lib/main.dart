import 'package:flutter/material.dart';
import 'package:ostad_map/map_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MapPage(),
      theme: ThemeData(useMaterial3: false, primaryColor: Colors.blue),
    );
  }
}

