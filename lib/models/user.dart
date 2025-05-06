class User {
  final int id;
  final String username;
  final String? nombre;
  final String? email; // Cambiado a email
  final String? telefono; // Añadido el campo telefono
  final String? tipoUsuario; // Cambiado a tipoUsuario

  User({
    required this.id,
    required this.username,
    this.nombre,
    this.email,
    this.telefono,
    this.tipoUsuario,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      nombre: json['nombre'],
      email: json['email'], // Usa 'email' del JSON
      telefono: json['telefono'], // Usa 'telefono' del JSON
      tipoUsuario: json['tipo_usuario'], // Usa 'tipo_usuario' del JSON
    );
  }

  // Opcional: Método toJson si lo necesitas para la edición
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'tipo_usuario': tipoUsuario,
    };
  }
}