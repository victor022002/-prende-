// word_lists.dart

// CIUDAD 

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
    'syllables': ['C', 'A', 'S', 'A'],
    'correct': ['C', 'A', 'S', 'A'],
  }
];

// NATURALEZA 
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

//  OBJETOS 

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

// SELECTOR 

List<Map<String, dynamic>> getWordList(String scenario, bool hard) {
  if (scenario == "city") return hard ? cityHard : cityEasy;
  if (scenario == "nature") return hard ? natureHard : natureEasy;
  if (scenario == "objects") return hard ? objectsHard : objectsEasy;

  // Si algo falla, devolvemos lista vacía del tipo correcto
  return <Map<String, dynamic>>[];
}
