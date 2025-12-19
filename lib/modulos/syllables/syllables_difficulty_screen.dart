import 'package:flutter/material.dart';
import 'syllables_game_screen.dart';
import 'word_lists.dart';
import '/models/student_model.dart';

class SyllablesDifficultyScreen extends StatelessWidget {
  final String scenario;
  final Student student;

  const SyllablesDifficultyScreen({
    super.key,
    required this.scenario,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text("Elige dificultad"),
        backgroundColor: Colors.lightBlueAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              "Selecciona dificultad",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),

            _buildButton(
              context,
              title: "Fácil (2 sílabas)",
              color: Colors.greenAccent,
              hard: false,
            ),

            const SizedBox(height: 20),

            _buildButton(
              context,
              title: "Difícil (letras)",
              color: Colors.orangeAccent,
              hard: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required String title,
    required Color color,
    required bool hard,
  }) {
    return GestureDetector(
      onTap: () {
        /// 🔹 SOLO LEE LA LISTA EN MEMORIA
        final words = getWordList(scenario, hard);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SyllablesGameScreen(
              words: words,
              hard: hard,
              scenario: scenario,
              student: student,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 30),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
