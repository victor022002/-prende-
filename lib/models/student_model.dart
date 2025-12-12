class Student {
  int? id;
  String name;
  String email;
  DateTime createdAt;

  Student({
    this.id,
    required this.name,
    required this.email,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}





