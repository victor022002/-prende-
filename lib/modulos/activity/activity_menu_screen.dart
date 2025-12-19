import 'package:aprende_app/modulos/listening/listening_game_screen.dart';
import 'package:aprende_app/modulos/listening/listening_list.dart';
import 'package:flutter/material.dart';
import '/models/student_model.dart';
import '/modulos/reading/reading_menu_screen.dart';
import '/modulos/writing/writing_menu_screen.dart';
import '/modulos/listening/listening_game_screen.dart';


class ActivityMenuScreen extends StatelessWidget {
  final Student student;

  const ActivityMenuScreen({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),

              /// 📚 LECTURA
              _buildCategoryCard(
                context,
                title: "📚 Lectura",
                description:
                    "Actividades para desarrollar comprensión lectora",
                color: Colors.lightBlue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReadingMenuScreen(
                        student: student,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              /// ✍️ ESCRITURA
              _buildCategoryCard(
                context,
                title: "✍️ Escritura",
                description:
                    "Actividades para desarrollar habilidades de escritura",
                color: Colors.purpleAccent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WritingMenuScreen(
                        student: student,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),
              /// 👂 ESCRITURA
              _buildCategoryCard(
                context,
                title: "👂 Escucha",
                description: "Actividades para desarrollar habilidades de escucha",
                color: Colors.purpleAccent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ListeningGameScreen(
                        student: student,
                        activities: listeningList, 
                      ),
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

  Widget _buildCategoryCard(
    BuildContext context, {
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    final width = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: EdgeInsets.all(width * 0.05),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: width * 0.07,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: TextStyle(
                fontSize: width * 0.045,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
