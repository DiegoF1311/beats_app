import 'package:beats_app/presentation/screens/beat_ide_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Beat IDE',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Courier',
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
      ),
      home: const BeatIDEScreen(),
    );
  }
}
