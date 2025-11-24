class Student {
  int? id;
  String name;
  String email;
  int progress;
  int completedReading;

  Student({
    this.id,
    required this.name,
    required this.email,
    this.progress = 0,
    this.completedReading = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'progress': progress,
      'completedReading': completedReading,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      progress: map['progress'],
      completedReading: map['completedReading'],
    );
  }
}




