class RouteModel {
  final String id;
  final String origen;
  final String destino;
  final int duracionMinutos;
  final double distanciaKm;
  final List<StepModel> pasos;
  final List<String> lineasBus;
  final String tiempoEstimadoLlegada;
  final int numeroTransbordos;
  final double costo;

  RouteModel({
    required this.id,
    required this.origen,
    required this.destino,
    required this.duracionMinutos,
    required this.distanciaKm,
    required this.pasos,
    required this.lineasBus,
    required this.tiempoEstimadoLlegada,
    required this.numeroTransbordos,
    required this.costo,
  });

  factory RouteModel.fromDirectionsJson(Map<String, dynamic> json) {
    final route = json['routes'][0];
    final leg = route['legs'][0];
    
    List<StepModel> pasos = [];
    if (leg['steps'] != null) {
      pasos = (leg['steps'] as List)
          .map((step) => StepModel.fromJson(step))
          .toList();
    }

    return RouteModel(
      id: route['summary'] ?? '',
      origen: leg['start_address'] ?? '',
      destino: leg['end_address'] ?? '',
      duracionMinutos: (leg['duration']['value'] / 60).round(),
      distanciaKm: (leg['distance']['value'] / 1000),
      pasos: pasos,
      lineasBus: _extractBusLines(leg),
      tiempoEstimadoLlegada: leg['arrival_time']?['text'] ?? '',
      numeroTransbordos: _countTransfers(leg),
      costo: 0.0, // Se calculará con STM API
    );
  }

  static List<String> _extractBusLines(Map<String, dynamic> leg) {
    List<String> lines = [];
    if (leg['steps'] != null) {
      for (var step in leg['steps']) {
        if (step['transit_details'] != null) {
          final line = step['transit_details']['line'];
          if (line != null && line['short_name'] != null) {
            lines.add(line['short_name']);
          }
        }
      }
    }
    return lines;
  }

  static int _countTransfers(Map<String, dynamic> leg) {
    int transfers = 0;
    if (leg['steps'] != null) {
      for (var step in leg['steps']) {
        if (step['transit_details'] != null) {
          transfers++;
        }
      }
    }
    return transfers > 0 ? transfers - 1 : 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'origen': origen,
      'destino': destino,
      'duracionMinutos': duracionMinutos,
      'distanciaKm': distanciaKm,
      'pasos': pasos.map((p) => p.toJson()).toList(),
      'lineasBus': lineasBus,
      'tiempoEstimadoLlegada': tiempoEstimadoLlegada,
      'numeroTransbordos': numeroTransbordos,
      'costo': costo,
    };
  }
}

class StepModel {
  final String instruccion;
  final String distancia;
  final String duracion;
  final double startLat;
  final double startLng;
  final double endLat;
  final double endLng;
  final String modoTransporte;
  final String? lineaBus;
  final String? paradaInicio;
  final String? paradaFin;

  StepModel({
    required this.instruccion,
    required this.distancia,
    required this.duracion,
    required this.startLat,
    required this.startLng,
    required this.endLat,
    required this.endLng,
    required this.modoTransporte,
    this.lineaBus,
    this.paradaInicio,
    this.paradaFin,
  });

  factory StepModel.fromJson(Map<String, dynamic> json) {
    final startLocation = json['start_location'];
    final endLocation = json['end_location'];
    final transitDetails = json['transit_details'];

    return StepModel(
      instruccion: json['html_instructions'] ?? '',
      distancia: json['distance']['text'] ?? '',
      duracion: json['duration']['text'] ?? '',
      startLat: startLocation['lat']?.toDouble() ?? 0.0,
      startLng: startLocation['lng']?.toDouble() ?? 0.0,
      endLat: endLocation['lat']?.toDouble() ?? 0.0,
      endLng: endLocation['lng']?.toDouble() ?? 0.0,
      modoTransporte: json['travel_mode'] ?? 'WALKING',
      lineaBus: transitDetails?['line']?['short_name'],
      paradaInicio: transitDetails?['departure_stop']?['name'],
      paradaFin: transitDetails?['arrival_stop']?['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'instruccion': instruccion,
      'distancia': distancia,
      'duracion': duracion,
      'startLat': startLat,
      'startLng': startLng,
      'endLat': endLat,
      'endLng': endLng,
      'modoTransporte': modoTransporte,
      'lineaBus': lineaBus,
      'paradaInicio': paradaInicio,
      'paradaFin': paradaFin,
    };
  }
}
