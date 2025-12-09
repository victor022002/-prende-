import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ActivitySyllablesScreen extends StatefulWidget {
  const ActivitySyllablesScreen({super.key});

  @override
  State<ActivitySyllablesScreen> createState() =>
      _ActivitySyllablesScreenState();
}

class _ActivitySyllablesScreenState extends State<ActivitySyllablesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text("Ordena las sílabas"),
        backgroundColor: Colors.lightBlueAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              "Elige la dificultad",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            _difficultyButton(
              title: "Fácil (2 sílabas)",
              color: Colors.greenAccent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SyllablesGameScreen(
                      words: _easyWords,
                      hard: false,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            _difficultyButton(
              title: "Difícil (letra por letra)",
              color: Colors.orangeAccent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SyllablesGameScreen(
                      words: _hardWords,
                      hard: true,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _difficultyButton({
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 30),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}


final List<Map<String, dynamic>> _easyWords = [
  {
    'word': 'CASA',
    'image': 'assets/imagenes/ordenar_casa.png',
    'syllables': ['CA', 'SA', 'LA', 'VA'],
    'correct': ['CA', 'SA'],
  },
  {
    'word': 'MESA',
    'image': 'assets/imagenes/ordenar_mesa.png',
    'syllables': ['ME', 'SA', 'SO', 'PA'],
    'correct': ['ME', 'SA'],
  },
  {
    'word': 'GATO',
    'image': 'assets/imagenes/ordenar_gato.png',
    'syllables': ['GA', 'TO', 'PE', 'LA'],
    'correct': ['GA', 'TO'],
  },
];


final List<Map<String, dynamic>> _hardWords = [
  {
    'word': 'CASA',
    'image': 'assets/imagenes/ordenar_casa.png',
    'syllables': ['C', 'A', 'S', 'A'],
    'correct': ['C', 'A', 'S', 'A'],
  },
  {
    'word': 'MESA',
    'image': 'assets/imagenes/ordenar_mesa.png',
    'syllables': ['M', 'E', 'S', 'A'],
    'correct': ['M', 'E', 'S', 'A'],
  },
  {
    'word': 'GATO',
    'image': 'assets/imagenes/ordenar_gato.png',
    'syllables': ['G', 'A', 'T', 'O'],
    'correct': ['G', 'A', 'T', 'O'],
  },
];


class SyllablesGameScreen extends StatefulWidget {
  final List<Map<String, dynamic>> words;
  final bool hard;

  const SyllablesGameScreen({
    super.key,
    required this.words,
    required this.hard,
  });

  @override
  State<SyllablesGameScreen> createState() => _SyllablesGameScreenState();
}

class _SyllablesGameScreenState extends State<SyllablesGameScreen> {
  final FlutterTts _tts = FlutterTts();

  int _index = 0;
  List<String> _selected = [];
  bool _completed = false;
  bool _errorFlash = false;

  @override
  void initState() {
    super.initState();

    //  Cuando el TTS termina de hablar
    _tts.setCompletionHandler(() {
      if (_completed) {
        // Cierra diálogo si está abierto
        if (Navigator.canPop(context)) {
          Navigator.pop(context); 
        }

        // vuelve a la pantalla anterior (escenarios o dificultad)
        Navigator.pop(context);
      }
    });
  }


  Future<void> _speak(String text) async {
    await _tts.setLanguage("es-ES");
    await _tts.setSpeechRate(0.55);
    await _tts.setPitch(1.2);
    await _tts.speak(text);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  void _select(String s) {
    final correct = List<String>.from(widget.words[_index]['correct']);

    if (_selected.length >= correct.length) return;

    _speak(s); // lee sílaba/letra

    setState(() => _selected.add(s));

    if (_selected.length == correct.length) {
      final word = correct.join();

      Future.delayed(const Duration(milliseconds: 300), () async {
        await _speak(word);
        _checkAnswer(correct);
      });
    }
  }

  void _removeFromSlot(int i) {
    if (i < _selected.length) {
      setState(() => _selected.removeAt(i));
    }
  }

  void _checkAnswer(List<String> correct) async {
    final word = widget.words[_index]['word'];

    if (_selected.join() == correct.join()) {
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("¡Muy bien! "),
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
      });
    } else {
      setState(() => _completed = true);

      // El TTS se encarga de cerrar y devolver
      _speak("¡Felicitaciones! Completaste todas las palabras.");
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_completed) {
      return Scaffold(
        backgroundColor: Colors.blue.shade50,
        body: const Center(
          child: Text(
            "¡Completaste todas las palabras!",
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

      // EVITA EL OVERFLOW CUANDO SALE EL TECLADO O BOTONES
      resizeToAvoidBottomInset: true,

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Center(   //  CENTRA TODO EL CONTENIDO
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 500,   // evita que se pegue a la izquierda
            ),

            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      Text(
                        "Palabra ${_index + 1} de ${widget.words.length}",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 20),

                      if (activity['image'] != null)
                        SizedBox(
                          height: 150,
                          child: Image.asset(
                            activity['image'],
                            fit: BoxFit.contain,
                          ),
                        ),

                      const SizedBox(height: 20),

                      if (!widget.hard)
                        Text(
                          activity['word'],
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                          ),
                          textAlign: TextAlign.center,
                        ),

                      const SizedBox(height: 25),

                      // CASILLEROS — AHORA CENTRADOS
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: List.generate(correct.length, (i) {
                          final text = i < _selected.length ? _selected[i] : "";

                          return GestureDetector(
                            onTap: () => _removeFromSlot(i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 80,
                              height: 60,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color:
                                    _errorFlash ? Colors.red.shade100 : Colors.white,
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

                      // BOTONES DE SÍLABAS — CENTRADOS
                      Wrap(
                        spacing: 14,
                        runSpacing: 14,
                        alignment: WrapAlignment.center,
                        children: syllables.map((s) {
                          return GestureDetector(
                            onTap: () => _select(s),
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
                                s,
                                style: const TextStyle(
                                  fontSize: 26,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 35),

                      ElevatedButton.icon(
                        icon: const Icon(Icons.volume_up, size: 28),
                        onPressed: () {
                          if (widget.hard) {
                            _speak("Forma la palabra");
                          } else {
                            _speak("Forma la palabra ${activity['word']}");
                          }
                        },
                        label: const Text(
                          "Escuchar indicación",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

          ),
        ),
      ),
    );
  }
}
