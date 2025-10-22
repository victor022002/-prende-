import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ActivityFillWordScreen extends StatefulWidget {
  const ActivityFillWordScreen({super.key});

  @override
  State<ActivityFillWordScreen> createState() => _ActivityFillWordScreenState();
}

class _ActivityFillWordScreenState extends State<ActivityFillWordScreen> {
  final FlutterTts _tts = FlutterTts();

  final List<Map<String, dynamic>> _activities = [
    {'text': '_asa', 'options': ['C', 'L', 'M'], 'answer': 'C'},
    {'text': '_ato', 'options': ['G', 'P', 'R'], 'answer': 'G'},
    {'text': 'pe_', 'options': ['rro', 'sado', 'ro'], 'answer': 'rro'},
  ];

  int _currentIndex = 0;
  String? _selectedOption;
  bool _completed = false;

  Future<void> _speak(String text) async {
    await _tts.setLanguage("es-ES");
    await _tts.setSpeechRate(0.9);
    await _tts.setPitch(1.1);
    await _tts.speak(text);
  }

  void _checkAnswer() {
    final current = _activities[_currentIndex];
    if (_selectedOption == current['answer']) {
      _speak("¡Muy bien! La palabra es ${current['text'].replaceAll('_', current['answer'])}");
      _showDialog(true);
    } else {
      _speak("Inténtalo otra vez");
      _showDialog(false);
    }
  }

  void _showDialog(bool correct) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(correct ? "¡Correcto! 🎉" : "Incorrecto ❌"),
        content: Text(
          correct ? "Formaste bien la palabra." : "Esa no era la opción correcta.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (correct) _nextWord();
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
        _selectedOption = null;
      });
    } else {
      setState(() => _completed = true);
      _speak("¡Has completado todas las palabras!");
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = _activities[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text("Completa la palabra"),
        backgroundColor: Colors.lightBlueAccent,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: _completed
            ? const Text("🎉 ¡Completaste todas las palabras!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Completa:",
                      style: TextStyle(fontSize: 22, color: Colors.grey[800]),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      current['text'],
                      style: const TextStyle(
                          fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30),
                    Wrap(
                      spacing: 16,
                      children: current['options']
                          .map<Widget>(
                            (option) => ChoiceChip(
                              label: Text(option,
                                  style: const TextStyle(fontSize: 22)),
                              selected: _selectedOption == option,
                              onSelected: (_) {
                                setState(() {
                                  _selectedOption = option;
                                });
                                _checkAnswer();
                              },
                              selectedColor: Colors.greenAccent,
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.volume_up),
                      onPressed: () => _speak(
                          "Completa la palabra ${current['text']} con la opción correcta."),
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
    );
  }
}
