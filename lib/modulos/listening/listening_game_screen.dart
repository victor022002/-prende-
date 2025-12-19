import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '/models/student_model.dart';
import '/models/progress_model.dart';
import '/repositories/progress_repository.dart';
import '/services/achievement_service.dart'; 
import '/widgets/achievement_overlay.dart';

class ListeningGameScreen extends StatefulWidget {
  final List<Map<String, dynamic>> activities;
  final Student student;

  const ListeningGameScreen({
    super.key,
    required this.activities,
    required this.student,
  });

  @override
  State<ListeningGameScreen> createState() => _ListeningGameScreenState();
}

class _ListeningGameScreenState extends State<ListeningGameScreen> {
  final AudioPlayer _player = AudioPlayer();
  final FlutterTts _tts = FlutterTts();

  int _index = 0;
  bool _completed = false;
  bool _blocked = false;

  // =====================
  // 🔊 TTS
  // =====================
  Future<void> _speak(String text) async {
    await _tts.setLanguage("es-ES");
    await _tts.setSpeechRate(0.55);
    await _tts.setPitch(1.2);
    await _tts.speak(text);
  }

  @override
  void initState() {
    super.initState();

    // 🔊 Instrucción inicial (1 segundo después)
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _speak(
          "Toca el botón de escuchar la palabra y elige la opción correcta",
        );
      }
    });

    // 🔊 Cuando termina el TTS final → volver atrás
    _tts.setCompletionHandler(() {
      if (_completed && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    _tts.stop();
    super.dispose();
  }

  // =====================
  // 🔊 AUDIO
  // =====================
  Future<void> _playAudio() async {
    final audio = widget.activities[_index]['audio'];
    await _player.stop();
    await _player.play(AssetSource(audio));
  }

  // =====================
  // 🎯 SELECCIÓN
  // =====================
  void _selectOption(String optionId) {
    if (_blocked) return;

    final activity = widget.activities[_index];
    final correct = activity['correct'];

    if (optionId == correct) {
      _blocked = true;
      _speak("¡Muy bien! Has seleccionado la palabra correcta");
      _showSuccessDialog();
    } else {
      _speak("Inténtalo otra vez");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Inténtalo otra vez")),
      );
    }
  }

  // =====================
  // 🟢 ÉXITO
  // =====================
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text("¡Muy bien!"),
        content: const Text("Elegiste la imagen correcta."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _next();
            },
            child: const Text("Continuar"),
          ),
        ],
      ),
    );
  }

  void _next() {
    if (_index < widget.activities.length - 1) {
      setState(() {
        _index++;
        _blocked = false;
      });
    } else {
      _finishGame();
    }
  }

  // =====================
  // 🏁 FINAL
  // =====================
  Future<void> _finishGame() async {
    setState(() => _completed = true);

    final repo = ProgressRepository();

    for (final a in widget.activities) {
      await repo.saveOrUpdate(
        Progress(
          studentId: widget.student.id!,
          activityId: a['id'],
          status: ProgressStatus.completed,
          attempts: 1,
          score: 100,
        ),
      );
    }

    // 🔊 MENSAJE FINAL DEL JUEGO (PRIORIDAD)
    await _speak(
      "¡Felicitaciones! Completaste todas las actividades de escucha",
    );

    // 🏆 LOGROS (VISUAL + VOZ DESPUÉS)
    final achievement =
        await AchievementService.checkNew(widget.student.id!);

    if (achievement != null && mounted) {
      AchievementOverlay.show(context, achievement);

      await _speak(
        "Has desbloqueado el logro ${achievement.title}",
      );
    }
  }



  // =====================
  // 🖼️ UI
  // =====================
  @override
  Widget build(BuildContext context) {
    if (_completed) {
      return Scaffold(
        backgroundColor: Colors.blue.shade50,
        body: const Center(
          child: Text(
            "¡Actividad completada!",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    final activity = widget.activities[_index];
    final options =
        List<Map<String, dynamic>>.from(activity['options']);

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text("Escucha y elige"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape =
                constraints.maxWidth > constraints.maxHeight;

            return Column(
              children: [
                /// 🔝 CONTENIDO SUPERIOR (SCROLLEABLE)
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: isLandscape ? 8 : 20,
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Actividad ${_index + 1} de ${widget.activities.length}",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: isLandscape ? 12 : 30),

                      /// 🔊 BOTÓN ESCUCHAR
                      ElevatedButton.icon(
                        icon: const Icon(Icons.volume_up),
                        label: const Text("Escuchar palabra"),
                        onPressed: _playAudio,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: isLandscape ? 12 : 16,
                          ),
                        ),
                      ),

                      SizedBox(height: isLandscape ? 16 : 30),
                    ],
                  ),
                ),

                /// 🖼️ OPCIONES (OCUPA EL RESTO)
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio:
                          isLandscape ? 1.4 : 1.0, // 🔑 CLAVE
                    ),
                    itemCount: options.length,
                    itemBuilder: (context, i) {
                      final opt = options[i];

                      return GestureDetector(
                        onTap: () => _selectOption(opt['id']),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Image.asset(
                              opt['image'],
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}