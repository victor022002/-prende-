import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ActivityCompleteWordScreen extends StatefulWidget {
  const ActivityCompleteWordScreen({super.key});

  @override
  State<ActivityCompleteWordScreen> createState() => _ActivityCompleteWordScreenState();
}

class _ActivityCompleteWordScreenState extends State<ActivityCompleteWordScreen> {
  final FlutterTts _tts = FlutterTts();
  bool _completed = false;
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _activities = [
    {
      'question': '_asa',
      'options': ['C', 'L', 'M'],
      'answer': 'C',
      'word': 'CASA',
    },
    {
      'question': '_ato',
      'options': ['G', 'P', 'R'],
      'answer': 'G',
      'word': 'GATO',
    },
    {
      'question': '_esa',
      'options': ['M', 'N', 'T'],
      'answer': 'M',
      'word': 'MESA',
    },
  ];

  Future<void> _speak(String text) async {
    await _tts.setLanguage("es-ES");
    await _tts.setPitch(1.1);
    await _tts.setSpeechRate(0.9);
    await _tts.speak(text);
  }

  void _checkAnswer(String option) {
    final current = _activities[_currentIndex];
    if (option == current['answer']) {
      _speak("¡Muy bien! La palabra es ${current['word']}");
      _showResultDialog(true);
    } else {
      _speak("Ups, intenta de nuevo.");
      _showResultDialog(false);
    }
  }

  void _showResultDialog(bool correct) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(correct ? "¡Correcto! 🎉" : "Inténtalo de nuevo 😅"),
        content: Text(correct
            ? "Has completado correctamente la palabra."
            : "Vuelve a intentarlo."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (correct) _nextActivity();
            },
            child: const Text("Continuar"),
          )
        ],
      ),
    );
  }

  void _nextActivity() {
    if (_currentIndex < _activities.length - 1) {
      setState(() => _currentIndex++);
    } else {
      setState(() => _completed = true);
      _speak("¡Felicitaciones! Has completado todas las palabras.");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_completed) {
      return Scaffold(
        backgroundColor: Colors.blue.shade50,
        appBar: AppBar(
          title: const Text("Completa la palabra"),
          backgroundColor: Colors.lightBlueAccent,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text(
            "🎉 ¡Has completado todas las palabras!",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final current = _activities[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text("Completa la palabra"),
        backgroundColor: Colors.lightBlueAccent,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Selecciona la letra o sílaba que falta:",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Text(
                current['question'],
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30),
              Wrap(
                spacing: 12,
                children: current['options'].map<Widget>((option) {
                  return ElevatedButton(
                    onPressed: () => _checkAnswer(option),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                    child: Text(
                      option,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.volume_up),
                label: const Text("Escuchar palabra"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _speak("Completa la palabra ${current['word']}"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
