class Student {
  final int? id;
  final String name;
  final int progress;

  Student({
    this.id,
    required this.name,
    required this.progress,
  });

  // Convertir de Map a objeto
  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      name: map['name'],
      progress: map['progress'],
    );
  }

  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'progress': progress,
    };
  }
}
