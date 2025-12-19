import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '/repositories/progress_repository.dart';
import '/models/progress_model.dart';
import '/models/student_model.dart';
import '/models/activity_model.dart';

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String audioPath;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.audioPath,
  });
}

class ActivityScreen extends StatefulWidget {
  final int storyId;
  final Student? student;
  final Activity activity;

  const ActivityScreen({
    super.key,
    required this.storyId,
    required this.activity,
    this.student,
  });

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  
  final AudioPlayer _storyPlayer = AudioPlayer();
  final AudioPlayer _quizPlayer = AudioPlayer();
  final FlutterTts _tts = FlutterTts();
  final PageController _pageController = PageController();

  // =================== STORY DATA ===================
  late String _storyTitle;
  late String _storyAuthor;
  late String _storyVersion;
  late String _coverAudio;

  late List<List<String>> _pages;
  late List<String> _pageAudios;

  late List<List<List<String>>> _pageWords; // page -> paragraph -> words

  late List<QuizQuestion> _quizzes;
  late List<int?> _userAnswers;
  late List<bool> _quizShown;

  // =================== STATE ===================
  int _currentPage = 0;
  int _currentParagraph = -1;
  int _currentWord = -1;

  bool _isPlayingStory = false;
  bool _inQuiz = false;
  int _currentQuizIndex = -1;

  int get _visiblePage {
  if (_pageController.hasClients && _pageController.page != null) {
    return _pageController.page!.round();
  }
  return _currentPage;
}


  // evitar doble click en quiz (y dialogs en cadena)
  bool _quizLock = false;

  // =================== LIFECYCLE ===================
  @override
  void initState() {
    super.initState();
    _loadStory(widget.storyId);

    _pageWords = _pages
        .map((page) => page
            .map((p) => p
                .trim()
                .split(RegExp(r'\s+'))
                .where((w) => w.isNotEmpty)
                .toList())
            .toList())
        .toList();

    _userAnswers = List<int?>.filled(_quizzes.length, null);
    _quizShown = List<bool>.filled(_quizzes.length, false);

    _initTts();
  }

  void _initTts() async {
    await _tts.setLanguage('es-ES');
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
  }

  @override
  void dispose() {
    _storyPlayer.dispose();
    _quizPlayer.dispose();
    _tts.stop();
    _pageController.dispose();
    super.dispose();
  }

  // =================== LOAD STORY ===================
  void _loadStory(int id) {
    switch (id) {
      case 1:
        _loadTioTigre();
        break;
      case 2:
        _loadRatita();
        break;
      case 3:
        _loadPrincipeRana();
        break;
      default:
        _loadTioTigre();
    }
  }

  // =================== STORY 1 ===================
  void _loadTioTigre() {
    _storyTitle = "TÍO TIGRE Y TÍO CONEJO";
    _storyAuthor = "Cuento tradicional de Venezuela";
    _storyVersion = "Versión de Paola Artmann";
    _coverAudio = 'audio/Tio_tigre_titulo.mp3';

    _pages = [
      [],
      [
        "Una calurosa mañana, se encontraba Tío Conejo recolectando zanahorias para el almuerzo.",
        "De repente, escuchó un rugido aterrador: ¡era Tío Tigre!",
        "¡Ajá, Tío Conejo! dijo el felino.",
        "No tienes escapatoria, pronto te convertirás en un delicioso bocadillo.",
      ],
      [
        "En ese instante, Tío Conejo notó unas piedras muy grandes en lo alto de la colina e ideó un plan.",
        "Puede que yo sea un delicioso bocadillo, pero estoy muy flaquito dijo Tío Conejo.",
        "Mira hacia la cima de la colina, ahí tengo mis vacas y te puedo traer una.",
        "¿Por qué conformarte con un pequeño bocadillo, cuando puedes darte un gran banquete?",
      ],
      [
        "Como Tío Tigre se encontraba de cara al sol, no podía ver con claridad y aceptó la propuesta.",
        "Entonces le permitió a Tío Conejo ir colina arriba mientras él esperaba abajo.",
        "Al llegar a la cima de la colina, Tío Conejo gritó:",
        "Abre bien los brazos Tío Tigre, estoy arreando la vaca más gordita.",
      ],
      [
        "Entonces, Tío Conejo se acercó a la piedra más grande y la empujó con todas sus fuerzas.",
        "La piedra rodó rápidamente.",
        "Tío Tigre estaba tan emocionado que no vio la enorme piedra que lo aplastó, dejándolo adolorido por meses.",
        "Tío Conejo huyó saltando de alegría.",
      ],
    ];

    _pageAudios = [
      '',
      'audio/tio_tigre_p1.mp3',
      'audio/tio_tigre_p2.mp3',
      'audio/tio_tigre_p3.mp3',
      'audio/tio_tigre_p4.mp3',
    ];

    _quizzes = [
      QuizQuestion(
        question: "¿Qué estaba recolectando Tío Conejo?",
        options: ["Zanahorias", "Manzanas", "Piedras"],
        correctIndex: 0,
        audioPath: "audio/quiz_tigre_p1.mp3",
      ),
      QuizQuestion(
        question: "¿Qué vio Tío Conejo en la colina?",
        options: ["Un arcoíris", "Piedras grandes", "Un lago"],
        correctIndex: 1,
        audioPath: "audio/quiz_tigre_p2.mp3",
      ),
      QuizQuestion(
        question: "¿Por qué Tío Tigre no veía bien?",
        options: [
          "Porque estaba de cara al sol",
          "Porque estaba triste",
          "Porque no tenía lentes"
        ],
        correctIndex: 0,
        audioPath: "audio/quiz_tigre_p3.mp3",
      ),
      QuizQuestion(
        question: "¿Qué empujó Tío Conejo colina abajo?",
        options: ["Un árbol", "Una piedra grande", "Un carro"],
        correctIndex: 1,
        audioPath: "audio/quiz_tigre_p4.mp3",
      ),
    ];
  }

  // =================== STORY 2 ===================
  void _loadRatita() {
    _storyTitle = "LA RATITA PRESUMIDA";
    _storyAuthor = "Cuento folclórico español";
    _storyVersion = "Versión de Paola Artmann";
    _coverAudio = 'audio/ratita_cover.mp3';

    _pages = [
      [],
      ["Érase una vez una ratita muy presumida que encontró una moneda de oro."],
      ["Fue al mercado y compró un lacito rojo."],
      ["El gallo quiso casarse con ella, pero la asustó."],
      ["Luego apareció el perro."],
      ["Después llegó el cerdo."],
      ["Más tarde apareció un gato blanco."],
      ["El gato intentó atraparla."],
      ["La ratita escapó y el cuento terminó felizmente."],
    ];

    _pageAudios = [
      '',
      'audio/ratita_p1.mp3',
      'audio/ratita_p2.mp3',
      'audio/ratita_p3.mp3',
      'audio/ratita_p4.mp3',
      'audio/ratita_p5.mp3',
      'audio/ratita_p6.mp3',
      'audio/ratita_p7.mp3',
      'audio/ratita_p8.mp3',
    ];

    _quizzes = [
      QuizQuestion(
        question: "¿Qué encontró la ratita?",
        options: ["Una moneda", "Un zapato", "Un caramelo"],
        correctIndex: 0,
        audioPath: "audio/quiz_ratita_p1.mp3",
      ),
    ];
  }

  // =================== STORY 3 ===================
  void _loadPrincipeRana() {
    _storyTitle = "EL PRÍNCIPE RANA";
    _storyAuthor = "Hermanos Grimm";
    _storyVersion = "Versión de Paola Artmann";
    _coverAudio = 'audio/rana_cover.mp3';

    _pages = [
      [],
      ["Una princesa perdió su bola dorada en un estanque."],
      ["Una rana prometió ayudarla."],
      ["La rana pidió un favor."],
      ["El rey obligó a cumplir la promesa."],
      ["La princesa tiró la rana."],
      ["La rana pidió un beso."],
      ["La rana se convirtió en príncipe."],
    ];

    _pageAudios = [
      '',
      'audio/rana_p1.mp3',
      'audio/rana_p2.mp3',
      'audio/rana_p3.mp3',
      'audio/rana_p4.mp3',
      'audio/rana_p5.mp3',
      'audio/rana_p6.mp3',
      'audio/rana_p7.mp3',
    ];

    _quizzes = [
      QuizQuestion(
        question: "¿Qué perdió la princesa?",
        options: ["Una corona", "Una bola dorada", "Un anillo"],
        correctIndex: 1,
        audioPath: "audio/quiz_rana_p1.mp3",
      ),
    ];
  }

  // =================== PLAY LOGIC ===================
  Future<void> _playCurrentPage() async {
    if (_currentPage == 0) return;

    final audio = _pageAudios[_currentPage];
    final wordsByParagraph = _pageWords[_currentPage];

    // total words
    int totalWords = 0;
    for (final p in wordsByParagraph) {
      totalWords += p.length;
    }
    if (totalWords == 0) return;

    await _storyPlayer.stop();
    await _storyPlayer.play(AssetSource(audio));

    setState(() {
      _isPlayingStory = true;
      _currentParagraph = 0;
      _currentWord = -1;
    });

    final duration = await _storyPlayer.getDuration();
    if (duration == null) return;

    final wordMs = (duration.inMilliseconds ~/ totalWords).clamp(60, 700);

    int pIndex = 0;
    int wIndex = 0;

    while (_isPlayingStory && pIndex < wordsByParagraph.length) {
      // si el párrafo está vacío
      if (wordsByParagraph[pIndex].isEmpty) {
        pIndex++;
        wIndex = 0;
        continue;
      }

      setState(() {
        _currentParagraph = pIndex;
        _currentWord = wIndex;
      });

      await Future.delayed(Duration(milliseconds: wordMs));

      wIndex++;
      if (wIndex >= wordsByParagraph[pIndex].length) {
        wIndex = 0;
        pIndex++;
      }
    }

    // al terminar: quiz de la página (si corresponde)
    final quizIndex = _currentPage - 1;
    if (quizIndex >= 0 &&
        quizIndex < _quizzes.length &&
        !_quizShown[quizIndex]) {
      _goToQuizForPage(_currentPage);
    }
  }

  Future<void> _togglePlayPause() async {
    if (_inQuiz) return;

    final pageNow = _visiblePage;

    // PORTADA (según lo que se ve realmente)
    if (pageNow == 0 && !_isPlayingStory) {
      setState(() => _isPlayingStory = true);

      await _storyPlayer.stop();
      await _storyPlayer.play(AssetSource(_coverAudio));
      await _storyPlayer.onPlayerComplete.first;

      if (!mounted) return;

      // después del audio de portada pasamos a la página 1 y leemos
      _pageController.jumpToPage(1);
      setState(() {
        _currentPage = 1;
        _isPlayingStory = false;
        _currentParagraph = 0;
        _currentWord = -1;
      });

      await _playCurrentPage();
      return;
    }

    // si NO estamos en portada, aseguro que el estado siga a lo visible
    if (_currentPage != pageNow) {
      setState(() {
        _currentPage = pageNow;
        _currentParagraph = -1;
        _currentWord = -1;
      });
    }

    if (_isPlayingStory) {
      await _storyPlayer.pause();
      setState(() => _isPlayingStory = false);
    } else {
      await _playCurrentPage();
    }
  }


  // =================== QUIZ ===================
  void _goToQuizForPage(int page) async {
    await _storyPlayer.pause();
    setState(() {
      _inQuiz = true;
      _currentQuizIndex = page - 1;
      _quizShown[_currentQuizIndex] = true;
      _isPlayingStory = false;
      _quizLock = false;
    });
  }

  Future<void> _playQuizAudio() async {
    await _quizPlayer.stop();
    await _quizPlayer.play(
      AssetSource(_quizzes[_currentQuizIndex].audioPath),
    );
  }

  Future<void> _speak(String text) async {
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  Future<void> _showFeedbackDialog({
    required bool correct,
  }) async {
    final title = correct ? "🎉 ¡Correcto!" : " Inténtalo otra vez";
    final msg = correct ? "¡Muy bien seleccionaste la respuesta correcta!" : "Ups, me parece que esa no es la respuesta correcta.";
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(title, style: const TextStyle(fontSize: 26)),
        content: Text(msg, style: const TextStyle(fontSize: 20)),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(correct ? "Continuar" : "Reintentar",
                  style: const TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  void _onSelectQuizOption(int index) async {
    if (_quizLock) return;
    _quizLock = true;

    final quiz = _quizzes[_currentQuizIndex];
    _userAnswers[_currentQuizIndex] = index;

    // ================= INCORRECTO =================
    if (index != quiz.correctIndex) {
      setState(() {}); // pinta rojo

      await _speak("Ups, me parece que esa no es la opcion correcta, Intentalo otra vez");
      await _showFeedbackDialog(correct: false);

      _quizLock = false;
      return;
    }

    // ================= CORRECTO =================
    setState(() {}); // pinta verde

    await _speak("¡Muy bien! Has seleccionado la respuesta correcta");
    await _showFeedbackDialog(correct: true);

    final bool isLastQuiz =
        _currentQuizIndex == _quizzes.length - 1;

    // ================= ÚLTIMO QUIZ =================
    if (isLastQuiz) {
      _quizLock = false;
      await _showSummary();
      return;
    }

    // ================= VOLVER AL CUENTO (FIX REAL) =================
    final int storyPage = _currentQuizIndex + 2;

    // 1️⃣ salir del quiz (esto reconstruye el PageView)
    setState(() {
      _inQuiz = false;
      _quizLock = false;
      _isPlayingStory = false;
      _currentParagraph = -1;
      _currentWord = -1;
    });

    // 2️⃣ esperar a que el PageView EXISTA y recién moverlo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _pageController.jumpToPage(storyPage);

      // sincronizar estado lógico
      setState(() {
        _currentPage = storyPage;
      });
    });
  }



  Future<void> _showSummary() async {
    if (widget.student != null) {
      await ProgressRepository().saveOrUpdate(
        Progress(
          studentId: widget.student!.id!,
          activityId: widget.activity.id!,
          status: ProgressStatus.completed,
          attempts: 1,
          score: 100,
        ),
      );
    }

    // Resumen detallado (como el que tenías antes)
    int correct = 0;
    for (int i = 0; i < _quizzes.length; i++) {
      if (_userAnswers[i] == _quizzes[i].correctIndex) correct++;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "🎉 ¡Muy bien!",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "Terminaste el cuento.\n\n"
                "🏆 Obtuviste $correct / ${_quizzes.length} correctas",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 16),
              ...List.generate(_quizzes.length, (i) {
                final q = _quizzes[i];
                final ua = _userAnswers[i];
                final ok = ua == q.correctIndex;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ok ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Pregunta ${i + 1}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Tu respuesta: ${ua == null ? "—" : q.options[ua]}",
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        "Correcta: ${q.options[q.correctIndex]}",
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // cierra dialog
                Navigator.pop(context); // vuelve a cards
              },
              child: const Text("Volver a los cuentos", style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  // =================== UI ===================
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // tamaños responsivos (evita overflow en horizontal)
    final titleSize = (size.width * 0.075).clamp(28.0, 44.0);
    final storyWordSize = (size.width * 0.055).clamp(24.0, 36.0);
    final quizQuestionSize = (size.width * 0.060).clamp(24.0, 38.0);
    final quizOptionSize = (size.width * 0.055).clamp(22.0, 34.0);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _storyTitle,
          style: TextStyle(fontSize: (size.width * 0.05).clamp(18.0, 26.0)),
        ),
      ),
      body: SafeArea(
        child: _inQuiz
            ? _buildQuiz(quizQuestionSize, quizOptionSize)
            : _buildStory(titleSize, storyWordSize),
      ),
    );
  }

  Widget _buildStory(double titleSize, double wordSize) {
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
              ],
            ),
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) {
                _storyPlayer.stop();
                setState(() {
                  _currentPage = i;
                  _currentParagraph = -1;
                  _currentWord = -1;
                });
              },
              itemCount: _pages.length,
              itemBuilder: (_, i) => i == 0 ? _buildCover(titleSize) : _buildPage(i, wordSize),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _togglePlayPause,
              icon: Icon(_isPlayingStory ? Icons.pause : Icons.play_arrow),
              label: Text(
                _isPlayingStory ? "Pausar" : "Leer",
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildCover(double titleSize) => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _storyTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(_storyAuthor, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 6),
                Text(_storyVersion, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20)),
              ],
            ),
          ),
        ),
      );

  // ✅ palabra por palabra
  Widget _buildPage(int pageIndex, double wordSize) {
    final paragraphs = _pageWords[pageIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 750),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(paragraphs.length, (p) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Wrap(
                spacing: 6,
                runSpacing: 10,
                children: List.generate(paragraphs[p].length, (w) {
                  final highlight = pageIndex == _currentPage &&
                      p == _currentParagraph &&
                      w == _currentWord;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: highlight ? Colors.yellow[300] : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      paragraphs[p][w],
                      style: TextStyle(
                        fontSize: wordSize,
                        height: 1.25,
                        fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildQuiz(double qSize, double optSize) {
    final q = _quizzes[_currentQuizIndex];
    final selected = _userAnswers[_currentQuizIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 4)),
              ],
            ),
            child: Column(
              children: [
                Text(
                  "Pregunta ${_currentQuizIndex + 1}",
                  style: const TextStyle(fontSize: 18, color: Colors.black54),
                ),
                const SizedBox(height: 10),
                Text(
                  q.question,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: qSize, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                IconButton(
                  onPressed: _playQuizAudio,
                  icon: const Icon(Icons.volume_up, size: 40),
                ),
                const SizedBox(height: 10),
                ...List.generate(q.options.length, (i) {
                  final isWrong = selected != null && selected == i && i != q.correctIndex;
                  final isCorrect = selected == i && i == q.correctIndex;

                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: isCorrect
                            ? Colors.green
                            : isWrong
                                ? Colors.red
                                : Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => _onSelectQuizOption(i),
                      child: Text(
                        q.options[i],
                        style: TextStyle(fontSize: optSize, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
