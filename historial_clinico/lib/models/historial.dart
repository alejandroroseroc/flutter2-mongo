import 'consulta.dart';

class HistorialClinico {
  final String pacienteId;
  final String nombre;
  final int edad;
  final List<String> alergias;
  final List<Consulta> consultas;

  HistorialClinico({
    required this.pacienteId,
    required this.nombre,
    required this.edad,
    required this.alergias,
    required this.consultas,
  });

  factory HistorialClinico.fromJson(Map<String, dynamic> json) {
    final listaConsultas = (json['consultas'] as List<dynamic>? ?? [])
        .map((c) => Consulta.fromJson(c as Map<String, dynamic>))
        .toList();

    return HistorialClinico(
      pacienteId: json['pacienteId'] ?? '',
      nombre: json['nombre'] ?? '',
      edad: json['edad'] ?? 0,
      alergias: List<String>.from(json['alergias'] ?? []),
      consultas: listaConsultas,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pacienteId': pacienteId,
      'nombre': nombre,
      'edad': edad,
      'alergias': alergias,
      'consultas': consultas.map((c) => c.toJson()).toList(),
    };
  }
}