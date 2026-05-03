import 'package:flutter/material.dart';
import 'splash_screen.dart';

void main() {
  runApp(const SystemCoreApp());
}

class SystemCoreApp extends StatelessWidget {
  const SystemCoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'System Core',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.cyanAccent,
        fontFamily: 'Roboto', // Default standard font
      ),
      home: const SplashScreen(),
    );
  }
}
