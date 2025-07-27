import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../utils/constants.dart';

class LocationService {
  
  // Verificar y solicitar permisos de ubicación
  static Future<bool> checkAndRequestPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si el servicio de ubicación está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // Obtener ubicación actual del usuario
  static Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await checkAndRequestPermissions();
      if (!hasPermission) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );

      return position;
    } catch (e) {
      print('Error obteniendo ubicación actual: $e');
      return null;
    }
  }

  // Obtener dirección desde coordenadas (reverse geocoding)
  static Future<String?> getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        
        // Construir dirección en formato uruguayo
        List<String> addressParts = [];
        
        if (placemark.street != null && placemark.street!.isNotEmpty) {
          addressParts.add(placemark.street!);
        }
        
        if (placemark.subThoroughfare != null && placemark.subThoroughfare!.isNotEmpty) {
          addressParts.add(placemark.subThoroughfare!);
        }
        
        if (placemark.locality != null && placemark.locality!.isNotEmpty) {
          addressParts.add(placemark.locality!);
        }
        
        if (placemark.administrativeArea != null && placemark.administrativeArea!.isNotEmpty) {
          addressParts.add(placemark.administrativeArea!);
        }

        return addressParts.join(', ');
      }
      
      return null;
    } catch (e) {
      print('Error obteniendo dirección desde coordenadas: $e');
      return null;
    }
  }

  // Obtener coordenadas desde dirección (geocoding)
  static Future<Position?> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      
      if (locations.isNotEmpty) {
        final location = locations.first;
        return Position(
          latitude: location.latitude,
          longitude: location.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      }
      
      return null;
    } catch (e) {
      print('Error obteniendo coordenadas desde dirección: $e');
      return null;
    }
  }

  // Calcular distancia entre dos puntos
  static double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
  }

  // Verificar si una ubicación está dentro de Montevideo
  static bool isLocationInMontevideo(double lat, double lng) {
    // Coordenadas aproximadas del área metropolitana de Montevideo
    const double minLat = -34.95;
    const double maxLat = -34.80;
    const double minLng = -56.30;
    const double maxLng = -56.00;
    
    return lat >= minLat && lat <= maxLat && lng >= minLng && lng <= maxLng;
  }

  // Obtener ubicación actual como texto
  static Future<String> getCurrentLocationAsText() async {
    try {
      final position = await getCurrentLocation();
      if (position != null) {
        final address = await getAddressFromCoordinates(
          position.latitude, 
          position.longitude
        );
        
        return address ?? AppConstants.ubicacionActual;
      }
      
      return AppConstants.ubicacionActual;
    } catch (e) {
      print('Error obteniendo ubicación actual como texto: $e');
      return AppConstants.ubicacionActual;
    }
  }

  // Stream de ubicación en tiempo real
  static Stream<Position> getLocationStream() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Actualizar cada 10 metros
    );
    
    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  // Verificar si el usuario está cerca de una parada
  static bool isNearStop(Position userPosition, double stopLat, double stopLng, {double radiusMeters = 100}) {
    final distance = calculateDistance(
      userPosition.latitude,
      userPosition.longitude,
      stopLat,
      stopLng,
    );
    
    return distance <= radiusMeters;
  }

  // Obtener la parada más cercana
  static Map<String, dynamic>? findNearestStop(
    Position userPosition, 
    List<Map<String, dynamic>> stops
  ) {
    if (stops.isEmpty) return null;
    
    Map<String, dynamic>? nearestStop;
    double minDistance = double.infinity;
    
    for (var stop in stops) {
      final stopLat = stop['latitud']?.toDouble() ?? 0.0;
      final stopLng = stop['longitud']?.toDouble() ?? 0.0;
      
      final distance = calculateDistance(
        userPosition.latitude,
        userPosition.longitude,
        stopLat,
        stopLng,
      );
      
      if (distance < minDistance) {
        minDistance = distance;
        nearestStop = stop;
        nearestStop['distancia'] = distance;
      }
    }
    
    return nearestStop;
  }

  // Formatear distancia para mostrar al usuario
  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()} m';
    } else {
      final km = distanceInMeters / 1000;
      return '${km.toStringAsFixed(1)} km';
    }
  }

  // Obtener dirección hacia un punto
  static double getBearing(double lat1, double lng1, double lat2, double lng2) {
    return Geolocator.bearingBetween(lat1, lng1, lat2, lng2);
  }

  // Convertir bearing a dirección cardinal
  static String bearingToCardinal(double bearing) {
    const directions = [
      'Norte', 'Noreste', 'Este', 'Sureste',
      'Sur', 'Suroeste', 'Oeste', 'Noroeste'
    ];
    
    final index = ((bearing + 22.5) / 45).floor() % 8;
    return directions[index];
  }

  // Verificar si la ubicación está actualizada (no muy antigua)
  static bool isLocationFresh(Position position, {int maxAgeMinutes = 5}) {
    final now = DateTime.now();
    final locationTime = position.timestamp ?? now;
    final difference = now.difference(locationTime);
    
    return difference.inMinutes <= maxAgeMinutes;
  }

  // Obtener configuración de ubicación recomendada para navegación
  static LocationSettings getNavigationLocationSettings() {
    return const LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 5, // Actualizar cada 5 metros durante navegación
    );
  }

  // Limpiar recursos de ubicación
  static void dispose() {
    // Implementar limpieza si es necesario
  }
}
