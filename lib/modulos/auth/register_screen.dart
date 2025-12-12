import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/modulos/home/home_screen.dart';
import '/models/student_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _auth = FirebaseAuth.instance;

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
    if (picked != null) setState(() => _fechaNac = picked);
  }

  Future<void> _register() async {
    final username = _usernameController.text.trim();
    final correo = _correoController.text.trim();
    final edad = int.tryParse(_edadController.text.trim()) ?? 0;
    final password = _passwordController.text.trim();

    if (username.isEmpty ||
        correo.isEmpty ||
        edad <= 0 ||
        password.isEmpty ||
        _fechaNac == null ||
        _cursoSeleccionado == null ||
        _tipoUsuario == null) {
      _showMessage("Completa todos los campos.");
      return;
    }

    try {
      // ⭐ 1) Crear usuario en Firebase Auth
      final userCred = await _auth.createUserWithEmailAndPassword(
        email: correo,
        password: password,
      );

      final uid = userCred.user!.uid;

      // ⭐ 2) Guardar datos del usuario en Supabase
      await Supabase.instance.client.from('users').insert({
        'id': uid,
        'correo_user': correo,
        'nombre_user': username,
        'edad_user': edad,
        'curso_user': _cursoSeleccionado,
        'fecha_nac': _fechaNac!.toIso8601String(),
        'tipo_usuario': _tipoUsuario!.toLowerCase(),
        'creado_en': DateTime.now().toIso8601String(),
      });

      _showMessage("Usuario registrado con éxito");

      // ⭐⭐ 3) Esperar a que Firebase active la sesión antes de navegar
      await userCred.user!.reload();
      await Future.delayed(const Duration(milliseconds: 300));

      final loggedIn = FirebaseAuth.instance.currentUser;

      if (loggedIn != null && mounted) {
        final user = loggedIn;

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
    } catch (e) {
      _showMessage("Error inesperado: $e");
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
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
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Icon(Icons.person_add,
                          size: 80, color: Colors.lightBlueAccent),
                      const SizedBox(height: 20),

                      const Text(
                        "Registrarse",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // CAMPOS DEL FORMULARIO
                      TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: "Nombre",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller: _correoController,
                        decoration: const InputDecoration(
                          labelText: "Correo",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller: _edadController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Edad",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "Curso",
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: "1° Básico", child: Text("1° Básico")),
                          DropdownMenuItem(
                              value: "2° Básico", child: Text("2° Básico")),
                        ],
                        onChanged: (v) => _cursoSeleccionado = v,
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "Tipo de usuario",
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: "estudiante", child: Text("Estudiante")),
                          DropdownMenuItem(
                              value: "tutor", child: Text("Tutor")),
                        ],
                        onChanged: (v) => _tipoUsuario = v,
                      ),

                      const SizedBox(height: 16),

                      // Fecha
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _fechaNac == null
                                  ? "Fecha de nacimiento: no seleccionada"
                                  : "Fecha: ${_fechaNac!.day}/${_fechaNac!.month}/${_fechaNac!.year}",
                            ),
                          ),
                          TextButton(
                            onPressed: _pickDate,
                            child: const Text("Seleccionar"),
                          )
                        ],
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

                      // BOTÓN REGISTRAR
                      ElevatedButton.icon(
                        icon: const Icon(Icons.person_add_alt),
                        label: const Text("Registrar usuario"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlueAccent,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: _register,
                      ),

                      const SizedBox(height: 16),

                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("¿Ya tienes cuenta? Inicia sesión"),
                      )
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
