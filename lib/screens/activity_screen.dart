import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/student_model.dart';
import '../services/database_service.dart';

class ActivityScreen extends StatefulWidget {
  final Student? student;

  const ActivityScreen({super.key, this.student});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final FlutterTts _tts = FlutterTts();

  final String _cuento = """
Había una vez un conejo que vivía en un bosque lleno de colores,
Cada mañana saltaba feliz mientras saludaba al sol,
Un día decidió salir a explorar y descubrió cosas maravillosas,
""";

  List<String> _words = [];
  int _currentWordIndex = -1;
  bool _isReading = false;

  @override
  void initState() {
    super.initState();
    _setupTTS();

    _words = _cuento
        .replaceAll("\n", " ")
        .split(" ")
        .where((w) => w.trim().isNotEmpty)
        .toList();
  }

  Future<void> _setupTTS() async {
    await _tts.setLanguage("es-ES");
    await _tts.setPitch(1.05);
    await _tts.setSpeechRate(0.80);

    try {
      final voices = await _tts.getVoices;
      final goodVoice = voices?.firstWhere(
        (v) =>
            v.toString().toLowerCase().contains("es") &&
            v.toString().toLowerCase().contains("female"),
        orElse: () => null,
      );
      if (goodVoice != null) await _tts.setVoice(goodVoice);
    } catch (_) {}
  }

  Future<void> _startReading() async {
    if (_isReading) return;

    setState(() {
      _currentWordIndex = -1;
      _isReading = true;
    });

    _readWithHighlight();
    await _tts.speak(_cuento);
  }

  Future<void> _readWithHighlight() async {
    const baseMsPerChar = 93;

    for (var i = 0; i < _words.length; i++) {
      if (!_isReading) return;

      setState(() => _currentWordIndex = i);

      final delay = _words[i].length * baseMsPerChar;
      await Future.delayed(Duration(milliseconds: delay));
    }

    _finishReading();
  }

  Future<void> _finishReading() async {
    setState(() {
      _isReading = false;
      _currentWordIndex = -1;
    });

    if (widget.student != null) {
      final st = widget.student!;

      if (st.completedReading == 0) {
        await DatabaseService.instance.updateProgress(
          st.id!,
          (st.progress + 10).clamp(0, 100),
        );

        await DatabaseService.instance.updateStudentField(
          st.id!,
          "completedReading",
          1,
        );
      }
    }

    if (!mounted) return;

    final alreadyDone =
        widget.student != null && widget.student!.completedReading == 1;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("¡Lectura terminada! 🎉"),
        content: Text(
          alreadyDone
              ? "Esta actividad ya estaba completada.\nNo ganaste progreso extra."
              : "Ganaste +10% de progreso.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Volver"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text("Lectura guiada"),
        backgroundColor: Colors.lightBlueAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: RichText(
                    text: TextSpan(
                      children: _words.asMap().entries.map((entry) {
                        final i = entry.key;
                        final w = entry.value;

                        return TextSpan(
                          text: "$w ",
                          style: TextStyle(
                            fontSize: 26,
                            height: 1.55,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                            backgroundColor: i == _currentWordIndex
                                ? Colors.yellow[300]
                                : Colors.transparent,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _startReading,
              icon: const Icon(Icons.volume_up),
              label: const Text("Leer cuento"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



