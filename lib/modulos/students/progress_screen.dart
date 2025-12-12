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
  final ProgressRepository _progressRepo = ProgressRepository();

  double _readingProgress = 0.0;
  bool _loading = true;

  static const int totalReadingActivities = 3; // tus cuentos actuales

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    print("📊 Cargando progreso para studentId=${widget.studentId}");

    final completed =
        await _progressRepo.countCompletedActivities(widget.studentId);

    print("✅ Actividades completadas: $completed");

    setState(() {
      _readingProgress = totalReadingActivities == 0
          ? 0
          : (completed / totalReadingActivities).clamp(0.0, 1.0);
      _loading = false;
    });

    print("🟢 ProgressScreen terminó de cargar");
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
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    "Aquí está tu progreso",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),

                  /// 📖 LECTURA (REAL)
                  ProgressCategoryCard(
                    title: "Lectura",
                    icon: Icons.menu_book_rounded,
                    color: Colors.lightBlue,
                    items: [
                      ProgressItem(
                        label: "Lectura guiada",
                        progress: _readingProgress,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// ✍️ ESCRITURA (ESTÁTICO POR AHORA)
                  ProgressCategoryCard(
                    title: "Escritura",
                    icon: Icons.edit_rounded,
                    color: Colors.orangeAccent,
                    items: const [
                      ProgressItem(
                        label: "Escribe una vocal",
                        progress: 0.7,
                      ),
                      ProgressItem(
                        label: "Escribe la palabra",
                        progress: 0.5,
                      ),
                    ],
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

/// =======================
/// CATEGORY CARD
/// =======================
class ProgressCategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<ProgressItem> items;

  const ProgressCategoryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
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
            /// Header
            Row(
              children: [
                Icon(icon, color: color, size: 28),
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

            const SizedBox(height: 20),

            /// Items
            ...items.map((item) => ProgressRow(item: item)),
          ],
        ),
      ),
    );
  }
}

/// =======================
/// PROGRESS ITEM MODEL
/// =======================
class ProgressItem {
  final String label;
  final double progress;

  const ProgressItem({
    required this.label,
    required this.progress,
  });
}

/// =======================
/// PROGRESS ROW
/// =======================
class ProgressRow extends StatelessWidget {
  final ProgressItem item;

  const ProgressRow({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (item.progress * 100).round();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: item.progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.blueAccent,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "$percent%",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
