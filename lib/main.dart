import 'package:flutter/material.dart';
import 'package:google_map/home_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Google Map App',
      home: Scaffold(
        appBar: AppBar(title: const Text('Google MAp')),
        body: MapHomeScreen(),
      ),
    );
  }
}
