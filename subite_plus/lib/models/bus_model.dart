class BusModel {
  final String id;
  final String linea;
  final double latitud;
  final double longitud;
  final String destino;
  final int tiempoEstimadoArribo; // en minutos
  final String estado; // "EN_RUTA", "EN_PARADA", "FUERA_SERVICIO"
  final DateTime ultimaActualizacion;
  final int ocupacion; // porcentaje de ocupación
  final String? paradaProxima;

  BusModel({
    required this.id,
    required this.linea,
    required this.latitud,
    required this.longitud,
    required this.destino,
    required this.tiempoEstimadoArribo,
    required this.estado,
    required this.ultimaActualizacion,
    required this.ocupacion,
    this.paradaProxima,
  });

  factory BusModel.fromStmJson(Map<String, dynamic> json) {
    return BusModel(
      id: json['id']?.toString() ?? '',
      linea: json['linea']?.toString() ?? '',
      latitud: json['latitud']?.toDouble() ?? 0.0,
      longitud: json['longitud']?.toDouble() ?? 0.0,
      destino: json['destino']?.toString() ?? '',
      tiempoEstimadoArribo: json['tiempoEstimadoArribo']?.toInt() ?? 0,
      estado: json['estado']?.toString() ?? 'DESCONOCIDO',
      ultimaActualizacion: json['ultimaActualizacion'] != null 
          ? DateTime.parse(json['ultimaActualizacion'])
          : DateTime.now(),
      ocupacion: json['ocupacion']?.toInt() ?? 0,
      paradaProxima: json['paradaProxima']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'linea': linea,
      'latitud': latitud,
      'longitud': longitud,
      'destino': destino,
      'tiempoEstimadoArribo': tiempoEstimadoArribo,
      'estado': estado,
      'ultimaActualizacion': ultimaActualizacion.toIso8601String(),
      'ocupacion': ocupacion,
      'paradaProxima': paradaProxima,
    };
  }

  String get tiempoArriboTexto {
    if (tiempoEstimadoArribo <= 0) return 'Llegando';
    if (tiempoEstimadoArribo == 1) return '1 min';
    return '$tiempoEstimadoArribo min';
  }

  String get ocupacionTexto {
    if (ocupacion <= 30) return 'Poco ocupado';
    if (ocupacion <= 70) return 'Moderadamente ocupado';
    return 'Muy ocupado';
  }
}

class StopModel {
  final String id;
  final String nombre;
  final double latitud;
  final double longitud;
  final List<String> lineasQueParanAqui;
  final String? direccion;
  final bool tieneAccesibilidad;
  final List<BusArrivalModel> proximosArribos;

  StopModel({
    required this.id,
    required this.nombre,
    required this.latitud,
    required this.longitud,
    required this.lineasQueParanAqui,
    this.direccion,
    required this.tieneAccesibilidad,
    required this.proximosArribos,
  });

  factory StopModel.fromStmJson(Map<String, dynamic> json) {
    List<BusArrivalModel> arribos = [];
    if (json['proximosArribos'] != null) {
      arribos = (json['proximosArribos'] as List)
          .map((arribo) => BusArrivalModel.fromJson(arribo))
          .toList();
    }

    List<String> lineas = [];
    if (json['lineas'] != null) {
      lineas = (json['lineas'] as List)
          .map((linea) => linea.toString())
          .toList();
    }

    return StopModel(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      latitud: json['latitud']?.toDouble() ?? 0.0,
      longitud: json['longitud']?.toDouble() ?? 0.0,
      lineasQueParanAqui: lineas,
      direccion: json['direccion']?.toString(),
      tieneAccesibilidad: json['accesibilidad'] ?? false,
      proximosArribos: arribos,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'latitud': latitud,
      'longitud': longitud,
      'lineasQueParanAqui': lineasQueParanAqui,
      'direccion': direccion,
      'tieneAccesibilidad': tieneAccesibilidad,
      'proximosArribos': proximosArribos.map((a) => a.toJson()).toList(),
    };
  }
}

class BusArrivalModel {
  final String linea;
  final String destino;
  final int tiempoEstimadoMinutos;
  final String estado;
  final DateTime horaEstimada;

  BusArrivalModel({
    required this.linea,
    required this.destino,
    required this.tiempoEstimadoMinutos,
    required this.estado,
    required this.horaEstimada,
  });

  factory BusArrivalModel.fromJson(Map<String, dynamic> json) {
    return BusArrivalModel(
      linea: json['linea']?.toString() ?? '',
      destino: json['destino']?.toString() ?? '',
      tiempoEstimadoMinutos: json['tiempoEstimado']?.toInt() ?? 0,
      estado: json['estado']?.toString() ?? 'PROGRAMADO',
      horaEstimada: json['horaEstimada'] != null 
          ? DateTime.parse(json['horaEstimada'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'linea': linea,
      'destino': destino,
      'tiempoEstimadoMinutos': tiempoEstimadoMinutos,
      'estado': estado,
      'horaEstimada': horaEstimada.toIso8601String(),
    };
  }

  String get tiempoTexto {
    if (tiempoEstimadoMinutos <= 0) return 'Llegando';
    if (tiempoEstimadoMinutos == 1) return '1 min';
    return '$tiempoEstimadoMinutos min';
  }
}
