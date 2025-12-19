import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '/repositories/syllables_repository.dart';

class AdminAddSyllablesScreen extends StatefulWidget {
  final Map<String, dynamic>? existing; // 👈 null = crear | map = editar

  const AdminAddSyllablesScreen({
    super.key,
    this.existing,
  });

  @override
  State<AdminAddSyllablesScreen> createState() =>
      _AdminAddSyllablesScreenState();
}

class _AdminAddSyllablesScreenState
    extends State<AdminAddSyllablesScreen> {
  final _wordCtrl = TextEditingController();
  final List<TextEditingController> _syllableCtrls = [];

  String _scenario = "city";
  bool _hard = false;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  final _repo = SyllablesRepository();

  @override
  void initState() {
    super.initState();

    /// 🔹 MODO EDITAR
    if (widget.existing != null) {
      final w = widget.existing!;
      _wordCtrl.text = w['word'];
      _scenario = w['scenario'];
      _hard = w['hard'];

      final syllables = List<String>.from(w['syllables']);
      for (final s in syllables) {
        _syllableCtrls.add(TextEditingController(text: s));
      }

      if (w['image'] != null) {
        _imageFile = File(w['image']);
      }
    } else {
      /// 🔹 MODO CREAR (mínimo 2 sílabas)
      _syllableCtrls.add(TextEditingController());
      _syllableCtrls.add(TextEditingController());
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  void _save() async {
    final repo = SyllablesRepository();

    final word = _wordCtrl.text.trim().toUpperCase();
    final syllables = _syllableCtrls
        .map((c) => c.text.trim().toUpperCase())
        .where((s) => s.isNotEmpty)
        .toList();

    if (word.isEmpty || syllables.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa los datos")),
      );
      return;
    }

    final wordData = {
      'id': widget.existing?['id'] ??
          DateTime.now().millisecondsSinceEpoch,
      'word': word,
      'syllables': syllables,
      'correct': syllables,
      'image': _imageFile?.path,
      'scenario': _scenario,
      'hard': _hard,
    };

    if (widget.existing != null) {
      await repo.update(wordData); // ✔️
    } else {
      await repo.save(wordData);   // ✔️
    }

    Navigator.pop(context);
  }



  void _removeSyllable(int index) {
    if (_syllableCtrls.length <= 2) return; // mínimo 2
    setState(() {
      _syllableCtrls.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Editar sílabas" : "Agregar sílabas"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// 🔤 PALABRA
              TextField(
                controller: _wordCtrl,
                decoration:
                    const InputDecoration(labelText: "Palabra final"),
              ),

              const SizedBox(height: 20),

              /// 🌍 ESCENARIO
              DropdownButtonFormField<String>(
                value: _scenario,
                decoration:
                    const InputDecoration(labelText: "Escenario"),
                items: const [
                  DropdownMenuItem(
                      value: "city", child: Text("Ciudad")),
                  DropdownMenuItem(
                      value: "nature", child: Text("Naturaleza")),
                  DropdownMenuItem(
                      value: "objects", child: Text("Objetos")),
                ],
                onChanged: (v) => setState(() => _scenario = v!),
              ),

              const SizedBox(height: 12),

              /// 🎯 DIFICULTAD
              SwitchListTile(
                title: const Text("Difícil (letras)"),
                value: _hard,
                onChanged: (v) => setState(() => _hard = v),
              ),

              const SizedBox(height: 20),

              /// 🧩 SÍLABAS
              const Text(
                "Sílabas (orden correcto)",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              ...List.generate(_syllableCtrls.length, (i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _syllableCtrls[i],
                          decoration: InputDecoration(
                            labelText: "Sílaba ${i + 1}",
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeSyllable(i),
                      ),
                    ],
                  ),
                );
              }),

              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _syllableCtrls.add(TextEditingController());
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text("Agregar sílaba"),
              ),

              const SizedBox(height: 20),

              /// 🖼️ IMAGEN
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text("Seleccionar imagen"),
              ),

              if (_imageFile != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Image.file(
                    _imageFile!,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),

              const SizedBox(height: 30),

              /// 💾 GUARDAR
              ElevatedButton(
                onPressed: _save,
                child:
                    Text(isEdit ? "Guardar cambios" : "Guardar actividad"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
