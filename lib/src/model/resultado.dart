class Resultado {
  final String fijo;
  final String corrido;
  final String session;
  final String estado;
  final String fecha;

  Resultado({
    required this.fijo,
    required this.corrido,
    required this.session,
    required this.estado,
    required this.fecha,
  });

  factory Resultado.fromJson(Map<String, dynamic> json) {
    return Resultado(
      fijo: json['fijo'],
      corrido: json['corrido'],
      session: json['session'],
      estado: json['estado'],
      fecha: json['fecha'],
    );
  }
}
