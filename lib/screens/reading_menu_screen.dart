import 'package:flutter/material.dart';
import 'stories_screen.dart';
import 'activity_syllables_screen.dart';
import 'activity_complete_word_screen.dart';

class ReadingMenuScreen extends StatelessWidget {
  const ReadingMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text("Lectura"),
        backgroundColor: Colors.lightBlueAccent,
        foregroundColor: Colors.white,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Elige una actividad 👇",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 30),
              //  Lectura guiada (va a StoriesScreen)
              _buildItem(
                context,
                title: "📖 Lectura guiada",
                color: Colors.lightBlueAccent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StoriesScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              //  Ordenar sílabas
              _buildItem(
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

              //  Completar palabra
              _buildItem(
                context,
                title: "🔠 Completa la palabra",
                color: Colors.green,
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

  Widget _buildItem(
    BuildContext context, {
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    final width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.symmetric(
          vertical: width * 0.04,
          horizontal: width * 0.04,
        ),

        decoration: ShapeDecoration(
          color: color.withOpacity(0.85),
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          shadows: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),

        child: Center(
          child: FittedBox(
            child: Text(
              title,
              style: TextStyle(
                fontSize: width * 0.055,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
