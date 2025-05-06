class Emergencia {
  final int id;
  final String? tipo;
  final DateTime? fecha; // Cambiado a fechaHora para coincidir con el backend
  final int? piso;
  final dynamic usuario_nombre;

  Emergencia({
    required this.id,
    this.tipo,
    this.fecha, // Usar fechaHora aquí
    this.piso,
    this.usuario_nombre,
  });

  factory Emergencia.fromJson(Map<String, dynamic> json) {
    return Emergencia(
      id: json['id'],
      tipo: json['tipo'],
      fecha: json['fecha'] != null ? DateTime.parse(json['fecha']).toLocal() : null, 
      piso: json['piso'],
      usuario_nombre: json['usuario_nombre'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo,
      'fecha': fecha?.toIso8601String(),
      'piso': piso,
      'usuario_nombre': usuario_nombre,
    };
  }
}