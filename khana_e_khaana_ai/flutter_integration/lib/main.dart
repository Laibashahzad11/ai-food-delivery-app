import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const KhanaEKhaanaApp());
}

class KhanaEKhaanaApp extends StatelessWidget {
  const KhanaEKhaanaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Khana e Khaana AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        primaryColor: const Color(0xFFD32F2F),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        useMaterial3: true,
        fontFamily: 'Roboto', // Ensure you have this font or remove if using default
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFD32F2F),
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
