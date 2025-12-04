import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../models/student_model.dart';
import '../services/database_service.dart';

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

  const ActivityScreen({
    super.key,
    required this.storyId,
    this.student,
  });

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final AudioPlayer _storyPlayer = AudioPlayer();
  final AudioPlayer _quizPlayer = AudioPlayer();
  final PageController _pageController = PageController();

  static const Duration _coverLock = Duration(seconds: 6);

  late String _audioAssetPath;
  late String _storyTitle;
  late String _storyAuthor;
  late String _storyVersion;

  late List<List<String>> _pages;
  late List<List<List<String>>> _pageWords;
  late List<List<List<int>>> _timeRanges;

  late List<QuizQuestion> _quizzes;
  late List<int?> _userAnswers;
  late List<bool> _quizShown;

  int _currentPage = 0;
  int _currentParagraph = -1;
  int _currentWord = -1;

  bool _isPlayingStory = false;
  Duration _position = Duration.zero;

  bool _inQuiz = false;
  int _currentQuizIndex = -1;
  Duration _resumePositionAfterQuiz = Duration.zero;

  int get _totalStoryPages => _pages.length - 1; // sin contar portada

  @override
  void initState() {
    super.initState();
    _loadStory(widget.storyId);
    _initAudioListeners();
  }

  @override
  void dispose() {
    _storyPlayer.dispose();
    _quizPlayer.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // ======================= 1. CARGAR CUENTO SEGÚN storyId ===================
  void _loadStory(int id) {
    if (id == 1) {
      _loadTioTigre();
    } else if (id == 2) {
      _loadRatita();
    } else if (id == 3) {
      _loadPrincipeRana();
    } else {
      _loadTioTigre();
    }

    _pageWords = _pages
        .map((page) => page.map((p) => p.split(" ")).toList())
        .toList();

    _userAnswers = List<int?>.filled(_quizzes.length, null);
    _quizShown = List<bool>.filled(_quizzes.length, false);
  }

  // ---------------- CUENTO 1: TÍO TIGRE Y TÍO CONEJO ----------------
  void _loadTioTigre() {
    _storyTitle = "TÍO TIGRE Y TÍO CONEJO";
    _audioAssetPath = 'audio/Tio_tigre_tio_conejo.mp3';
    _storyAuthor = "Cuento tradicional de Venezuela";
    _storyVersion = "Versión de Paola Artmann";

    _pages = [
      [],
      [
        "Una calurosa mañana, se encontraba Tío Conejo recolectando zanahorias para el almuerzo.",
        "De repente, escuchó un rugido aterrador: ¡era Tío Tigre!",
        "—¡Ajá, Tío Conejo! —dijo el felino—.",
        "No tienes escapatoria, pronto te convertirás en un delicioso bocadillo.",
      ],
      [
        "En ese instante, Tío Conejo notó unas piedras muy grandes en lo alto de la colina e ideó un plan.",
        "—Puede que yo sea un delicioso bocadillo, pero estoy muy flaquito —dijo Tío Conejo—.",
        "Mira hacia la cima de la colina, ahí tengo mis vacas y te puedo traer una.",
        "¿Por qué conformarte con un pequeño bocadillo, cuando puedes darte un gran banquete?",
      ],
      [
        "Como Tío Tigre se encontraba de cara al sol, no podía ver con claridad y aceptó la propuesta.",
        "Entonces le permitió a Tío Conejo ir colina arriba mientras él esperaba abajo.",
        "Al llegar a la cima de la colina, Tío Conejo gritó:",
        "—Abre bien los brazos Tío Tigre, estoy arreando la vaca más gordita.",
      ],
      [
        "Entonces, Tío Conejo se acercó a la piedra más grande y la empujó con todas sus fuerzas.",
        "La piedra rodó rápidamente.",
        "Tío Tigre estaba tan emocionado que no vio la enorme piedra que lo aplastó, dejándolo adolorido por meses.",
        "Tío Conejo huyó saltando de alegría.",
      ],
    ];

    _timeRanges = [
      [
        [0, 6200],
      ],
      [
        [6200, 11900],
        [11900, 16900],
        [16900, 20700],
        [20700, 27900],
      ],
      [
        [27900, 33500],
        [33500, 39200],
        [39200, 43300],
        [43300, 50900],
      ],
      [
        [50900, 56000],
        [56000, 60900],
        [60900, 65200],
        [65200, 69200],
      ],
      [
        [69200, 73900],
        [73900, 75900],
        [75900, 83300],
        [83300, 87000],
      ],
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


  // ---------------- CUENTO 2: RATITA PRESUMIDA ----------------
  void _loadRatita() {
    _storyTitle = "LA RATITA PRESUMIDA";
    _audioAssetPath = 'audio/Ratita_presumida.mp3';
    _storyAuthor = "Cuento folclorico español";
    _storyVersion = "Versión de Paola Artmann";

    _pages = [
      [],
      [
        "Érase una vez una ratita que era muy presumida. "
            "Un día estaba barriendo su casita, cuando de repente encontró en el suelo algo que brillaba: era una moneda de oro. "
            "La ratita la recogió del suelo y dichosa se puso a pensar qué se compraría con la moneda. "
            "“Ya sé, me compraré caramelos. ¡Oh no!, se me caerán los dientes. "
            "Pues me compraré pasteles. ¡Oh no! me dolerá la barriguita. "
            "Ya sé, me compraré un lacito de color rojo para mi rabito.”",
      ],
      [
        "La ratita guardó la moneda en su bolsillo y se fue al mercado. "
            "Una vez en el mercado le pidió al tendero un trozo de su mejor cinta roja. "
            "La compró y volvió a su casita. "
            "Al día siguiente, la ratita se puso el lacito en la colita y salió al balcón de su casa para que todos pudieran admirarla. "
            "En eso que aparece un gallo y le dice: "
            "— Ratita, ratita tú que eres tan bonita, ¿te quieres casar conmigo?",
      ],
      [
        "Y la ratita le dijo: "
            "—No sé, no sé, ¿tú por las noches qué ruido haces? "
            "—Yo cacareo así: quiquiriquí —respondió el gallo. "
            "—¡Ay, no!, contigo no me casaré, me asusto, me asusto —replicó la ratita con un tono muy indiferente.",
      ],
      [
        "Se fue el gallo y apareció el perro: "
            "— Ratita, ratita tú que eres tan bonita, ¿te quieres casar conmigo? "
            "Y la ratita le dijo: "
            "—No sé, no sé, ¿tú por las noches qué ruido haces?",
      ],
      [
        "—Yo ladro así: guau, guau — respondió el perro. "
            "—¡Ay, no!, contigo no me casaré, me asusto, me asusto —replicó la ratita sin ni siquiera mirarlo. "
            "Se fue el perro y apareció el cerdo. "
            "— Ratita, ratita tú que eres tan bonita, ¿te quieres casar conmigo?",
      ],
      [
        "Y la ratita le dijo: "
            "—No sé, no sé, ¿tú por las noches qué ruido haces? "
            "—Yo gruño así: oinc, oinc— respondió el cerdo. "
            "—¡Ay, no!, contigo no me casaré, me asusto, me asusto —replicó la ratita con mucho desagrado.",
      ],
      [
        "El cerdo desaparece por donde vino, llega un gato blanco y le dice a la ratita: "
            "— Ratita, ratita tú que eres tan bonita, ¿te quieres casar conmigo? "
            "Y la ratita le dijo: "
            "—No sé, no sé, ¿tú por las noches qué ruido haces?",
      ],
      [
        "—Yo maúllo así: miau, miau— respondió el gato con un maullido muy dulce. "
            "—¡Ay, sí!, contigo me casaré, tienes un maullido muy dulce. "
            "La ratita muy emocionada, se acercó al gato para darle un abrazo y él sin perder la oportunidad de hacerse a buen bocado, "
            "se abalanzó sobre ella y casi la atrapa de un solo zarpazo.",
      ],
      [
        "La ratita pegó un brinco y corrió lo más rápido que pudo. "
            "De no ser porque la ratita no solo era presumida sino también muy suertuda, esta hubiera sido una muy triste historia. "
            "Y colorín colorado, este cuento se ha acabado.",
      ],
    ];

    // tiempos genéricos (ajusta luego al audio real)
    // Tiempos reales por página (en ms) usando el audio de 3:11
    _timeRanges = [
      // Portada (solo bloqueo de 6s)
      [
        [0, 6000],
      ],

      // Página 1
      [
        [6000, 26587],
      ],

      // Página 2
      [
        [26587, 47175],
      ],

      // Página 3
      [
        [47175, 67762],
      ],

      // Página 4
      [
        [67762, 88349],
      ],

      // Página 5
      [
        [88349, 108937],
      ],

      // Página 6
      [
        [108937, 129524],
      ],

      // Página 7
      [
        [129524, 150111],
      ],

      // Página 8
      [
        [150111, 170699],
      ],

      // Página 9
      [
        [170699, 191286],
      ],
    ];


    _quizzes = [
      QuizQuestion(
        question: "¿Qué encontró la ratita en el suelo?",
        options: ["Una moneda de oro", "Un caramelo", "Un zapato"],
        correctIndex: 0,
        audioPath: "audio/quiz_ratita_p1.mp3",
      ),
      QuizQuestion(
        question: "¿Qué se compró la ratita con la moneda?",
        options: ["Caramelos", "Pasteles", "Un lacito rojo"],
        correctIndex: 2,
        audioPath: "audio/quiz_ratita_p2.mp3",
      ),
      QuizQuestion(
        question: "¿Quién fue el primer animal en pedirle matrimonio?",
        options: ["Perro", "Gallo", "Cerdo"],
        correctIndex: 1,
        audioPath: "audio/quiz_ratita_p3.mp3",
      ),
      QuizQuestion(
        question: "¿Qué ruido hacía el perro?",
        options: ["Miau, miau", "Guau, guau", "Oinc, oinc"],
        correctIndex: 1,
        audioPath: "audio/quiz_ratita_p4.mp3",
      ),
      QuizQuestion(
        question: "¿Qué animal hacía oinc, oinc?",
        options: ["El cerdo", "El gato", "El perro"],
        correctIndex: 0,
        audioPath: "audio/quiz_ratita_p5.mp3",
      ),
      QuizQuestion(
        question: "¿De qué color era el gato que llegó al final?",
        options: ["Negro", "Blanco", "Gris"],
        correctIndex: 1,
        audioPath: "audio/quiz_ratita_p6.mp3",
      ),
      QuizQuestion(
        question: "¿Por qué la ratita decidió casarse con el gato?",
        options: [
          "Porque era blanco",
          "Porque tenía mucho dinero",
          "Porque su maullido era muy dulce"
        ],
        correctIndex: 2,
        audioPath: "audio/quiz_ratita_p7.mp3",
      ),
      QuizQuestion(
        question: "¿Qué intentó hacer el gato con la ratita?",
        options: ["Abrazarla", "Comérsela", "Llevarla a pasear"],
        correctIndex: 1,
        audioPath: "audio/quiz_ratita_p8.mp3",
      ),
      QuizQuestion(
        question: "¿Qué ayudó a que la historia no fuera triste?",
        options: [
          "Que la ratita era muy suertuda",
          "Que el gato se durmió",
          "Que llegó el perro"
        ],
        correctIndex: 0,
        audioPath: "audio/quiz_ratita_p9.mp3",
      ),
    ];
  }

  // ---------------- CUENTO 3: PRÍNCIPE RANA ----------------
void _loadPrincipeRana() {
    _storyTitle = "EL PRÍNCIPE RANA";
    _audioAssetPath = 'audio/Príncipe_rana.mp3';
    _storyAuthor = "Cuento de los Hermanos Grimm";
    _storyVersion = "Versión de Paola Artmann";

  // (y todo tu cuento queda igual… no se toca nada más)


    _pages = [
      [],
      [
        "En una tierra muy lejana, una princesa disfrutaba de la brisa fresca de la tarde afuera del palacio de su familia. "
            "Ella llevaba consigo una pequeña bola dorada que era su posesión más preciada. "
            "Mientras jugaba, la arrojó tan alto que perdió vista de ella y la bola rodó hacia un estanque. "
            "La princesa comenzó a llorar desconsoladamente. Entonces, una pequeña rana salió del estanque saltando.",
      ],
      [
        "—¿Qué pasa bella princesa? —preguntó la rana. "
            "La princesa se enjugó las lágrimas y dijo: "
            "—Mi bola dorada favorita está perdida en el fondo del estanque, y nada me la devolverá. "
            "La rana intentó consolar a la princesa, y le aseguró que podía recuperar la bola dorada si ella le concedía un solo favor.",
      ],
      [
        "—¡Cualquier cosa! ¡Te daré todas mis joyas, puñados de oro y hasta mis vestidos! —exclamó la princesa. "
            "La rana le explicó que no tenía necesidad de riquezas, y que a cambio solo pedía que la princesa le permitiera comer de su plato y dormir en su habitación. "
            "La idea de compartir el plato y habitación con una rana desagradó muchísimo a la princesa, pero aceptó pensando que la rana jamás encontraría el camino al palacio. "
            "La rana se sumergió en el estanque y en un abrir y cerrar de ojos había recuperado la bola.",
      ],
      [
        "A la mañana siguiente, la princesa encontró a la rana esperándola en la puerta del palacio. "
            "—He venido a reclamar lo prometido —dijo la rana. "
            "Al escuchar esto, la princesa corrió hacia su padre, llorando. Cuando el amable rey se enteró de la promesa, dijo: "
            "—Una promesa es una promesa. Ahora, debes dejar que la rana se quede aquí.",
      ],
      [
        "La princesa estaba muy enojada, pero no tuvo otra opción que dejar quedar a la rana. "
            "Fue así como la rana comió de su plato y durmió en su almohada. "
            "Al final de la tercera noche, la princesa cansada de la presencia del huésped indeseable, se levantó de la cama y tiró la rana al piso. "
            "Entonces la rana le propuso un trato:",
      ],
      [
        "—Si me das un beso, desapareceré para siempre —dijo la rana. "
            "La princesa muy asqueada plantó un beso en la frente huesuda de la rana y exclamó: "
            "—He cumplido con mi parte, ahora márchate inmediatamente. "
            "De repente, una nube de humo blanco inundó la habitación.",
      ],
      [
        "Para sorpresa de la princesa, la rana era realmente un apuesto príncipe atrapado por la maldición de una bruja malvada. "
            "Su beso lo había liberado de una vida de soledad y tristeza. "
            "La princesa y el príncipe se hicieron amigos al instante, después de unos años se casaron y vivieron felices para siempre.",
      ],
    ];

    _timeRanges = [
      // Portada
      [
        [0, 6000],
      ],

      // Página 1
      [
        [6000, 30748],
      ],

      // Página 2
      [
        [27748, 51495],
      ],

      // Página 3
      [
        [51495, 85000],
      ],

      // Página 4
      [
        [74243, 96990],
      ],

      // Página 5
      [
        [96990, 119738],
      ],

      // Página 6
      [
        [119738, 142485],
      ],

      // Página 7
      [
        [142485, 165233],
      ],
    ];


    _quizzes = [
      QuizQuestion(
        question: "¿Qué objeto preciado tenía la princesa?",
        options: ["Un collar", "Una bola dorada", "Una corona"],
        correctIndex: 1,
        audioPath: "audio/quiz_rana_p1.mp3",
      ),
      QuizQuestion(
        question: "¿Dónde cayó la bola dorada de la princesa?",
        options: ["En un río", "En un pozo", "En un estanque"],
        correctIndex: 2,
        audioPath: "audio/quiz_rana_p2.mp3",
      ),
      QuizQuestion(
        question: "¿Qué quería la rana a cambio?",
        options: [
          "Joyas y oro",
          "Comer de su plato y dormir en su habitación",
          "Un castillo"
        ],
        correctIndex: 1,
        audioPath: "audio/quiz_rana_p3.mp3",
      ),
      QuizQuestion(
        question: "¿Qué dijo el rey al saber de la promesa?",
        options: [
          "Que la rompiera",
          "Que una promesa es una promesa",
          "Que se fuera del palacio"
        ],
        correctIndex: 1,
        audioPath: "audio/quiz_rana_p4.mp3",
      ),
      QuizQuestion(
        question: "¿Qué hizo la princesa la tercera noche?",
        options: [
          "Le cantó a la rana",
          "Tiró la rana al piso",
          "Se fue del palacio"
        ],
        correctIndex: 1,
        audioPath: "audio/quiz_rana_p5.mp3",
      ),
      QuizQuestion(
        question: "¿Qué debía hacer la princesa para que la rana desapareciera?",
        options: [
          "Darle comida",
          "Regalarle joyas",
          "Darle un beso"
        ],
        correctIndex: 2,
        audioPath: "audio/quiz_rana_p6.mp3",
      ),
      QuizQuestion(
        question: "¿Quién era en realidad la rana?",
        options: [
          "Un mago",
          "Un príncipe",
          "Un rey"
        ],
        correctIndex: 1,
        audioPath: "audio/quiz_rana_p7.mp3",
      ),
    ];
  }

  // ======================= 2. AUDIO LISTENERS ================================
  void _initAudioListeners() {
    _storyPlayer.onPositionChanged.listen((p) {
      if (_inQuiz) return;
      setState(() => _position = p);
      _syncAudioToText();
    });

    _storyPlayer.onPlayerComplete.listen((_) {
      if (!_quizShown[_quizzes.length - 1]) {
        _goToQuizForPage(_totalStoryPages);
      }
    });
  }

  // ======================= 3. SYNC AUDIO → TEXTO =============================
  void _syncAudioToText() {
    if (_inQuiz) return;
    final currentMs = _position.inMilliseconds;

    if (currentMs < _coverLock.inMilliseconds) {
      if (_currentPage != 0) {
        _currentPage = 0;
        _currentParagraph = -1;
        _currentWord = -1;
        _pageController.jumpToPage(0);
        setState(() {});
      }
      return;
    }

    int? page;
    int? paragraph;
    int? word;

    for (int pg = 1; pg < _timeRanges.length; pg++) {
      for (int pa = 0; pa < _timeRanges[pg].length; pa++) {
        final start = _timeRanges[pg][pa][0];
        final end = _timeRanges[pg][pa][1];

        if (currentMs >= start && currentMs < end) {
          page = pg;
          paragraph = pa;

          const delay = 120;
          final words = _pageWords[pg][pa];
          final totalWords = words.length;
          final range = (end - start).clamp(1, 999999);
          final local =
              (currentMs - start - delay).clamp(0, range - 1);
          final wordDuration = range / totalWords;

          word = (local / wordDuration)
              .floor()
              .clamp(0, totalWords - 1);
          break;
        }
      }
      if (page != null) break;
    }

    if (page == null) return;

    final prevPage = _currentPage;

    _currentPage = page;
    _currentParagraph = paragraph!;
    _currentWord = word!;
    _pageController.jumpToPage(page);
    setState(() {});

    if (prevPage >= 1 &&
        prevPage < _totalStoryPages &&
        page == prevPage + 1) {
      final quizIndex = prevPage - 1;
      if (quizIndex >= 0 &&
          quizIndex < _quizzes.length &&
          !_quizShown[quizIndex]) {
        _resumePositionAfterQuiz = _position;
        _goToQuizForPage(prevPage);
      }
    }
  }

  // ======================= 4. PLAY / PAUSE / RESTART ========================
  Future<void> _togglePlayPause() async {
    if (_inQuiz) return;

    if (_isPlayingStory) {
      await _storyPlayer.pause();
      setState(() => _isPlayingStory = false);
    } else {
      await _storyPlayer.play(AssetSource(_audioAssetPath));
      setState(() => _isPlayingStory = true);
    }
  }

  Future<void> _restart() async {
    await _storyPlayer.stop();
    await _quizPlayer.stop();

    setState(() {
      _isPlayingStory = false;
      _currentPage = 0;
      _currentParagraph = -1;
      _currentWord = -1;
      _position = Duration.zero;
      _inQuiz = false;
      _currentQuizIndex = -1;
      _quizShown = List<bool>.filled(_quizzes.length, false);
      _userAnswers = List<int?>.filled(_quizzes.length, null);
    });

    _pageController.jumpToPage(0);
  }

  // ======================= 5. QUIZZES =======================================
  void _goToQuizForPage(int pageNumber) async {
    final quizIndex = pageNumber - 1;
    if (quizIndex < 0 || quizIndex >= _quizzes.length) return;
    if (_quizShown[quizIndex]) return;

    await _storyPlayer.pause();
    setState(() {
      _inQuiz = true;
      _currentQuizIndex = quizIndex;
      _quizShown[quizIndex] = true;
      _isPlayingStory = false;
    });
  }

  Future<void> _playQuizAudio() async {
    final q = _quizzes[_currentQuizIndex];
    await _quizPlayer.stop();
    await _quizPlayer.play(AssetSource(q.audioPath));
  }

  void _onSelectQuizOption(int index) async {
    _userAnswers[_currentQuizIndex] = index;
    final isLast = _currentQuizIndex == _quizzes.length - 1;

    if (isLast) {
      await _showSummary();
      return;
    }

    setState(() => _inQuiz = false);
    await _quizPlayer.stop();
    await _storyPlayer.seek(_resumePositionAfterQuiz);
    await _storyPlayer.resume();
    setState(() => _isPlayingStory = true);
  }

  Future<void> _showSummary() async {
    await _quizPlayer.stop();
    await _storyPlayer.stop();

    int correct = 0;
    for (int i = 0; i < _quizzes.length; i++) {
      final ua = _userAnswers[i];
      if (ua != null && ua == _quizzes[i].correctIndex) correct++;
    }

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

    setState(() {
      _inQuiz = false;
      _currentQuizIndex = -1;
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "🎉 ¡Muy bien!",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "Terminaste el cuento.\n\n"
                "🏆 Obtuviste $correct / ${_quizzes.length} correctas",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
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
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text("Tu respuesta: ${ua == null ? "—" : q.options[ua]}"),
                      Text("Correcta: ${q.options[q.correctIndex]}"),
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
              child: const Text("Volver a los cuentos"),
            ),
          ),
        ],
      ),
    );
  }

  // ======================= 6. UI GENERAL ====================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: Text(_storyTitle),
        backgroundColor: Colors.lightBlueAccent,
        foregroundColor: Colors.white,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _inQuiz ? _buildQuizScreen() : _buildStoryScreen(),
      ),
    );
  }

  // ---------------- UI CUENTO ----------------
  Widget _buildStoryScreen() {
    return Column(
      key: const ValueKey('story'),
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _pages.length,
              itemBuilder: (_, page) {
                if (page == 0) return _buildCover();
                return _buildStoryPage(page);
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _togglePlayPause,
              icon: Icon(
                  _isPlayingStory ? Icons.pause : Icons.play_arrow),
              label: Text(_isPlayingStory ? "Pausar" : "Leer"),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: _restart,
              icon: const Icon(Icons.restart_alt),
              label: const Text("Reiniciar"),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCover() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _storyTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 20),

          Text(
            _storyAuthor,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.black54,
            ),
          ),

          SizedBox(height: 6),

          Text(
            _storyVersion,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildStoryPage(int pageIndex) {
    final paragraphs = _pages[pageIndex];
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(paragraphs.length, (i) {
          return Container(
            margin: const EdgeInsets.only(bottom: 18),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: _buildParagraphText(pageIndex, i),
          );
        }),
      ),
    );
  }

  Widget _buildParagraphText(int pageIndex, int paragraphIndex) {
    final words = _pageWords[pageIndex][paragraphIndex];
    final active = pageIndex == _currentPage &&
        paragraphIndex == _currentParagraph;

    return Wrap(
      alignment: WrapAlignment.start,
      runSpacing: 4,
      children: List.generate(words.length, (i) {
        final highlight = active && i == _currentWord;
        return Text(
          '${words[i]} ',
          style: TextStyle(
            fontSize: 22,
            fontWeight:
                highlight ? FontWeight.bold : FontWeight.normal,
            backgroundColor:
                highlight ? Colors.yellow[300] : Colors.transparent,
          ),
        );
      }),
    );
  }

  // ---------------- UI QUIZ ----------------
Widget _buildQuizScreen() {
  final q = _quizzes[_currentQuizIndex];
  final selected = _userAnswers[_currentQuizIndex];

  return SafeArea(
    key: const ValueKey('quiz'),
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 14,
                  offset: Offset(0, 5),
                ),
              ],
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Pregunta de la página ${_currentQuizIndex + 1}",
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  q.question,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                IconButton(
                  onPressed: _playQuizAudio,
                  icon: const Icon(Icons.volume_up, size: 40),
                ),

                const SizedBox(height: 20),

                Column(
                  children: List.generate(q.options.length, (i) {
                    final isSel = selected == i;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor:
                              isSel ? Colors.orangeAccent : Colors.lightBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => _onSelectQuizOption(i),
                        child: Text(
                          q.options[i],
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}