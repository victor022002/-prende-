import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '/models/student_model.dart';
import '/models/progress_model.dart';
import '/repositories/progress_repository.dart';
import '/services/achievement_service.dart'; 
import '/widgets/achievement_overlay.dart';

class ActivityFillSentenceScreen extends StatefulWidget {
  final Student student;

  const ActivityFillSentenceScreen({
    super.key,
    required this.student,
  });

  @override
  State<ActivityFillSentenceScreen> createState() =>
      _ActivityFillSentenceScreenState();
}

class _ActivityFillSentenceScreenState
    extends State<ActivityFillSentenceScreen> {
  final FlutterTts _tts = FlutterTts();

  // 📖 Lectura → ids < 100
  static const int activityId = 2;

  final List<Map<String, dynamic>> _activities = [
    {
      'sentence': 'El niño está jugando con una ',
      'spoken': 'El niño está jugando con una pelota',
      'image': 'assets/imagenes/niño_pelota.jpg',
      'options': ['pelota', 'paleta', 'zapatos'],
      'answer': 'pelota',
    },
    {
      'sentence': 'La niña se está comiendo una ',
      'spoken': 'La niña se está comiendo una manzana',
      'image': 'assets/imagenes/niña_manzana.jpg',
      'options': ['pelota', 'manzana', 'camisa'],
      'answer': 'manzana',
    },
  ];

  int _currentIndex = 0;
  String? _selectedOption;
  bool _completed = false;

@override
void initState() {
  super.initState();
  _delayedIntro();

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

  Future<void> _delayedIntro() async {
    await Future.delayed(const Duration(seconds: 1));
    await _tts.stop();
    await _speak(
      "Escucha y completa la oración, con la palabra que falta.",
    );
  }

  Future<void> _speak(String text) async {
    await _tts.stop();
    await _tts.setLanguage("es-ES");
    await _tts.setSpeechRate(0.55);
    await _tts.setPitch(1.1);
    await _tts.speak(text);
  }

  void _speakSentence() async {
    await _tts.stop();
    _speak(_activities[_currentIndex]['spoken']);
  }

  Future<void> _checkAnswer(String option) async {
    final current = _activities[_currentIndex];
    setState(() => _selectedOption = option);

    if (option == current['answer']) {
      await _tts.stop();
      _speak(option);

      Future.delayed(const Duration(seconds: 1), () async {
        await _tts.stop();
        await _speak("¡Muy bien! Completaste correctamente la oración.");
        _showDialog();
      });
    } else {
      await _tts.stop();
      await _speak(
        "Ups. Elegiste $option. Inténtalo de nuevo.",
      );

      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _selectedOption = null);
      });
    }
  }

  void _showDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text("¡Correcto! 🎉"),
        content:
            const Text("Completaste correctamente la oración."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _nextActivity();
            },
            child: const Text("Continuar"),
          ),
        ],
      ),
    );
  }

  Future<void> _nextActivity() async {
    await _tts.stop();

    if (_currentIndex < _activities.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
      });
    } else {
      await _finishActivity();
    }
  }

  Future<void> _finishActivity() async {
    setState(() => _completed = true);

    final repo = ProgressRepository();

    print(
      "💾 Guardando progreso oraciones | "
      "student=${widget.student.id}, "
      "activityId=$activityId",
    );

    await repo.saveOrUpdate(
      Progress(
        studentId: widget.student.id!,
        activityId: activityId,
        status: ProgressStatus.completed,
        attempts: 1,
        score: 100,
      ),
    );

    // 🔊 MENSAJE FINAL DEL JUEGO (PRIORIDAD)
    await _speak(
      "¡Felicitaciones! Completaste todas las oraciones.",
    );

    // 🏆 LOGROS (DESPUÉS DEL MENSAJE FINAL)
    final achievement =
        await AchievementService.checkNew(widget.student.id!);

    if (achievement != null && mounted) {
      AchievementOverlay.show(context, achievement);

      await _speak(
        "Has desbloqueado el logro ${achievement.title}",
      );
    }
  }


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

    final current = _activities[_currentIndex];

    return WillPopScope(
      onWillPop: () async {
        await _tts.stop();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.blue.shade50,
        appBar: AppBar(
          title: const Text("Completa la oración"),
          backgroundColor: Colors.lightBlueAccent,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                      "Completa la oración",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (current['image'] != null)
                      SizedBox(
                        height: 180,
                        child: Image.asset(
                          current['image'],
                          fit: BoxFit.contain,
                        ),
                      ),

                    const SizedBox(height: 20),

                    Text(
                      current['sentence']
                          .replaceAll('___', '')
                          .trim(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 220,
                      height: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _selectedOption == null
                              ? Colors.black26
                              : Colors.green,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        _selectedOption ?? "___",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16,
                      runSpacing: 16,
                      children: current['options']
                          .map<Widget>((option) {
                        final used = _selectedOption == option;

                        return AnimatedOpacity(
                          opacity: used ? 0.4 : 1.0,
                          duration:
                              const Duration(milliseconds: 200),
                          child: ChoiceChip(
                            label: Text(
                              option,
                              style: const TextStyle(fontSize: 20),
                            ),
                            selected: used,
                            onSelected: used
                                ? null
                                : (_) => _checkAnswer(option),
                            selectedColor:
                                Colors.greenAccent,
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 40),

                    ElevatedButton.icon(
                      icon: const Icon(Icons.volume_up),
                      onPressed: _speakSentence,
                      label:
                          const Text("Escuchar oración"),
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
      ),
    );
  }
}
