import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const AprendeApp());
}

class AprendeApp extends StatelessWidget {
  const AprendeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '@prende+',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
      ),
      home: const LoginScreen(),
    );
  }
}




