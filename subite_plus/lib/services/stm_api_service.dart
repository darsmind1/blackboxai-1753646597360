import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bus_model.dart';
import '../utils/constants.dart';

class StmApiService {
  static String? _accessToken;
  static DateTime? _tokenExpiry;

  // Obtener token de acceso
  static Future<String?> _getAccessToken() async {
    // Verificar si el token actual sigue siendo válido
    if (_accessToken != null && 
        _tokenExpiry != null && 
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _accessToken;
    }

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.stmAccessTokenUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'client_credentials',
          'client_id': ApiConstants.stmClientId,
          'client_secret': ApiConstants.stmClientSecret,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];
        
        // Calcular tiempo de expiración (generalmente 1 hora)
        final expiresIn = data['expires_in'] ?? 3600;
        _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn - 60));
        
        return _accessToken;
      } else {
        print('Error obteniendo token STM: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error de conexión STM API: $e');
      return null;
    }
  }

  // Realizar petición autenticada a STM API
  static Future<Map<String, dynamic>?> _makeAuthenticatedRequest(String endpoint) async {
    final token = await _getAccessToken();
    if (token == null) {
      throw Exception('No se pudo obtener token de acceso STM');
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.stmBaseUrl}$endpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        // Token expirado, limpiar y reintentar
        _accessToken = null;
        _tokenExpiry = null;
        return await _makeAuthenticatedRequest(endpoint);
      } else {
        print('Error en petición STM: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error de conexión STM: $e');
      return null;
    }
  }

  // Obtener buses en tiempo real por línea
  static Future<List<BusModel>> getBusesByLine(String linea) async {
    try {
      final data = await _makeAuthenticatedRequest('/buses/linea/$linea');
      if (data != null && data['buses'] != null) {
        return (data['buses'] as List)
            .map((bus) => BusModel.fromStmJson(bus))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error obteniendo buses de línea $linea: $e');
      return [];
    }
  }

  // Obtener buses cercanos a una ubicación
  static Future<List<BusModel>> getNearbyBuses(double lat, double lng, {double radiusKm = 2.0}) async {
    try {
      final data = await _makeAuthenticatedRequest('/buses/cercanos?lat=$lat&lng=$lng&radio=$radiusKm');
      if (data != null && data['buses'] != null) {
        return (data['buses'] as List)
            .map((bus) => BusModel.fromStmJson(bus))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error obteniendo buses cercanos: $e');
      return [];
    }
  }

  // Obtener información de parada específica
  static Future<StopModel?> getStopInfo(String stopId) async {
    try {
      final data = await _makeAuthenticatedRequest('/paradas/$stopId');
      if (data != null) {
        return StopModel.fromStmJson(data);
      }
      return null;
    } catch (e) {
      print('Error obteniendo información de parada $stopId: $e');
      return null;
    }
  }

  // Obtener paradas cercanas
  static Future<List<StopModel>> getNearbyStops(double lat, double lng, {double radiusKm = 1.0}) async {
    try {
      final data = await _makeAuthenticatedRequest('/paradas/cercanas?lat=$lat&lng=$lng&radio=$radiusKm');
      if (data != null && data['paradas'] != null) {
        return (data['paradas'] as List)
            .map((stop) => StopModel.fromStmJson(stop))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error obteniendo paradas cercanas: $e');
      return [];
    }
  }

  // Obtener próximos arribos para una parada
  static Future<List<BusArrivalModel>> getUpcomingArrivals(String stopId) async {
    try {
      final data = await _makeAuthenticatedRequest('/paradas/$stopId/arribos');
      if (data != null && data['arribos'] != null) {
        return (data['arribos'] as List)
            .map((arrival) => BusArrivalModel.fromJson(arrival))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error obteniendo arribos para parada $stopId: $e');
      return [];
    }
  }

  // Obtener todas las líneas disponibles
  static Future<List<String>> getAvailableLines() async {
    try {
      final data = await _makeAuthenticatedRequest('/lineas');
      if (data != null && data['lineas'] != null) {
        return (data['lineas'] as List)
            .map((line) => line.toString())
            .toList();
      }
      return [];
    } catch (e) {
      print('Error obteniendo líneas disponibles: $e');
      return [];
    }
  }

  // Obtener información detallada de una línea
  static Future<Map<String, dynamic>?> getLineInfo(String linea) async {
    try {
      final data = await _makeAuthenticatedRequest('/lineas/$linea');
      return data;
    } catch (e) {
      print('Error obteniendo información de línea $linea: $e');
      return null;
    }
  }

  // Obtener rutas/recorridos de una línea específica
  static Future<List<Map<String, dynamic>>> getLineRoutes(String linea) async {
    try {
      final data = await _makeAuthenticatedRequest('/lineas/$linea/recorridos');
      if (data != null && data['recorridos'] != null) {
        return List<Map<String, dynamic>>.from(data['recorridos']);
      }
      return [];
    } catch (e) {
      print('Error obteniendo recorridos de línea $linea: $e');
      return [];
    }
  }

  // Método para limpiar token (útil para logout o reset)
  static void clearToken() {
    _accessToken = null;
    _tokenExpiry = null;
  }
}
