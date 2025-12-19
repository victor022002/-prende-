// word_lists.dart
import '/repositories/syllables_repository.dart';

bool _adminWordsLoaded = false;


/// =========================
/// LISTAS BASE (FIJAS)
/// =========================

// -------- CIUDAD --------
final List<Map<String, dynamic>> cityEasy = [
  {
    'word': 'CASA',
    'image': 'assets/imagenes/ordenar_casa.png',
    'syllables': ['CA', 'SA', 'LA', 'VA'],
    'correct': ['CA', 'SA'],
  },
];

final List<Map<String, dynamic>> cityHard = [
  {
    'word': 'CASA',
    'image': 'assets/imagenes/ordenar_casa.png',
    'syllables': ['A', 'S', 'C', 'A'],
    'correct': ['C', 'A', 'S', 'A'],
  },
];

// -------- NATURALEZA --------
final List<Map<String, dynamic>> natureEasy = [
  {
    'word': 'FLOR',
    'image': 'assets/imagenes/ordenar_flor.jpg',
    'syllables': ['FLO', 'R', 'LA', 'FO'],
    'correct': ['FLO', 'R'],
  },
];

final List<Map<String, dynamic>> natureHard = [
  {
    'word': 'FLOR',
    'image': 'assets/imagenes/ordenar_flor.jpg',
    'syllables': ['F', 'L', 'O', 'R'],
    'correct': ['F', 'L', 'O', 'R'],
  },
];

// -------- OBJETOS --------
final List<Map<String, dynamic>> objectsEasy = [
  {
    'word': 'MESA',
    'image': 'assets/imagenes/ordenar_mesa.jpg',
    'syllables': ['ME', 'SA', 'SO', 'PA'],
    'correct': ['ME', 'SA'],
  },
];

final List<Map<String, dynamic>> objectsHard = [
  {
    'word': 'MESA',
    'image': 'assets/imagenes/ordenar_mesa.jpg',
    'syllables': ['M', 'E', 'S', 'A'],
    'correct': ['M', 'E', 'S', 'A'],
  },
];


/// =========================
/// SELECTOR USADO POR EL JUEGO
/// =========================
List<Map<String, dynamic>> getWordList(String scenario, bool hard) {
  if (scenario == "city") return hard ? cityHard : cityEasy;
  if (scenario == "nature") return hard ? natureHard : natureEasy;
  if (scenario == "objects") return hard ? objectsHard : objectsEasy;
  return <Map<String, dynamic>>[];
}

/// =========================
/// AGREGA PALABRAS A LISTAS
/// =========================
void addWordToList({
  required String scenario,
  required bool hard,
  required Map<String, dynamic> wordData,
}) {
  if (scenario == "city") {
    hard ? cityHard.add(wordData) : cityEasy.add(wordData);
  } else if (scenario == "nature") {
    hard ? natureHard.add(wordData) : natureEasy.add(wordData);
  } else if (scenario == "objects") {
    hard ? objectsHard.add(wordData) : objectsEasy.add(wordData);
  }
}

/// =========================
/// CARGA PALABRAS DEL ADMIN
/// (SE EJECUTA UNA SOLA VEZ)
/// =========================
Future<void> loadAdminWordsIntoLists() async {
  if (_adminWordsLoaded) return; // 🔒 evita duplicados
  _adminWordsLoaded = true;

  final repo = SyllablesRepository();
  final all = await repo.getAll();

  for (final word in all) {
    addWordToList(
      scenario: word['scenario'],
      hard: word['hard'],
      wordData: {
        'word': word['word'],
        'syllables': List<String>.from(word['syllables']),
        'correct': List<String>.from(word['correct']),
        'image': word['image'],
      },
    );
  }
}
