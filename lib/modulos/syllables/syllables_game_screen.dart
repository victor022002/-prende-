import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '/models/student_model.dart';
import '/models/progress_model.dart';
import '/repositories/progress_repository.dart';
import '/services/achievement_service.dart';
import '/widgets/achievement_overlay.dart';

class SyllablesGameScreen extends StatefulWidget {
  final List<Map<String, dynamic>> words;
  final bool hard;
  final String scenario; // city | nature | objects
  final Student student;

  const SyllablesGameScreen({
    super.key,
    required this.words,
    required this.hard,
    required this.scenario,
    required this.student,
  });

  @override
  State<SyllablesGameScreen> createState() => _SyllablesGameScreenState();
}

class _SyllablesGameScreenState extends State<SyllablesGameScreen> {
  final FlutterTts _tts = FlutterTts();

  int _index = 0;
  final List<Map<String, int>> _selected = [];

  bool _completed = false;
  bool _errorFlash = false;

  // ======================
  // 🎯 ACTIVITY ID FIJO
  // ======================
  int get activityId {
    const baseIds = {
      'city': 100,
      'nature': 110,
      'objects': 120,
    };

    final base = baseIds[widget.scenario]!;
    return base + (widget.hard ? 1 : 0);
  }

  @override
  void initState() {
    super.initState();

    _tts.setCompletionHandler(() {
      if (_completed && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  // ======================
  // 🔊 TTS
  // ======================
  Future<void> _speak(String text) async {
    await _tts.setLanguage("es-ES");
    await _tts.setSpeechRate(0.55);
    await _tts.setPitch(1.2);
    await _tts.speak(text);
  }

  // ======================
  // 🧠 LÓGICA
  // ======================
  String _buildSelectedWord(List<String> syllables) {
    return _selected.map((e) => syllables[e['index']!]).join();
  }

  void _select(int index) {
    final activity = widget.words[_index];
    final correct = List<String>.from(activity['correct']);

    if (_selected.length >= correct.length) return;
    if (_selected.any((e) => e['index'] == index)) return;

    final syllables = List<String>.from(activity['syllables']);
    _speak(syllables[index]);

    setState(() {
      _selected.add({'index': index});
    });

    if (_selected.length == correct.length) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _checkAnswer(correct, syllables);
      });
    }
  }

  void _removeFromSlot(int slotIndex) {
    if (slotIndex < _selected.length) {
      setState(() {
        _selected.removeAt(slotIndex);
      });
    }
  }

  void _checkAnswer(List<String> correct, List<String> syllables) async {
    final activity = widget.words[_index];
    final word = activity['word'];

    final selectedWord = _buildSelectedWord(syllables);
    final correctWord = correct.join();

    if (selectedWord == correctWord) {
      await _speak("¡Muy bien! Formaste la palabra $word");
      _showSuccessDialog();
    } else {
      _speak("Inténtalo otra vez");
      setState(() {
        _selected.clear();
        _errorFlash = true;
      });

      Future.delayed(
        const Duration(milliseconds: 300),
        () => setState(() => _errorFlash = false),
      );
    }
  }

  // ======================
  // 🟢 DIÁLOGO
  // ======================
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text("¡Muy bien!"),
        content: const Text("Formaste la palabra correctamente."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _nextWord();
            },
            child: const Text("Continuar"),
          )
        ],
      ),
    );
  }

  void _nextWord() {
    if (_index < widget.words.length - 1) {
      setState(() {
        _index++;
        _selected.clear();
        _errorFlash = false;
      });
    } else {
      _finishGame();
    }
  }

  // ======================
  // 🏁 FINAL
  // ======================
  Future<void> _finishGame() async {
    setState(() => _completed = true);

    final repo = ProgressRepository();

    await repo.saveOrUpdate(
      Progress(
        studentId: widget.student.id!,
        activityId: activityId, // ID fijo correcto
        status: ProgressStatus.completed,
        attempts: 1,
        score: 100,
      ),
    );

    // 🗣️ MENSAJE FINAL DEL JUEGO (PRIORIDAD)
    await _speak(
      "¡Felicitaciones! Completaste todas las palabras.",
    );

    // 🏆 LOGROS (SOLO VISUAL)
    final achievement =
        await AchievementService.checkNew(widget.student.id!);

    if (achievement != null && mounted) {
      AchievementOverlay.show(context, achievement);

      // 🗣️ MENSAJE DE LOGRO (DESPUÉS)
      await _speak(
        "Has desbloqueado el logro ${achievement.title}",
      );
    }
  }


  // ======================
  // 🖼️ IMAGEN
  // ======================
  Widget _buildImage(String path) {
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.contain);
    }
    return Image.file(File(path), fit: BoxFit.contain);
  }

  // ======================
  // 🖼️ UI
  // ======================
  @override
  Widget build(BuildContext context) {
    if (_completed) {
      return Scaffold(
        backgroundColor: Colors.blue.shade50,
        body: const Center(
          child: Text(
            "¡Actividad completada!",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    final activity = widget.words[_index];
    final correct = List<String>.from(activity['correct']);
    final syllables = List<String>.from(activity['syllables']);

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text("Ordena las sílabas"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    "Palabra ${_index + 1} de ${widget.words.length}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (activity['image'] != null)
                    SizedBox(
                      height: 150,
                      child: _buildImage(activity['image']),
                    ),

                  const SizedBox(height: 20),

                  Text(
                    activity['word'],
                    style: TextStyle(
                      fontSize: widget.hard ? 22 : 34,
                      fontWeight: FontWeight.bold,
                      letterSpacing: widget.hard ? 2 : 4,
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// 🟦 CASILLEROS
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    children: List.generate(correct.length, (i) {
                      final text = i < _selected.length
                          ? syllables[_selected[i]['index']!]
                          : "";

                      return GestureDetector(
                        onTap:
                            text.isNotEmpty ? () => _removeFromSlot(i) : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 80,
                          height: 60,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _errorFlash
                                ? Colors.red.shade100
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black26, width: 2),
                          ),
                          child: Text(
                            text,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 30),

                  /// 🧩 SÍLABAS
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 14,
                    runSpacing: 14,
                    children: List.generate(syllables.length, (i) {
                      final used =
                          _selected.any((e) => e['index'] == i);

                      return AnimatedOpacity(
                        opacity: used ? 0.35 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: GestureDetector(
                          onTap: used ? null : () => _select(i),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 26,
                              vertical: 18,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.lightBlueAccent,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Text(
                              syllables[i],
                              style: const TextStyle(
                                fontSize: 26,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 35),

                  ElevatedButton.icon(
                    icon: const Icon(Icons.volume_up),
                    onPressed: () {
                      _speak(
                        widget.hard
                            ? "Forma la palabra"
                            : "Forma la palabra ${activity['word']}",
                      );
                    },
                    label: const Text("Escuchar indicación"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
