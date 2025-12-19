import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SyllablesRepository {
  static const _key = 'admin_syllables';

  Future<void> save(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getAll();
    list.add(data);
    await prefs.setString(_key, jsonEncode(list));
  }

  Future<void> update(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getAll();

    final index = list.indexWhere((e) => e['id'] == data['id']);
    if (index != -1) {
      list[index] = data;
      await prefs.setString(_key, jsonEncode(list));
    }
  }

  Future<void> delete(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getAll();
    list.removeWhere((e) => e['id'] == id);
    await prefs.setString(_key, jsonEncode(list));
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];

    final decoded = jsonDecode(raw) as List;
    return decoded.cast<Map<String, dynamic>>();
  }
}

