import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '/models/student_model.dart';
import '/modulos/home/home_screen.dart';
import '/modulos/auth/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);

    try {
      final credential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );

      final user = credential.user!;
      final student = Student(
        id: user.uid.hashCode,
        name: user.email?.split('@').first ?? "Alumno",
        email: user.email ?? "",
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(student: student),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al iniciar sesión")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  // =========================
  // 👤 ENTRAR COMO INVITADO
  // =========================
  void _loginAsGuest() {
    final guest = Student(
      id: -1, // 🔑 ID FIJO PARA INVITADO
      name: "Invitado",
      email: "",
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(student: guest),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Aprende+",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                TextField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(
                    labelText: "Correo",
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Contraseña",
                  ),
                ),

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text("Iniciar sesión"),
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: const Text("Crear cuenta"),
                ),

                const SizedBox(height: 30),

                const Divider(),

                const SizedBox(height: 12),

                // 👤 BOTÓN INVITADO
                OutlinedButton.icon(
                  icon: const Icon(Icons.person_outline),
                  label: const Text("Entrar como invitado"),
                  onPressed: _loginAsGuest,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
