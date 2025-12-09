import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import '/modulos/home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  bool _isLoginMode = true;

  final _usernameController = TextEditingController();
  final _correoController = TextEditingController();
  final _edadController = TextEditingController();
  final _passwordController = TextEditingController();
  DateTime? _fechaNac;
  String? _tipoUsuario;
  String? _cursoSeleccionado;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 10),
      firstDate: DateTime(2000),
      lastDate: now,
      locale: const Locale('es', 'ES'),
    );
    if (picked != null) {
      setState(() => _fechaNac = picked);
    }
  }

  Future<void> _submit() async {
    final username = _usernameController.text.trim();
    final correo = _correoController.text.trim();
    final edad = int.tryParse(_edadController.text.trim()) ?? 0;
    final password = _passwordController.text.trim();

    if (_isLoginMode) {
      if (correo.isEmpty || password.isEmpty) {
        if (mounted) _showMessage("Completa todos los campos.");
        return;
      }

      try {
        await _auth.signInWithEmailAndPassword(email: correo, password: password);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) _showMessage("Error: ${e.message}");
      }
    } else {
      if (username.isEmpty ||
          correo.isEmpty ||
          edad <= 0 ||
          _fechaNac == null ||
          password.isEmpty ||
          _tipoUsuario == null ||
          _cursoSeleccionado == null) {
        if (mounted) _showMessage("Por favor, completa todos los campos.");
        return;
      }

      try {
        final cred = await _auth.createUserWithEmailAndPassword(
          email: correo,
          password: password,
        );

        final uid = cred.user!.uid;

        await _firestore.collection('usuarios').doc(uid).set({
          'uid': uid,
          'correo_user': correo,
          'edad_user': edad,
          'curso_user': _cursoSeleccionado,
          'fecha_nac': _fechaNac!.toIso8601String(),
          'nombre_user': username,
          'tipo_usuario': _tipoUsuario!.toLowerCase(),
          'creado_en': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;
        _showMessage("Usuario registrado correctamente");
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) _showMessage("Error: ${e.message}");
      } catch (e) {
        if (mounted) _showMessage("Error inesperado: $e");
      }
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🔹 Animación superior
              Lottie.asset(
                'assets/animations/Sun_breathing.json',
                height: 140,
              ),
              const SizedBox(height: 16),

              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.menu_book,
                          size: 80, color: Colors.lightBlueAccent),
                      const SizedBox(height: 20),
                      Text(
                        _isLoginMode ? "Iniciar Sesión" : "Registrarse",
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 30),

                      Column(
                        children: [
                          if (!_isLoginMode)
                            TextField(
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                labelText: "Nombre",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          if (!_isLoginMode) const SizedBox(height: 16),

                          TextField(
                            controller: _correoController,
                            decoration: const InputDecoration(
                              labelText: "Correo",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),

                          if (!_isLoginMode) ...[
                            // 🔹 Edad primero
                            TextField(
                              controller: _edadController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Edad",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 🔹 Curso tipo dropdown
                            DropdownButtonFormField<String>(
                              initialValue: _cursoSeleccionado,
                              decoration: const InputDecoration(
                                labelText: "Curso",
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(
                                    value: "1° Básico",
                                    child: Text("1° Básico")),
                                DropdownMenuItem(
                                    value: "2° Básico",
                                    child: Text("2° Básico")),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _cursoSeleccionado = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16),

                            // 🔹 Tipo de usuario
                            DropdownButtonFormField<String>(
                              initialValue: _tipoUsuario,
                              decoration: const InputDecoration(
                                labelText: "Tipo de usuario",
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(
                                    value: "Estudiante",
                                    child: Text("Estudiante")),
                                DropdownMenuItem(
                                    value: "Tutor", child: Text("Tutor")),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _tipoUsuario = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: Text(_fechaNac == null
                                      ? "Fecha de nacimiento: no seleccionada"
                                      : "Fecha de nacimiento: ${_fechaNac!.day}/${_fechaNac!.month}/${_fechaNac!.year}"),
                                ),
                                TextButton(
                                  onPressed: _pickDate,
                                  child: const Text("Seleccionar"),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],

                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: "Contraseña",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      ElevatedButton.icon(
                        icon: Icon(_isLoginMode
                            ? Icons.login
                            : Icons.person_add_alt_1),
                        label: Text(_isLoginMode
                            ? "Entrar"
                            : "Registrar usuario"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlueAccent,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: _submit,
                      ),
                      const SizedBox(height: 20),

                      TextButton(
                        onPressed: () {
                          setState(() => _isLoginMode = !_isLoginMode);
                        },
                        child: Text(
                          _isLoginMode
                              ? "¿No tienes cuenta? Regístrate"
                              : "¿Ya tienes cuenta? Inicia sesión",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}






