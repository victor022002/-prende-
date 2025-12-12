import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import '/modulos/home/home_screen.dart';
import 'register_screen.dart';
import '/models/student_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    final correo = _correoController.text.trim();
    final password = _passwordController.text.trim();

    if (correo.isEmpty || password.isEmpty) {
      _showMessage("Completa todos los campos.");
      return;
    }

    try {
      await _auth.signInWithEmailAndPassword(
        email: correo,
        password: password,
      );

      final user = FirebaseAuth.instance.currentUser;

      if (user != null && mounted) {
        final student = Student(
          id: user.uid.hashCode,
          name: user.email?.split('@').first ?? 'Alumno',
          email: user.email ?? '',
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(student: student),
          ),
        );
      }

    } on FirebaseAuthException catch (e) {
      _showMessage("Error: ${e.message}");
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Lottie.asset('assets/animations/Sun_breathing.json', height: 140),

              const SizedBox(height: 16),

              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Icon(Icons.menu_book,
                          size: 80, color: Colors.lightBlueAccent),
                      const SizedBox(height: 20),

                      const Text(
                        "Iniciar Sesión",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),

                      TextField(
                        controller: _correoController,
                        decoration: const InputDecoration(
                          labelText: "Correo",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Contraseña",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 30),

                      ElevatedButton.icon(
                        icon: const Icon(Icons.login),
                        label: const Text("Entrar"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlueAccent,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: _login,
                      ),

                      const SizedBox(height: 16),

                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RegisterScreen()),
                          );
                        },
                        child: const Text("¿No tienes cuenta? Regístrate"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
