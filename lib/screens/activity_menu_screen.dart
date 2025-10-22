import 'package:flutter/material.dart';
import 'activity_screen.dart';
import 'activity_syllables_screen.dart';
import 'activity_complete_word_screen.dart'; // esta la haremos después

class ActivityMenuScreen extends StatelessWidget {
  const ActivityMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text("Actividades Offline"),
        backgroundColor: Colors.lightBlueAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Selecciona una actividad para comenzar 👇",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 40),

              // 🔹 Lectura Guiada
              _buildActivityButton(
                context,
                title: "📖 Lectura guiada",
                color: Colors.lightBlueAccent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ActivityScreen(
                        student: null, // puedes pasar un Student si lo deseas
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // 🔹 Ordenar Sílabas
              _buildActivityButton(
                context,
                title: "🧩 Ordenar sílabas",
                color: Colors.orangeAccent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ActivitySyllablesScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // 🔹 Completa la palabra
              _buildActivityButton(
                context,
                title: "🔠 Completa la palabra",
                color: Colors.greenAccent.shade700,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ActivityCompleteWordScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityButton(
    BuildContext context, {
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        width: double.infinity,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
