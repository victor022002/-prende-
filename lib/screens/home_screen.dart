import 'package:flutter/material.dart';
import 'activity_menu_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const WelcomeScreen(),
    const ActivityMenuScreen(),
    const PlaceholderScreen(title: "Progreso"),
    const PlaceholderScreen(title: "Ajustes"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Row(
        children: [
          // 📚 Barra lateral izquierda
          NavigationRail(
            backgroundColor: Colors.lightBlueAccent,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined, color: Colors.white),
                selectedIcon: Icon(Icons.home, color: Colors.white),
                label: Text("Inicio", style: TextStyle(color: Colors.white)),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.menu_book_outlined, color: Colors.white),
                selectedIcon: Icon(Icons.menu_book, color: Colors.white),
                label: Text("Actividades", style: TextStyle(color: Colors.white)),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.bar_chart_outlined, color: Colors.white),
                selectedIcon: Icon(Icons.bar_chart, color: Colors.white),
                label: Text("Progreso", style: TextStyle(color: Colors.white)),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined, color: Colors.white),
                selectedIcon: Icon(Icons.settings, color: Colors.white),
                label: Text("Ajustes", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),

          // 🖥️ Contenido principal
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
    );
  }
}

// 💬 Pantalla de bienvenida
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book, size: 80, color: Colors.lightBlueAccent),
            const SizedBox(height: 20),
            const Text(
              "Bienvenido a @prende+",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Una aplicación educativa para mejorar tus habilidades de lectura y escritura, incluso sin conexión.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text("Comenzar aprendizaje"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ActivityMenuScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              "Progreso: 0/10",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

// 🧩 Placeholder temporal
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
      ),
    );
  }
}
