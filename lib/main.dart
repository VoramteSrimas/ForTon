import 'package:flutter/material.dart';
import 'package:flutter_application_food_scan/srceen/camera.dart';
import 'package:flutter_application_food_scan/srceen/home_srceen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Scan App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/camera': (context) => const Camera(),
      },
    );
  }
}
