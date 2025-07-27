import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/route_model.dart';
import '../utils/constants.dart';

class DirectionsService {
  
  // Buscar rutas de transporte público entre origen y destino
  static Future<List<RouteModel>> getPublicTransitRoutes({
    required String origen,
    required String destino,
    DateTime? departureTime,
    bool alternatives = true,
  }) async {
    try {
      final departTime = departureTime ?? DateTime.now();
      final departureTimestamp = (departTime.millisecondsSinceEpoch / 1000).round();

      final uri = Uri.parse(ApiConstants.directionsApiUrl).replace(
        queryParameters: {
          'origin': origen,
          'destination': destino,
          'mode': 'transit',
          'transit_mode': 'bus',
          'departure_time': departureTimestamp.toString(),
          'alternatives': alternatives.toString(),
          'region': 'uy', // Uruguay
          'language': 'es', // Español
          'key': ApiConstants.googleMapsApiKey,
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['routes'] != null) {
          List<RouteModel> routes = [];
          
          for (var routeData in data['routes']) {
            try {
              final route = RouteModel.fromDirectionsJson({'routes': [routeData]});
              routes.add(route);
            } catch (e) {
              print('Error procesando ruta: $e');
              continue;
            }
          }
          
          // Ordenar por duración (más rápido primero)
          routes.sort((a, b) => a.duracionMinutos.compareTo(b.duracionMinutos));
          
          return routes;
        } else {
          print('Error en respuesta Directions API: ${data['status']}');
          if (data['error_message'] != null) {
            print('Mensaje de error: ${data['error_message']}');
          }
          return [];
        }
      } else {
        print('Error HTTP Directions API: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error obteniendo rutas: $e');
      return [];
    }
  }

  // Buscar rutas combinando caminar + transporte público
  static Future<List<RouteModel>> getMixedRoutes({
    required String origen,
    required String destino,
    DateTime? departureTime,
  }) async {
    try {
      final departTime = departureTime ?? DateTime.now();
      final departureTimestamp = (departTime.millisecondsSinceEpoch / 1000).round();

      final uri = Uri.parse(ApiConstants.directionsApiUrl).replace(
        queryParameters: {
          'origin': origen,
          'destination': destino,
          'mode': 'transit',
          'transit_mode': 'bus',
          'transit_routing_preference': 'fewer_transfers',
          'departure_time': departureTimestamp.toString(),
          'alternatives': 'true',
          'region': 'uy',
          'language': 'es',
          'key': ApiConstants.googleMapsApiKey,
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['routes'] != null) {
          List<RouteModel> routes = [];
          
          for (var routeData in data['routes']) {
            try {
              final route = RouteModel.fromDirectionsJson({'routes': [routeData]});
              routes.add(route);
            } catch (e) {
              print('Error procesando ruta mixta: $e');
              continue;
            }
          }
          
          return routes;
        }
      }
      
      return [];
    } catch (e) {
      print('Error obteniendo rutas mixtas: $e');
      return [];
    }
  }

  // Obtener detalles de una ruta específica con waypoints
  static Future<RouteModel?> getDetailedRoute({
    required String origen,
    required String destino,
    required List<String> waypoints,
    DateTime? departureTime,
  }) async {
    try {
      final departTime = departureTime ?? DateTime.now();
      final departureTimestamp = (departTime.millisecondsSinceEpoch / 1000).round();

      Map<String, String> queryParams = {
        'origin': origen,
        'destination': destino,
        'mode': 'transit',
        'transit_mode': 'bus',
        'departure_time': departureTimestamp.toString(),
        'region': 'uy',
        'language': 'es',
        'key': ApiConstants.googleMapsApiKey,
      };

      if (waypoints.isNotEmpty) {
        queryParams['waypoints'] = waypoints.join('|');
      }

      final uri = Uri.parse(ApiConstants.directionsApiUrl).replace(
        queryParameters: queryParams,
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['routes'] != null && data['routes'].isNotEmpty) {
          return RouteModel.fromDirectionsJson(data);
        }
      }
      
      return null;
    } catch (e) {
      print('Error obteniendo ruta detallada: $e');
      return null;
    }
  }

  // Buscar lugares/direcciones para autocompletar
  static Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    try {
      final uri = Uri.parse(ApiConstants.placesApiUrl).replace(
        queryParameters: {
          'input': query,
          'location': '${ApiConstants.montevideoLat},${ApiConstants.montevideoLng}',
          'radius': '50000', // 50km radius around Montevideo
          'language': 'es',
          'components': 'country:uy', // Solo Uruguay
          'key': ApiConstants.googleMapsApiKey,
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['predictions'] != null) {
          return List<Map<String, dynamic>>.from(data['predictions']);
        }
      }
      
      return [];
    } catch (e) {
      print('Error buscando lugares: $e');
      return [];
    }
  }

  // Obtener coordenadas de una dirección (geocoding)
  static Future<Map<String, double>?> getCoordinatesFromAddress(String address) async {
    try {
      final uri = Uri.parse('https://maps.googleapis.com/maps/api/geocode/json').replace(
        queryParameters: {
          'address': address,
          'region': 'uy',
          'key': ApiConstants.googleMapsApiKey,
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['results'] != null && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          return {
            'lat': location['lat'].toDouble(),
            'lng': location['lng'].toDouble(),
          };
        }
      }
      
      return null;
    } catch (e) {
      print('Error obteniendo coordenadas: $e');
      return null;
    }
  }

  // Calcular distancia y tiempo entre dos puntos
  static Future<Map<String, dynamic>?> getDistanceMatrix({
    required List<String> origins,
    required List<String> destinations,
    String mode = 'transit',
    DateTime? departureTime,
  }) async {
    try {
      final departTime = departureTime ?? DateTime.now();
      final departureTimestamp = (departTime.millisecondsSinceEpoch / 1000).round();

      final uri = Uri.parse('https://maps.googleapis.com/maps/api/distancematrix/json').replace(
        queryParameters: {
          'origins': origins.join('|'),
          'destinations': destinations.join('|'),
          'mode': mode,
          'departure_time': departureTimestamp.toString(),
          'language': 'es',
          'region': 'uy',
          'key': ApiConstants.googleMapsApiKey,
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          return data;
        }
      }
      
      return null;
    } catch (e) {
      print('Error calculando matriz de distancias: $e');
      return null;
    }
  }

  // Validar si una dirección existe en Montevideo
  static Future<bool> validateAddressInMontevideo(String address) async {
    try {
      final coordinates = await getCoordinatesFromAddress(address);
      if (coordinates != null) {
        final lat = coordinates['lat']!;
        final lng = coordinates['lng']!;
        
        // Verificar si está dentro del área metropolitana de Montevideo
        // Coordenadas aproximadas del área metropolitana
        const double minLat = -34.95;
        const double maxLat = -34.80;
        const double minLng = -56.30;
        const double maxLng = -56.00;
        
        return lat >= minLat && lat <= maxLat && lng >= minLng && lng <= maxLng;
      }
      
      return false;
    } catch (e) {
      print('Error validando dirección: $e');
      return false;
    }
  }
}
