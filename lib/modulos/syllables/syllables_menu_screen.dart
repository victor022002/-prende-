import 'package:flutter/material.dart';
import 'syllables_difficulty_screen.dart';
import '/models/student_model.dart';

class SyllablesMenuScreen extends StatelessWidget {
  final Student student;

  const SyllablesMenuScreen({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text("Elige un escenario"),
        backgroundColor: Colors.lightBlueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text(
                "Selecciona el mundo",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              _buildCard(
                context,
                icon: Icons.location_city,
                title: "Ciudad",
                color: Colors.orangeAccent,
                scenario: "city",
              ),

              const SizedBox(height: 20),

              _buildCard(
                context,
                icon: Icons.nature_people,
                title: "Naturaleza",
                color: Colors.greenAccent,
                scenario: "nature",
              ),

              const SizedBox(height: 20),

              _buildCard(
                context,
                icon: Icons.toys,
                title: "Objetos",
                color: Colors.lightBlueAccent,
                scenario: "objects",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required String scenario,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SyllablesDifficultyScreen(
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
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 60, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
