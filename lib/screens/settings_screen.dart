import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../services/database_service.dart';
import 'login_screen.dart';
import 'change_password_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  User? _user;
  String? _fotoUrl; // ruta local o URL remota
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _fotoUrl = _user?.photoURL;
    _loadOfflineProfile();
  }

  Future<void> _loadOfflineProfile() async {
    final user = _user;
    if (user == null) return;

    final cached = await DatabaseService.instance.getUserProfile(user.uid);
    final cachedUrl = cached?['foto_url'] as String?;
    if (!mounted) return;

    if ((_fotoUrl == null || _fotoUrl!.isEmpty) &&
        cachedUrl != null &&
        cachedUrl.isNotEmpty) {
      setState(() => _fotoUrl = cachedUrl);
    }
  }

  Future<void> _logout() async {
    try {
      setState(() => _busy = true);
      await _auth.signOut();

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cerrar sesión: $e")),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _changeProfilePhoto() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
      );
      if (picked == null) return;

      setState(() => _busy = true);

      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'profile_${user.uid}${p.extension(picked.path)}';
      final localPath = p.join(appDir.path, fileName);

      await File(picked.path).copy(localPath);

      await DatabaseService.instance.upsertUserProfile(
        uid: user.uid,
        email: user.email ?? '',
        fotoUrl: localPath,
      );

      if (!mounted) return;
      setState(() {
        _fotoUrl = localPath;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Foto de perfil actualizada")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No se pudo actualizar la foto: $e")),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _goToChangePasswordScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ChangePasswordScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;

    ImageProvider? avatarImage;
    if (_fotoUrl != null && _fotoUrl!.isNotEmpty) {
      if (_fotoUrl!.startsWith('http')) {
        avatarImage = NetworkImage(_fotoUrl!);
      } else {
        avatarImage = FileImage(File(_fotoUrl!));
      }
    }

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  const Icon(
                    Icons.settings,
                    size: 90,
                    color: Colors.lightBlueAccent,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Configuración de cuenta",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user != null
                        ? "Sesión iniciada como:\n${user.email}"
                        : "Usuario no identificado",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 26),
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: Colors.white,
                    backgroundImage: avatarImage,
                    child: avatarImage == null
                        ? const Icon(
                            Icons.person,
                            size: 42,
                            color: Colors.lightBlueAccent,
                          )
                        : null,
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.photo_camera),
                    label: Text(
                      _busy ? "Procesando..." : "Cambiar foto de perfil",
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _busy ? null : _changeProfilePhoto,
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.lock),
                    label: const Text("Cambiar contraseña"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.lightBlueAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(
                        color: Colors.lightBlueAccent,
                        width: 1.5,
                      ),
                    ),
                    onPressed: _busy ? null : _goToChangePasswordScreen,
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: Text(
                      _busy ? "Cerrando sesión..." : "Cerrar sesión",
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _busy ? null : _logout,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


