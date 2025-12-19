import 'package:flutter/material.dart';
import '/repositories/achievement_repository.dart';

class AchievementsCard extends StatelessWidget {
  final int studentId;

  const AchievementsCard({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    final repo = AchievementRepository();

    return FutureBuilder(
      future: repo.getAchievements(studentId),
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final achievements = snapshot.data!;

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
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                ...achievements.map((a) {
                  return ListTile(
                    leading: Icon(
                      a.unlocked ? Icons.star : Icons.lock,
                      color: a.unlocked
                          ? Colors.amber
                          : Colors.grey,
                    ),
                    title: Text(a.title),
                    subtitle: Text(a.description),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
