import 'package:flutter/material.dart';
import '/repositories/syllables_repository.dart';
import 'admin_add_syllables_screen.dart';

class AdminActivitiesScreen extends StatefulWidget {
  const AdminActivitiesScreen({super.key});

  @override
  State<AdminActivitiesScreen> createState() =>
      _AdminActivitiesScreenState();
}

class _AdminActivitiesScreenState
    extends State<AdminActivitiesScreen> {
  final SyllablesRepository _repo = SyllablesRepository();
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = _repo.getAll();
    setState(() {});
  }

  Future<void> _delete(int id) async {
    await _repo.delete(id);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Actividades – Sílabas"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No hay actividades creadas",
                textAlign: TextAlign.center,
              ),
            );
          }

          final items = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (_, i) {
              final w = items[i];

              return ListTile(
                leading: const Icon(Icons.text_fields),
                title: Text(
                  w['word'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "${w['scenario']} • ${w['hard'] ? "Difícil" : "Fácil"}\n"
                  "Sílabas: ${w['syllables'].join(' - ')}",
                ),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// ✏️ EDITAR
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AdminAddSyllablesScreen(existing: w),
                          ),
                        );
                        _reload();
                      },
                    ),

                    /// 🗑️ BORRAR
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _delete(w['id']),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AdminAddSyllablesScreen(),
            ),
          );
          _reload();
        },
      ),
    );
  }
}
