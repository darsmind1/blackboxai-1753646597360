import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../models/route_model.dart';
import '../models/bus_model.dart';
import '../services/location_service.dart';
import '../services/stm_api_service.dart';
import '../utils/constants.dart';
import '../widgets/custom_icons.dart';
import '../widgets/step_by_step_widget.dart';

class NavigationScreen extends StatefulWidget {
  final RouteModel? selectedRoute;
  final String? origen;
  final String? destino;

  const NavigationScreen({
    Key? key,
    this.selectedRoute,
    this.origen,
    this.destino,
  }) : super(key: key);

  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStream;
  Timer? _busUpdateTimer;
  
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<BusModel> _nearbyBuses = [];
  List<StopModel> _nearbyStops = [];
  
  int _currentStepIndex = 0;
  bool _isNavigationActive = false;
  bool _showStepByStep = false;
  bool _isLoading = true;

  // Configuración inicial del mapa centrado en Montevideo
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(ApiConstants.montevideoLat, ApiConstants.montevideoLng),
    zoom: 13.0,
  );

  @override
  void initState() {
    super.initState();
    _initializeNavigation();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _busUpdateTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializeNavigation() async {
    try {
      // Obtener ubicación actual
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _currentPosition = position;
        });
        
        // Centrar mapa en ubicación actual
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(position.latitude, position.longitude),
          ),
        );
      }

      // Cargar datos iniciales
      await _loadInitialData();
      
      // Iniciar actualizaciones en tiempo real
      _startLocationTracking();
      _startBusTracking();
      
    } catch (e) {
      print('Error inicializando navegación: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadInitialData() async {
    if (_currentPosition == null) return;

    try {
      // Cargar paradas cercanas
      final stops = await StmApiService.getNearbyStops(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        radiusKm: 1.0,
      );
      
      // Cargar buses cercanos
      final buses = await StmApiService.getNearbyBuses(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        radiusKm: 2.0,
      );

      setState(() {
        _nearbyStops = stops;
        _nearbyBuses = buses;
      });

      _updateMapMarkers();
      
      // Si hay una ruta seleccionada, dibujar la ruta
      if (widget.selectedRoute != null) {
        _drawRouteOnMap(widget.selectedRoute!);
      }
      
    } catch (e) {
      print('Error cargando datos iniciales: $e');
    }
  }

  void _startLocationTracking() {
    _positionStream = LocationService.getLocationStream().listen(
      (Position position) {
        setState(() {
          _currentPosition = position;
        });
        
        _updateUserLocationMarker();
        
        // Verificar progreso de navegación si está activa
        if (_isNavigationActive && widget.selectedRoute != null) {
          _checkNavigationProgress(position);
        }
      },
      onError: (error) {
        print('Error en stream de ubicación: $error');
      },
    );
  }

  void _startBusTracking() {
    _busUpdateTimer = Timer.periodic(Duration(seconds: 30), (timer) async {
      if (_currentPosition != null) {
        try {
          final buses = await StmApiService.getNearbyBuses(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            radiusKm: 2.0,
          );
          
          setState(() {
            _nearbyBuses = buses;
          });
          
          _updateBusMarkers();
        } catch (e) {
          print('Error actualizando buses: $e');
        }
      }
    });
  }

  void _updateMapMarkers() {
    Set<Marker> markers = {};

    // Marcador de ubicación actual
    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: MarkerId('current_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
            title: 'Tu ubicación',
            snippet: 'Ubicación actual',
          ),
        ),
      );
    }

    // Marcadores de paradas
    for (var stop in _nearbyStops) {
      markers.add(
        Marker(
          markerId: MarkerId('stop_${stop.id}'),
          position: LatLng(stop.latitud, stop.longitud),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: stop.nombre,
            snippet: 'Líneas: ${stop.lineasQueParanAqui.take(3).join(', ')}',
          ),
          onTap: () => _showStopDetails(stop),
        ),
      );
    }

    // Marcadores de buses
    _updateBusMarkers(markers);

    setState(() {
      _markers = markers;
    });
  }

  void _updateBusMarkers([Set<Marker>? existingMarkers]) {
    Set<Marker> markers = existingMarkers ?? Set.from(_markers);
    
    // Remover marcadores de buses anteriores
    markers.removeWhere((marker) => marker.markerId.value.startsWith('bus_'));

    // Agregar marcadores de buses actuales
    for (var bus in _nearbyBuses) {
      markers.add(
        Marker(
          markerId: MarkerId('bus_${bus.id}'),
          position: LatLng(bus.latitud, bus.longitud),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: 'Línea ${bus.linea}',
            snippet: '${bus.destino} • ${bus.tiempoArriboTexto}',
          ),
          rotation: 0, // En una implementación real, usar la dirección del bus
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  void _updateUserLocationMarker() {
    if (_currentPosition == null) return;

    setState(() {
      _markers.removeWhere((marker) => marker.markerId.value == 'current_location');
      _markers.add(
        Marker(
          markerId: MarkerId('current_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
            title: 'Tu ubicación',
            snippet: 'Ubicación actual',
          ),
        ),
      );
    });
  }

  void _drawRouteOnMap(RouteModel route) {
    List<LatLng> routePoints = [];
    
    // Agregar puntos de la ruta basados en los pasos
    for (var step in route.pasos) {
      routePoints.add(LatLng(step.startLat, step.startLng));
      routePoints.add(LatLng(step.endLat, step.endLng));
    }

    if (routePoints.isNotEmpty) {
      setState(() {
        _polylines.add(
          Polyline(
            polylineId: PolylineId('selected_route'),
            points: routePoints,
            color: Color(StyleConstants.primaryColor),
            width: 4,
            patterns: [],
          ),
        );
      });

      // Ajustar cámara para mostrar toda la ruta
      _fitCameraToRoute(routePoints);
    }
  }

  void _fitCameraToRoute(List<LatLng> points) {
    if (points.isEmpty || _mapController == null) return;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (var point in points) {
      minLat = math.min(minLat, point.latitude);
      maxLat = math.max(maxLat, point.latitude);
      minLng = math.min(minLng, point.longitude);
      maxLng = math.max(maxLng, point.longitude);
    }

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100.0, // padding
      ),
    );
  }

  void _checkNavigationProgress(Position position) {
    if (widget.selectedRoute == null || _currentStepIndex >= widget.selectedRoute!.pasos.length) {
      return;
    }

    final currentStep = widget.selectedRoute!.pasos[_currentStepIndex];
    final stepEndLocation = LatLng(currentStep.endLat, currentStep.endLng);
    
    final distance = LocationService.calculateDistance(
      position.latitude,
      position.longitude,
      stepEndLocation.latitude,
      stepEndLocation.longitude,
    );

    // Si está cerca del final del paso actual (menos de 50 metros)
    if (distance < 50) {
      setState(() {
        _currentStepIndex++;
      });
      
      // Si completó todos los pasos
      if (_currentStepIndex >= widget.selectedRoute!.pasos.length) {
        _showNavigationComplete();
      }
    }
  }

  void _showNavigationComplete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '¡Llegaste!',
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: StyleConstants.fontSizeLarge,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Has llegado a tu destino.',
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: StyleConstants.fontSizeSmall,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'Finalizar',
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: StyleConstants.fontSizeSmall,
                color: Color(StyleConstants.primaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStopDetails(StopModel stop) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(StyleConstants.spacingMedium),
        decoration: BoxDecoration(
          color: Color(StyleConstants.backgroundColor),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(StyleConstants.borderRadiusMedium),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                BusStopIcon(
                  size: 20,
                  color: Color(StyleConstants.primaryColor),
                  hasArrivals: stop.proximosArribos.isNotEmpty,
                ),
                SizedBox(width: StyleConstants.spacingSmall),
                Expanded(
                  child: Text(
                    stop.nombre,
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: StyleConstants.fontSizeLarge,
                      fontWeight: FontWeight.w600,
                      color: Color(StyleConstants.textPrimary),
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: StyleConstants.spacingMedium),
            
            if (stop.proximosArribos.isNotEmpty) ...[
              Text(
                AppConstants.proximosArribos,
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: StyleConstants.fontSizeMedium,
                  fontWeight: FontWeight.w600,
                  color: Color(StyleConstants.textPrimary),
                ),
              ),
              SizedBox(height: StyleConstants.spacingSmall),
              ...stop.proximosArribos.take(3).map((arribo) => 
                ArrivalCard(
                  linea: arribo.linea,
                  destino: arribo.destino,
                  tiempoMinutos: arribo.tiempoEstimadoMinutos,
                  estado: arribo.estado,
                ),
              ).toList(),
            ] else ...[
              Text(
                'No hay arribos programados',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: StyleConstants.fontSizeSmall,
                  color: Color(StyleConstants.textSecondary),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _toggleNavigation() {
    setState(() {
      _isNavigationActive = !_isNavigationActive;
      if (_isNavigationActive) {
        _currentStepIndex = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(StyleConstants.backgroundColor),
      body: Stack(
        children: [
          // Mapa principal
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            initialCameraPosition: _initialPosition,
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
            trafficEnabled: false,
            buildingsEnabled: true,
            onTap: (LatLng position) {
              setState(() {
                _showStepByStep = false;
              });
            },
          ),
          
          // Indicador de carga
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(StyleConstants.primaryColor),
                      ),
                    ),
                    SizedBox(height: StyleConstants.spacingMedium),
                    Text(
                      AppConstants.cargando,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: StyleConstants.fontSizeSmall,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Controles superiores
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(StyleConstants.spacingMedium),
              child: Column(
                children: [
                  // Botón de regreso y título
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Color(StyleConstants.backgroundColor),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: Color(StyleConstants.textPrimary),
                            size: 20,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      SizedBox(width: StyleConstants.spacingSmall),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: StyleConstants.spacingMedium,
                            vertical: StyleConstants.spacingSmall,
                          ),
                          decoration: BoxDecoration(
                            color: Color(StyleConstants.backgroundColor),
                            borderRadius: BorderRadius.circular(StyleConstants.borderRadiusMedium),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            AppConstants.modoNavegacion,
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: StyleConstants.fontSizeMedium,
                              fontWeight: FontWeight.w600,
                              color: Color(StyleConstants.textPrimary),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Indicador de paso actual (si hay navegación activa)
                  if (_isNavigationActive && 
                      widget.selectedRoute != null && 
                      _currentStepIndex < widget.selectedRoute!.pasos.length) ...[
                    SizedBox(height: StyleConstants.spacingMedium),
                    CurrentStepIndicator(
                      currentStep: widget.selectedRoute!.pasos[_currentStepIndex],
                      stepNumber: _currentStepIndex + 1,
                      totalSteps: widget.selectedRoute!.pasos.length,
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // Controles inferiores
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Botones de acción
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: StyleConstants.spacingMedium),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Botón de ubicación actual
                      FloatingActionButton(
                        mini: true,
                        heroTag: "location",
                        onPressed: () {
                          if (_currentPosition != null && _mapController != null) {
                            _mapController!.animateCamera(
                              CameraUpdate.newLatLng(
                                LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                              ),
                            );
                          }
                        },
                        backgroundColor: Color(StyleConstants.backgroundColor),
                        child: Icon(
                          Icons.my_location,
                          color: Color(StyleConstants.primaryColor),
                          size: 20,
                        ),
                      ),
                      
                      // Botón de navegación paso a paso
                      if (widget.selectedRoute != null)
                        FloatingActionButton(
                          mini: true,
                          heroTag: "steps",
                          onPressed: () {
                            setState(() {
                              _showStepByStep = !_showStepByStep;
                            });
                          },
                          backgroundColor: _showStepByStep 
                              ? Color(StyleConstants.primaryColor)
                              : Color(StyleConstants.backgroundColor),
                          child: Icon(
                            Icons.list,
                            color: _showStepByStep 
                                ? Colors.white
                                : Color(StyleConstants.primaryColor),
                            size: 20,
                          ),
                        ),
                    ],
                  ),
                ),
                
                SizedBox(height: StyleConstants.spacingMedium),
                
                // Botón principal de navegación
                if (widget.selectedRoute != null)
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: StyleConstants.spacingMedium),
                    child: ElevatedButton.icon(
                      onPressed: _toggleNavigation,
                      icon: Icon(
                        _isNavigationActive ? Icons.stop : Icons.play_arrow,
                        size: 18,
                      ),
                      label: Text(
                        _isNavigationActive ? 'Detener navegación' : 'Iniciar navegación',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: StyleConstants.fontSizeSmall,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isNavigationActive 
                            ? Color(StyleConstants.errorColor)
                            : Color(StyleConstants.primaryColor),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: StyleConstants.spacingMedium,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(StyleConstants.borderRadiusMedium),
                        ),
                      ),
                    ),
                  ),
                
                // Panel de pasos (si está activo)
                if (_showStepByStep && widget.selectedRoute != null)
                  StepByStepWidget(
                    steps: widget.selectedRoute!.pasos,
                    currentStepIndex: _currentStepIndex,
                    onNextStep: () {
                      if (_currentStepIndex < widget.selectedRoute!.pasos.length - 1) {
                        setState(() {
                          _currentStepIndex++;
                        });
                      }
                    },
                    onPreviousStep: () {
                      if (_currentStepIndex > 0) {
                        setState(() {
                          _currentStepIndex--;
                        });
                      }
                    },
                  ),
                
                SizedBox(height: StyleConstants.spacingMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Importar math para las funciones matemáticas
import 'dart:math' as math;
