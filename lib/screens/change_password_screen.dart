import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/database_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _repeatCtrl = TextEditingController();

  bool _busy = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _repeatCtrl.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final current = _currentCtrl.text.trim();
    final newPass = _newCtrl.text.trim();
    final repeat = _repeatCtrl.text.trim();

    if (current.isEmpty || newPass.isEmpty || repeat.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos.")),
      );
      return;
    }

    if (newPass != repeat) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Las nuevas contraseñas no coinciden."),
        ),
      );
      return;
    }

    if (newPass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("La contraseña debe tener al menos 6 caracteres."),
        ),
      );
      return;
    }

    setState(() => _busy = true);

    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw "Usuario no autenticado.";
      }

      // Reautenticar
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: current,
      );
      await user.reauthenticateWithCredential(cred);

      // Actualizar contraseña
      await user.updatePassword(newPass);

      // Firestore: marcar actualización
      await _firestore.collection('usuarios').doc(user.uid).set(
        {
          'actualizado_en': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      // SQLite: mantener coherencia
      await DatabaseService.instance.upsertUserProfile(
        uid: user.uid,
        email: user.email ?? '',
        fotoUrl: null, // no tocamos la foto aquí
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Contraseña actualizada correctamente"),
        ),
      );

      Navigator.pop(context); // volver a Configuración
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("No se pudo cambiar la contraseña: $e"),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text("Cambiar contraseña"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _currentCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Contraseña actual",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Nueva contraseña",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _repeatCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Repetir nueva contraseña",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: Text(_busy ? "Procesando..." : "Guardar"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _busy ? null : _changePassword,
              ),
            ),
          ],
        ),
      ),
    );
  }
}