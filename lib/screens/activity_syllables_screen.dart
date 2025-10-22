import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:collection/collection.dart'; // <-- IMPORT necesario

class ActivitySyllablesScreen extends StatefulWidget {
  const ActivitySyllablesScreen({super.key});

  @override
  State<ActivitySyllablesScreen> createState() => _ActivitySyllablesScreenState();
}

class _ActivitySyllablesScreenState extends State<ActivitySyllablesScreen> {
  final FlutterTts _tts = FlutterTts();
  final List<Map<String, dynamic>> _activities = [
    {
      'word': 'CASA',
      'syllables': ['CA', 'SA', 'PA', 'TO'],
      'correct': ['CA', 'SA']
    },
    {
      'word': 'MESA',
      'syllables': ['ME', 'SA', 'SO', 'PA'],
      'correct': ['ME', 'SA']
    },
    {
      'word': 'GATO',
      'syllables': ['GA', 'TO', 'PE', 'LA'],
      'correct': ['GA', 'TO']
    },
  ];

  int _currentIndex = 0;
  final List<String> _selected = [];
  bool _completed = false;

  final _listEq = const ListEquality<String>();

  Future<void> _speak(String text) async {
    await _tts.setLanguage("es-ES");
    await _tts.setPitch(1.1);
    await _tts.setSpeechRate(0.9);
    await _tts.speak(text);
  }

  void _selectSyllable(String syllable) {
    if (_selected.length >= _activities[_currentIndex]['correct'].length) return;
    if (_selected.contains(syllable)) return;
    setState(() {
      _selected.add(syllable);
    });
    if (_selected.length == (_activities[_currentIndex]['correct'] as List).length) {
      _checkAnswer();
    }
  }

  void _checkAnswer() {
    final current = _activities[_currentIndex];
    final List<String> correct = List<String>.from(current['correct'] as List);
    if (_listEq.equals(_selected, correct)) {
      _speak("¡Muy bien! La palabra es ${current['word']}");
      _showResultDialog(true);
    } else {
      _speak("Inténtalo de nuevo");
      _showResultDialog(false);
    }
  }

  void _showResultDialog(bool correct) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(correct ? "¡Correcto! 🎉" : "Ups 😅"),
        content: Text(correct
            ? "Formaste la palabra correctamente."
            : "Esa no es la palabra correcta."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (correct) _nextWord();
              setState(() => _selected.clear());
            },
            child: const Text("Continuar"),
          )
        ],
      ),
    );
  }

  void _nextWord() {
    if (_currentIndex < _activities.length - 1) {
      setState(() {
        _currentIndex++;
        _selected.clear();
      });
    } else {
      setState(() => _completed = true);
      _speak("¡Felicitaciones! Has completado todas las palabras.");
    }
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = _activities[_currentIndex];
    final syllables = List<String>.from(current['syllables'] as List);
    final correctLength = (current['correct'] as List).length;

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text("Ordena las sílabas"),
        backgroundColor: Colors.lightBlueAccent,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: _completed
            ? const Text(
                "🎉 ¡Completaste todas las palabras!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Forma la palabra:",
                      style: TextStyle(fontSize: 22, color: Colors.grey[800]),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: syllables
                          .map<Widget>(
                            (s) => ElevatedButton(
                              onPressed: _selected.contains(s) || _selected.length >= correctLength
                                  ? null
                                  : () => _selectSyllable(s),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.lightBlueAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                              child: Text(s,
                                  style: const TextStyle(
                                      fontSize: 20, fontWeight: FontWeight.bold)),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 30),
                    Wrap(
                      spacing: 10,
                      children: _selected
                          .map((s) => Chip(
                                label: Text(
                                  s,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                backgroundColor: Colors.green.shade200,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.volume_up),
                      onPressed: () => _speak("Forma la palabra ${current['word']}"),
                      label: const Text("Escuchar indicación"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Seleccionadas: ${_selected.length}/$correctLength",
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

