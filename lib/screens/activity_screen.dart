import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/database_service.dart';
import '../models/student_model.dart';

class ActivityScreen extends StatefulWidget {
  final Student? student; // 👈 Hacemos opcional el parámetro

  const ActivityScreen({super.key, this.student});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;
  bool _completed = false;

  // 🧠 Textos educativos cargados localmente (modo offline)
  final List<String> _texts = [
    "La mariposa vuela sobre las flores.",
    "Mi perro se llama Max y le gusta correr.",
    "El sol brilla en el cielo azul.",
    "Me gusta leer cuentos con mi mamá.",
  ];

  int _currentIndex = 0;

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    await _tts.setLanguage("es-ES");
    await _tts.setPitch(1.1);
    await _tts.setSpeechRate(0.9);

    setState(() => _isSpeaking = true);
    await _tts.speak(text);
    setState(() => _isSpeaking = false);
  }

  Future<void> _nextText() async {
    if (_currentIndex < _texts.length - 1) {
      setState(() => _currentIndex++);
    } else {
      // 🏁 Fin de actividad
      setState(() => _completed = true);

      // ✅ Solo actualiza progreso si hay estudiante asignado
      if (widget.student != null) {
        await DatabaseService.instance.updateProgress(
          widget.student!.id!,
          (widget.student!.progress + 10).clamp(0, 100),
        );
      }

      _showCompletedDialog();
    }
  }

  void _showCompletedDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("¡Actividad completada! 🎉"),
        content: const Text("Has ganado 10% más de progreso."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Volver al inicio"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentText = _texts[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: Text(
          widget.student != null
              ? "Lectura de ${widget.student!.name}"
              : "Lectura guiada (modo libre)",
        ),
        backgroundColor: Colors.lightBlueAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: Colors.white,
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    currentText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isSpeaking ? null : () => _speak(currentText),
                    icon: const Icon(Icons.volume_up),
                    label: const Text("Leer en voz alta"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                    onPressed: _completed ? null : _nextText,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text("Siguiente"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
