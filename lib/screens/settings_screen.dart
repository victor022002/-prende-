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
  String? _fotoUrl; // ruta local o URL
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

    final correo = user?.email ?? "Correo no disponible";

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.settings,
                    size: 32,
                    color: Colors.lightBlueAccent,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Configuración de cuenta",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Tarjeta de perfil
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 38,
                        backgroundColor: Colors.blue.shade100,
                        backgroundImage: avatarImage,
                        child: avatarImage == null
                            ? const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user != null ? "Usuario conectado" : "Sin sesión",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              correo,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed:
                                  _busy ? null : _changeProfilePhoto,
                              icon: const Icon(
                                Icons.photo_camera_outlined,
                                size: 18,
                              ),
                              label: Text(
                                _busy
                                    ? "Cambiando foto..."
                                    : "Cambiar foto de perfil",
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                foregroundColor: Colors.lightBlueAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Sección Seguridad
              Text(
                "Seguridad",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.lock_outline,
                        color: Colors.lightBlueAccent,
                      ),
                      title: const Text("Cambiar contraseña"),
                      subtitle: const Text(
                        "Actualiza tu contraseña de acceso",
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _busy ? null : _goToChangePasswordScreen,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Sección Sesión
              Text(
                "Sesión",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    children: [
                      const Text(
                        "Si cierras sesión deberás volver a iniciar con tu correo y contraseña.",
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.logout),
                          label: Text(
                            _busy ? "Cerrando sesión..." : "Cerrar sesión",
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _busy ? null : _logout,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}


