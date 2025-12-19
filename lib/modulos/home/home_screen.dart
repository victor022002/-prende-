import 'package:aprende_app/modulos/listening/listening_game_screen.dart';
import 'package:flutter/material.dart';
import 'package:aprende_app/modulos/reading/reading_menu_screen.dart';
import '/modulos/activity/activity_menu_screen.dart';
import '/modulos/writing/writing_menu_screen.dart';
import '/modulos/settings/settings_screen.dart';
import '/modulos/students/progress_screen.dart';
import '/models/student_model.dart';
import '/modulos/listening/listening_list.dart';


class HomeScreen extends StatefulWidget {
  final Student student;

  const HomeScreen({
    super.key,
    required this.student,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {

  int _selectedIndex = 0;
  bool _sidebarVisible = false;

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  late final List<Widget> _screens;

  Student get currentStudent => widget.student;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _screens = [
      WelcomeScreen(student: currentStudent),
      ActivityMenuScreen(student: currentStudent),
      ProgressScreen(studentId: currentStudent.id!), 
      const SettingsScreen(),
    ];
  }

  void changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        foregroundColor: Colors.white,
        title: const Text("Aprende+"),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            setState(() => _sidebarVisible = !_sidebarVisible);
            _sidebarVisible ? _controller.forward() : _controller.reverse();
          },
        ),
      ),
      body: Stack(
        children: [
          SafeArea(child: _screens[_selectedIndex]),

          SlideTransition(
            position: _slideAnimation,
            child: SafeArea(
              child: Container(
                width: 250,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 15,
                      offset: const Offset(4, 4),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    _buildMenuItem(Icons.home, "Inicio", 0),
                    _buildMenuItem(Icons.menu_book, "Actividades", 1),
                    _buildMenuItem(Icons.bar_chart, "Progreso", 2),
                    _buildMenuItem(Icons.settings, "Ajustes", 3),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, int index) {
    final selected = _selectedIndex == index;

    return ListTile(
      leading: Icon(
        icon,
        color: selected ? Colors.lightBlue : Colors.grey,
        size: selected ? 30 : 24,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.lightBlue : Colors.black87,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        changeTab(index);
        setState(() => _sidebarVisible = false);
        _controller.reverse();
      },
    );
  }
}


/// =======================
/// WELCOME SCREEN
/// =======================
class WelcomeScreen extends StatelessWidget {
  final Student student;

  const WelcomeScreen({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Icon(Icons.menu_book,
                  size: 80, color: Colors.lightBlueAccent),
              const SizedBox(height: 20),
              const Text(
                "Bienvenido a Aprende+",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              Text(
                "¡Bienvenido de nuevo, ${student.name} , sigamos con nuestro viaje de la lectura! 📖✨",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),


              const SizedBox(height: 25),

              Wrap(
                alignment: WrapAlignment.center,
                spacing: 20,
                runSpacing: 16,
                children: [
                  _buildCard(
                    context,
                    title: "Lectura",
                    icon: Icons.menu_book,
                    color: Colors.orangeAccent,
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
                  _buildCard(
                    context,
                    title: "Escritura",
                    icon: Icons.edit,
                    color: Colors.greenAccent,
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

                  // 🔊 ESCUCHA (restaurado, aún no activo)
                  _buildCard(
                    context,
                    title: "Escucha",
                    icon: Icons.hearing,
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
                    }
                  ),

                  _buildCard(
                    context,
                    title: "Logros",
                    icon: Icons.star,
                    color: Colors.pinkAccent,
                    onTap: () {
                      final home =
                          context.findAncestorStateOfType<_HomeScreenState>();
                      home?.changeTab(2);
                    },
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 130,
        height: 100,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 36),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }
}
