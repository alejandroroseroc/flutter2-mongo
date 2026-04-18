class Consulta {
  final String fecha;
  final String diagnostico;
  final String medicamento;
  final String medico;
  
  Consulta({
    required this.fecha,
    required this.diagnostico,
    required this.medicamento,
    required this.medico,
  });

  factory Consulta.fromJson(Map<String, dynamic> json) {
    return Consulta(
      fecha: json['fecha'] ?? '',
      diagnostico: json['diagnostico'] ?? '',
      medicamento: json['medicamento'] ?? '',
      medico: json['medico'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fecha': fecha,
      'diagnostico': diagnostico,
      'medicamento': medicamento,
      'medico': medico,
    };
  }
}