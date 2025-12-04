import 'package:flutter/material.dart';
import 'syllables_menu_screen.dart';

class ActivitySyllablesScreen extends StatelessWidget {
  const ActivitySyllablesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔥 APENAS ENTRA A ESTA SCREEN, VA DIRECTO A SYLLABLES MENU
    Future.microtask(() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const SyllablesMenuScreen(),
        ),
      );
    });

    // Pantalla temporal de transición mientras navega
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: const Center(
        child: CircularProgressIndicator(color: Colors.lightBlueAccent),
      ),
    );
  }
}
