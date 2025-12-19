import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '/models/student_model.dart';
import '/models/progress_model.dart';
import '/repositories/progress_repository.dart';
import '/services/achievement_service.dart'; 
import '/widgets/achievement_overlay.dart';

class WritingScreen extends StatefulWidget {
  final String letter;
  final Student student;

  const WritingScreen({
    super.key,
    required this.letter,
    required this.student,
  });

  @override
  State<WritingScreen> createState() => _WritingScreenState();
}

class _WritingScreenState extends State<WritingScreen> {
  final FlutterTts _tts = FlutterTts();
  final ProgressRepository _progressRepo = ProgressRepository();

  List<List<Offset>> _lines = [];
  List<Offset> _currentLine = [];

  bool _saved = false;

  /// 🧠 activityId por vocal
  int get activityId {
    const base = 200;
    const vowels = ['A', 'E', 'I', 'O', 'U'];
    return base + vowels.indexOf(widget.letter.toUpperCase());
  }

  @override
  void initState() {
    super.initState();
    _speak("Escribe la vocal ${widget.letter}");
  }

  Future<void> _speak(String text) async {
    await _tts.setLanguage("es-ES");
    await _tts.setSpeechRate(0.55);
    await _tts.setPitch(1.2);
    await _tts.speak(text);
  }

  void _clearDrawing() {
    setState(() => _lines.clear());
  }

  /// ✅ VALIDAR + GUARDAR PROGRESO
  Future<void> _validate() async {
    if (_lines.isEmpty) {
      await _speak("No has escrito nada, intenta de nuevo");
      return;
    }

    if (!_saved) {
      await _progressRepo.saveOrUpdate(
        Progress(
          studentId: widget.student.id!,
          activityId: activityId,
          status: ProgressStatus.completed,
          attempts: 1,
          score: 100,
        ),
      );
      _saved = true;
    }

    // 🔊 MENSAJE PRINCIPAL DEL JUEGO
    await _speak("¡Muy bien! Has completado la actividad de escritura");

    // 🏆 LOGROS (DESPUÉS DEL FEEDBACK)
    final achievement =
        await AchievementService.checkNew(widget.student.id!);

    if (achievement != null && mounted) {
      AchievementOverlay.show(context, achievement);

      await _speak(
        "Has desbloqueado el logro ${achievement.title}",
      );
    }

    // UI FINAL
    _showSuccessDialog();
  }


  void _showSuccessDialog() {
    _speak(
      "¡Felicitaciones! Escribiste correctamente la letra ${widget.letter}",
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text("¡Felicitaciones! 🎉"),
        content: Text(
          "Escribiste correctamente la letra ${widget.letter}",
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // vuelve al menú
            },
            child: const Text("Continuar"),
          )
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
        title: Text("Escribe la '${widget.letter}'"),
        backgroundColor: Colors.lightBlueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: () => _speak("Vocal ${widget.letter}"),
          ),
        ],
      ),
      body: Stack(
        children: [
          /// 🔤 LETRA GUÍA
          Center(
            child: Text(
              widget.letter,
              style: TextStyle(
                fontSize: 300,
                fontWeight: FontWeight.bold,
                color: Colors.grey.withOpacity(0.15),
              ),
            ),
          ),

          /// ✏️ DIBUJO (COORDENADAS CORREGIDAS)
          Positioned.fill(
            child: GestureDetector(
              onPanStart: (details) {
                setState(() {
                  _currentLine = [details.localPosition];
                  _lines.add(_currentLine);
                });
              },

              onPanUpdate: (details) {
                setState(() {
                  _currentLine.add(details.localPosition);
                });
              },
              onPanEnd: (_) => _currentLine = [],
              child: CustomPaint(
                painter: _WritingPainter(_lines),
                size: Size.infinite,
              ),
            ),
          ),

          /// 🧹 BORRAR
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.redAccent,
              onPressed: _clearDrawing,
              child: const Icon(Icons.delete),
            ),
          ),

          /// ✅ VALIDAR
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.green,
              onPressed: _validate,
              child: const Icon(Icons.check),
            ),
          ),
        ],
      ),
    );
  }
}

class _WritingPainter extends CustomPainter {
  final List<List<Offset>> lines;

  _WritingPainter(this.lines);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    for (var line in lines) {
      for (int i = 0; i < line.length - 1; i++) {
        canvas.drawLine(line[i], line[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(_) => true;
}
