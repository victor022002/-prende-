import 'package:flutter/material.dart';
import '/repositories/progress_repository.dart';

class ProgressScreen extends StatefulWidget {
  final int studentId;

  const ProgressScreen({
    super.key,
    required this.studentId,
  });

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final ProgressRepository _repo = ProgressRepository();

  bool _loading = true;

  double _readingProgress = 0;
  double _syllablesProgress = 0;
  double _writingProgress = 0;
  double _listeningProgress = 0; 

  Set<int> _completed = {};

  // totales
  static const int totalReading = 2;
  static const int totalSyllables = 6;
  static const int totalWriting = 5;
  static const int totalListening = 2; 

  // LECTURA
  static const Map<int, String> readingActivities = {
    1: "Lectura guiada",
    2: "Completa la oración",
  };

  // SÍLABAS
  static const Map<int, String> syllablesActivities = {
    100: "Ordenar sílabas (fácil)",
    101: "Ordenar sílabas (difícil)",
    110: "Naturaleza fácil",
    111: "Naturaleza difícil",
    120: "Objetos fácil",
    121: "Objetos difícil",
  };

  // ESCRITURA
  static const Map<int, String> writingActivities = {
    200: "Vocal A",
    201: "Vocal E",
    202: "Vocal I",
    203: "Vocal O",
    204: "Vocal U",
  };

  // 👂 ESCUCHA (NUEVO)
  static const Map<int, String> listeningActivities = {
    300: "Escucha: Perro",
    301: "Escucha: Gato",
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  double _activityProgress(int id) {
    return _completed.contains(id) ? 1.0 : 0.0;
  }

  Future<void> _load() async {
    final completedIds =
        await _repo.getCompletedActivityIds(widget.studentId);

    _completed = completedIds.toSet();

    final readingDone = _completed.where((id) => id < 100).length;
    final syllablesDone =
        _completed.where((id) => id >= 100 && id < 200).length;
    final writingDone =
        _completed.where((id) => id >= 200 && id < 300).length;
    final listeningDone =
        _completed.where((id) => id >= 300 && id < 400).length;

    setState(() {
      _readingProgress = readingDone / totalReading;
      _syllablesProgress =
          (syllablesDone / totalSyllables).clamp(0.0, 1.0);
      _writingProgress = writingDone / totalWriting;
      _listeningProgress =
          (listeningDone / totalListening).clamp(0.0, 1.0);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Aquí está tu progreso",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 30),

              /// 📖 LECTURA
              ProgressCategoryCard(
                title: "Lectura",
                icon: Icons.menu_book,
                color: Colors.lightBlue,
                general: ProgressItem(
                  label: "Actividades de lectura",
                  progress: _readingProgress,
                ),
                children: readingActivities.entries.map((e) {
                  return MiniProgressRow(
                    label: e.value,
                    progress: _activityProgress(e.key),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              /// 🧩 SÍLABAS
              ProgressCategoryCard(
                title: "Sílabas",
                icon: Icons.extension,
                color: Colors.green,
                general: ProgressItem(
                  label: "Ordenar sílabas",
                  progress: _syllablesProgress,
                ),
                children: syllablesActivities.entries.map((e) {
                  return MiniProgressRow(
                    label: e.value,
                    progress: _activityProgress(e.key),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              /// ✍️ ESCRITURA
              ProgressCategoryCard(
                title: "Escritura",
                icon: Icons.edit,
                color: Colors.orange,
                general: ProgressItem(
                  label: "Escritura de vocales",
                  progress: _writingProgress,
                ),
                children: writingActivities.entries.map((e) {
                  return MiniProgressRow(
                    label: e.value,
                    progress: _activityProgress(e.key),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              /// 👂 ESCUCHA 
              ProgressCategoryCard(
                title: "Escucha",
                icon: Icons.hearing,
                color: Colors.purple,
                general: ProgressItem(
                  label: "Actividades de escucha",
                  progress: _listeningProgress,
                ),
                children: listeningActivities.entries.map((e) {
                  return MiniProgressRow(
                    label: e.value,
                    progress: _activityProgress(e.key),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              /// 🏆 LOGROS 
              AchievementsCard(studentId: widget.studentId),
            ],
          ),
        ),
      ),
    );
  }
}

class ProgressCategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final ProgressItem general;
  final List<Widget> children;

  const ProgressCategoryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.general,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            ProgressRow(item: general),

            const Divider(height: 26),

            ...children,
          ],
        ),
      ),
    );
  }
}

class ProgressItem {
  final String label;
  final double progress;

  const ProgressItem({
    required this.label,
    required this.progress,
  });
}

class ProgressRow extends StatelessWidget {
  final ProgressItem item;

  const ProgressRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final percent = (item.progress * 100).round();

    return Row(
      children: [
        Expanded(child: Text(item.label)),
        const SizedBox(width: 10),
        Expanded(
          child: LinearProgressIndicator(
            value: item.progress,
            minHeight: 8,
          ),
        ),
        const SizedBox(width: 10),
        Text("$percent%"),
      ],
    );
  }
}

class MiniProgressRow extends StatelessWidget {
  final String label;
  final double progress;

  const MiniProgressRow({
    super.key,
    required this.label,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          SizedBox(
            width: 90,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
            ),
          ),
          const SizedBox(width: 8),
          Text("$percent%"),
        ],
      ),
    );
  }
}


class AchievementsCard extends StatefulWidget {
  final int studentId;

  const AchievementsCard({
    super.key,
    required this.studentId,
  });

  @override
  State<AchievementsCard> createState() => _AchievementsCardState();
}

class _AchievementsCardState extends State<AchievementsCard> {
  final ProgressRepository _repo = ProgressRepository();

  bool _loading = true;
  late Set<int> _completed;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ids =
        await _repo.getCompletedActivityIds(widget.studentId);
    setState(() {
      _completed = ids.toSet();
      _loading = false;
    });
  }

  bool get hasAnyActivity => _completed.isNotEmpty;

  bool get hasListening =>
      _completed.any((id) => id >= 300 && id < 400);

  bool get hasAllSyllables =>
      _completed.where((id) => id >= 100 && id < 200).length >= 6;

  bool get hasAllCategories {
    final hasReading = _completed.any((id) => id < 100);
    final hasSyllables =
        _completed.any((id) => id >= 100 && id < 200);
    final hasWriting =
        _completed.any((id) => id >= 200 && id < 300);
    final hasListening =
        _completed.any((id) => id >= 300 && id < 400);

    return hasReading &&
        hasSyllables &&
        hasWriting &&
        hasListening;
  }

  Widget _achievement({
    required String title,
    required String description,
    required bool unlocked,
  }) {
    return ListTile(
      isThreeLine: true, 
      leading: Icon(
        unlocked ? Icons.star : Icons.lock,
        color: unlocked ? Colors.amber : Colors.grey,
        size: 28,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: unlocked ? Colors.black : Colors.black54,
        ),
      ),
      subtitle: Text(
        description,
        style: TextStyle(
          fontSize: 13,
          color: unlocked ? Colors.black54 : Colors.grey,
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Logros",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.pinkAccent,
              ),
            ),
            const SizedBox(height: 12),

            _achievement(
              title: "Primer paso",
              description: "Completa tu primera actividad",
              unlocked: hasAnyActivity,
            ),

            _achievement(
              title: "Buen oyente",
              description: "Completa tu primera actividad de escucha",
              unlocked: hasListening,
            ),

            _achievement(
              title: "Maestro de sílabas",
              description: "Completa todas las actividades de sílabas",
              unlocked: hasAllSyllables,
            ),

            _achievement(
              title: "Aprende+ completo",
              description: "Completa actividades de lectura, sílabas, escritura y escucha",
              unlocked: hasAllCategories,
            ),

          ],
        ),
      ),
    );
  }
}

