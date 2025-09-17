import 'package:flutter/material.dart';
import 'screens/loading_screen.dart';

void main() {
  runApp(const FiltraCheckApp());
}

class FiltraCheckApp extends StatelessWidget {
  const FiltraCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FiltraCheck',
      theme: ThemeData(
        primaryColor: const Color(0xFF0D47A1), // Dark blue
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF0D47A1),
          secondary: Color(0xFF1976D2),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoadingScreen(), // Use the correct class name
    );
  }
}
