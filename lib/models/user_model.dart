class User {
  final String username;
  final String correo;
  final String curso;
  final int edad;
  final DateTime fechaNac;
  final String password;

  User({
    required this.username,
    required this.correo,
    required this.curso,
    required this.edad,
    required this.fechaNac,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'nombre_user': username,
      'correo_user': correo,
      'curso_user': curso,
      'edad_user': edad,
      'fecha_nac': fechaNac,
      'tipo_usuario': 'estudiante',
    };
  }
}


