import 'package:flutter/material.dart';
import '/modulos/reading/reading_menu_screen.dart';
import '/modulos/writing/writing_menu_screen.dart';

class ActivityMenuScreen extends StatelessWidget {
  const ActivityMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              const SizedBox(height: 10),

              // 📚 Lectura
              _buildCategoryCard(
                context,
                title: "📚 Lectura",
                description: "Actividades para desarrollar comprensión lectora",
                color: Colors.lightBlue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ReadingMenuScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // ✍️ Escritura
              _buildCategoryCard(
                context,
                title: "✍️ Escritura",
                description: "Actividades para desarrollar habilidades de escritura :sunglasses:",
                color: Colors.purpleAccent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_)=> const WritingMenuScreen()
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(width * 0.05),
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



