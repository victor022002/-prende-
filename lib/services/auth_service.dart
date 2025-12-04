import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart' as local;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<User?> login(String correo, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: correo,
        password: password,
      );
      return cred.user;
    } catch (e) {
      print("Error en login: $e");
      return null;
    }
  }

  Future<User?> register(local.User userData) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: userData.correo,
        password: userData.password,
      );

      final uid = cred.user!.uid;

      await _db.collection('usuarios').doc(uid).set({
        'nombre_user': userData.username,
        'correo_user': userData.correo,
        'curso_user': userData.curso,
        'edad_user': userData.edad,
        'fecha_nac': userData.fechaNac,
        'tipo_usuario': 'estudiante',
        'foto_url': null,
        'creado_en': FieldValue.serverTimestamp(),
      });

      return cred.user;
    } catch (e) {
      print("Error en registro: $e");
      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}



