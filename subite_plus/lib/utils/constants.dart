class ApiConstants {
  // Google Maps API
  static const String googleMapsApiKey = 'AIzaSyD1R-HlWiKZ55BMDdv1KP5anE5T5MX4YkU';
  
  // STM API Credentials
  static const String stmClientId = 'd7916e2b';
  static const String stmClientSecret = '164c5cf512e692dbfcc2fbda1f0ec0a1';
  static const String stmAccessTokenUrl = 'https://mvdapi-auth.montevideo.gub.uy/token';
  static const String stmBaseUrl = 'https://mvdapi.montevideo.gub.uy/api/transportepublico';
  
  // Google Directions API
  static const String directionsApiUrl = 'https://maps.googleapis.com/maps/api/directions/json';
  static const String placesApiUrl = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
}

class AppConstants {
  // Montevideo coordinates
  static const double montevideoLat = -34.9011;
  static const double montevideoLng = -56.1645;
  
  // App strings in Spanish
  static const String appName = 'Subite+';
  static const String buscarRuta = 'Buscar ruta';
  static const String modoNavegacion = 'Modo navegación';
  static const String opcionesTrayecto = 'Opciones de trayecto';
  static const String proximosArribos = 'Próximos arribos';
  static const String detallesViaje = 'Detalles del viaje';
  static const String indicacionesPaso = 'Indicaciones paso a paso';
  static const String busEnMapa = 'Bus en mapa en tiempo real';
  static const String origen = 'Origen';
  static const String destino = 'Destino';
  static const String ubicacionActual = 'Ubicación actual';
  static const String noRutasEncontradas = 'No se encontraron rutas disponibles';
  static const String errorConexion = 'Error de conexión. Intente nuevamente.';
  static const String cargando = 'Cargando...';
}

class StyleConstants {
  // Colors - Minimalist palette
  static const int primaryColor = 0xFF2196F3; // Blue transport
  static const int backgroundColor = 0xFFFFFFFF; // White
  static const int surfaceColor = 0xFFF5F5F5; // Light gray
  static const int textPrimary = 0xFF212121; // Dark gray
  static const int textSecondary = 0xFF757575; // Medium gray
  static const int accentColor = 0xFF4CAF50; // Green for success
  static const int errorColor = 0xFFF44336; // Red for errors
  
  // Typography - Very small Arial fonts
  static const double fontSizeVerySmall = 10.0;
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  
  // Spacing - Minimal
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  
  // Border radius
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
}
