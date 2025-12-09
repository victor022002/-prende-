import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class WritingScreen extends StatefulWidget {
  final String letter;

  const WritingScreen({super.key, required this.letter});

  @override
  State<WritingScreen> createState() => _WritingScreenState();
}

class _WritingScreenState extends State<WritingScreen> {
  final FlutterTts _tts = FlutterTts();

  List<List<Offset>> _lines = [];
  List<Offset> _currentLine = [];

  @override
  void initState() {
    super.initState();
    _speak("Escribe la vocal ${widget.letter}");
  }

  Future<void> _speak(String text) async {
    await _tts.setLanguage("es-ES");
    await _tts.setSpeechRate(0.55);
    await _tts.setPitch(1.3);
    _tts.speak(text);
  }

  void _clearDrawing() {
    setState(() => _lines.clear());
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

      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // LETRA GUÍA DEBAJO
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

              // ÁREA DE DIBUJO AJUSTADA
              Positioned.fill(
                child: GestureDetector(
                  onPanStart: (details) {
                    final RenderBox box = context.findRenderObject() as RenderBox;
                    final localOffset = box.globalToLocal(details.globalPosition);

                    setState(() {
                      _currentLine = [localOffset];
                      _lines.add(_currentLine);
                    });
                  },

                  onPanUpdate: (details) {
                    final RenderBox box = context.findRenderObject() as RenderBox;
                    final localOffset = box.globalToLocal(details.globalPosition);

                    setState(() {
                      _currentLine.add(localOffset);
                    });
                  },

                  onPanEnd: (_) => _currentLine = [],

                  child: CustomPaint(
                    painter: _WritingPainter(_lines),
                    size: Size.infinite,
                  ),
                ),
              ),

              // BOTÓN BORRAR
              Positioned(
                bottom: 20,
                right: 20,
                child: FloatingActionButton(
                  backgroundColor: Colors.redAccent,
                  onPressed: _clearDrawing,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
              )
            ],
          );
        },
      ),

    );
  }
}

class _WritingPainter extends CustomPainter {
  final List<List<Offset>> lines;

  _WritingPainter(this.lines);

  @override
  void paint(Canvas canvas, Size size) {
    for (var line in lines) {
      final paint = Paint()
        ..color = Colors.black
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;

      for (int i = 0; i < line.length - 1; i++) {
        canvas.drawLine(line[i], line[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
