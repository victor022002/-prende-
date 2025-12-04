import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'database_service.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _db.collection('usuarios').doc(uid).get();
      if (!doc.exists) return null;
      return doc.data() as Map<String, dynamic>;
    } catch (e) {
      print('Error getUserData: $e');
      return null;
    }
  }

  Future<String?> changeProfileImage(String uid) async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (picked == null) return null;

      final file = File(picked.path);

      final ref = _storage.ref().child('profile_images').child('$uid.jpg');
      await ref.putFile(file);
      final url = await ref.getDownloadURL();

      await _db.collection('usuarios').doc(uid).update({
        'foto_url': url,
      });

      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePhotoURL(url);
      }

      await DatabaseService.instance.upsertUserProfile(
        uid: uid,
        email: user?.email ?? '',
        fotoUrl: url,
      );

      return url;
    } catch (e) {
      print('Error changeProfileImage: $e');
      return null;
    }
  }

  Future<void> syncRemoteToLocal() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final doc = await _db.collection('usuarios').doc(user.uid).get();
      if (!doc.exists) return;

      final data = doc.data() as Map<String, dynamic>?;

      await DatabaseService.instance.upsertUserProfile(
        uid: user.uid,
        email: data?['correo_user'] ?? user.email ?? '',
        fotoUrl: data?['foto_url'],
      );
    } catch (e) {
      print('Error syncRemoteToLocal: $e');
    }
  }
}