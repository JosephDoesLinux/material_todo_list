import 'package:flutter/material.dart';
import 'home.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material To-Do List',
      // Material 3 Theme, please work
      theme: ThemeData(
        useMaterial3: true,
        // picked a seed color (like Blue, will try pulling from android soon) and it generates a cool palette for the ((android)) user
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const Home(),
    );
  }
}