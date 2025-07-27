import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bus_model.dart';
import '../services/stm_api_service.dart';
import '../services/location_service.dart';
import '../utils/constants.dart';
import '../widgets/custom_icons.dart';
import '../widgets/route_card.dart';
import 'route_search_screen.dart';
import 'navigation_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<BusArrivalModel> _proximosArribos = [];
  List<StopModel> _paradasCercanas = [];
  bool _isLoading = false;
  String? _ubicacionActual;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // Obtener ubicación actual
      final ubicacion = await LocationService.getCurrentLocationAsText();
      setState(() {
        _ubicacionActual = ubicacion;
      });

      // Obtener posición para buscar paradas cercanas
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        await _loadNearbyData(position.latitude, position.longitude);
      }
    } catch (e) {
      setState(() {
        _error = AppConstants.errorConexion;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadNearbyData(double lat, double lng) async {
    try {
      // Cargar paradas cercanas
      final paradas = await StmApiService.getNearbyStops(lat, lng);
      setState(() {
        _paradasCercanas = paradas;
      });

      // Cargar próximos arribos de las paradas cercanas
      List<BusArrivalModel> arribos = [];
      for (var parada in paradas.take(3)) {
        final paradaArribos = await StmApiService.getUpcomingArrivals(parada.id);
        arribos.addAll(paradaArribos.take(2));
      }

      // Ordenar por tiempo de arribo
      arribos.sort((a, b) => a.tiempoEstimadoMinutos.compareTo(b.tiempoEstimadoMinutos));

      setState(() {
        _proximosArribos = arribos.take(5).toList();
      });
    } catch (e) {
      print('Error cargando datos cercanos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(StyleConstants.backgroundColor),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _initializeLocation,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(StyleConstants.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con logo y título
                _buildHeader(),
                
                SizedBox(height: StyleConstants.spacingLarge),
                
                // Búsqueda principal
                _buildSearchSection(),
                
                SizedBox(height: StyleConstants.spacingLarge),
                
                // Botón modo navegación
                _buildNavigationModeButton(),
                
                SizedBox(height: StyleConstants.spacingLarge),
                
                // Próximos arribos
                if (_proximosArribos.isNotEmpty) ...[
                  _buildProximosArribos(),
                  SizedBox(height: StyleConstants.spacingLarge),
                ],
                
                // Paradas cercanas
                if (_paradasCercanas.isNotEmpty) ...[
                  _buildParadasCercanas(),
                ],
                
                // Error message
                if (_error.isNotEmpty) ...[
                  _buildErrorMessage(),
                ],
                
                // Loading indicator
                if (_isLoading) ...[
                  _buildLoadingIndicator(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            BusIcon(
              size: 28,
              color: Color(StyleConstants.primaryColor),
            ),
            SizedBox(width: StyleConstants.spacingSmall),
            Text(
              AppConstants.appName,
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: StyleConstants.fontSizeLarge + 4,
                fontWeight: FontWeight.w700,
                color: Color(StyleConstants.primaryColor),
              ),
            ),
          ],
        ),
        
        SizedBox(height: StyleConstants.spacingSmall),
        
        if (_ubicacionActual != null)
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 14,
                color: Color(StyleConstants.textSecondary),
              ),
              SizedBox(width: StyleConstants.spacingXSmall),
              Expanded(
                child: Text(
                  _ubicacionActual!,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: StyleConstants.fontSizeVerySmall,
                    color: Color(StyleConstants.textSecondary),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: EdgeInsets.all(StyleConstants.spacingMedium),
      decoration: BoxDecoration(
        color: Color(StyleConstants.surfaceColor),
        borderRadius: BorderRadius.circular(StyleConstants.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Planifica tu viaje',
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: StyleConstants.fontSizeMedium,
              fontWeight: FontWeight.w600,
              color: Color(StyleConstants.textPrimary),
            ),
          ),
          
          SizedBox(height: StyleConstants.spacingMedium),
          
          // Campo de búsqueda
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RouteSearchScreen(),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.all(StyleConstants.spacingMedium),
              decoration: BoxDecoration(
                color: Color(StyleConstants.backgroundColor),
                borderRadius: BorderRadius.circular(StyleConstants.borderRadiusMedium),
                border: Border.all(
                  color: Color(StyleConstants.textSecondary).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    size: 20,
                    color: Color(StyleConstants.textSecondary),
                  ),
                  SizedBox(width: StyleConstants.spacingSmall),
                  Expanded(
                    child: Text(
                      AppConstants.buscarRuta,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: StyleConstants.fontSizeSmall,
                        color: Color(StyleConstants.textSecondary),
                      ),
                    ),
                  ),
                  NavigationIcon(
                    size: 16,
                    color: Color(StyleConstants.primaryColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationModeButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NavigationScreen(),
            ),
          );
        },
        icon: NavigationIcon(
          size: 18,
          color: Colors.white,
        ),
        label: Text(
          AppConstants.modoNavegacion,
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: StyleConstants.fontSizeSmall,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(StyleConstants.primaryColor),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            vertical: StyleConstants.spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(StyleConstants.borderRadiusMedium),
          ),
        ),
      ),
    );
  }

  Widget _buildProximosArribos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppConstants.proximosArribos,
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: StyleConstants.fontSizeMedium,
                fontWeight: FontWeight.w600,
                color: Color(StyleConstants.textPrimary),
              ),
            ),
            TextButton(
              onPressed: _initializeLocation,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.refresh,
                    size: 14,
                    color: Color(StyleConstants.primaryColor),
                  ),
                  SizedBox(width: StyleConstants.spacingXSmall),
                  Text(
                    'Actualizar',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: StyleConstants.fontSizeVerySmall,
                      color: Color(StyleConstants.primaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        SizedBox(height: StyleConstants.spacingSmall),
        
        ...(_proximosArribos.map((arribo) => ArrivalCard(
          linea: arribo.linea,
          destino: arribo.destino,
          tiempoMinutos: arribo.tiempoEstimadoMinutos,
          estado: arribo.estado,
        )).toList()),
      ],
    );
  }

  Widget _buildParadasCercanas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Paradas cercanas',
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: StyleConstants.fontSizeMedium,
            fontWeight: FontWeight.w600,
            color: Color(StyleConstants.textPrimary),
          ),
        ),
        
        SizedBox(height: StyleConstants.spacingSmall),
        
        ...(_paradasCercanas.take(3).map((parada) => 
          Container(
            margin: EdgeInsets.only(bottom: StyleConstants.spacingSmall),
            padding: EdgeInsets.all(StyleConstants.spacingMedium),
            decoration: BoxDecoration(
              color: Color(StyleConstants.surfaceColor),
              borderRadius: BorderRadius.circular(StyleConstants.borderRadiusMedium),
            ),
            child: Row(
              children: [
                BusStopIcon(
                  size: 18,
                  color: Color(StyleConstants.primaryColor),
                  hasArrivals: parada.proximosArribos.isNotEmpty,
                ),
                SizedBox(width: StyleConstants.spacingSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        parada.nombre,
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: StyleConstants.fontSizeSmall,
                          fontWeight: FontWeight.w500,
                          color: Color(StyleConstants.textPrimary),
                        ),
                      ),
                      if (parada.lineasQueParanAqui.isNotEmpty)
                        Text(
                          'Líneas: ${parada.lineasQueParanAqui.take(3).join(', ')}',
                          style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: StyleConstants.fontSizeVerySmall,
                            color: Color(StyleConstants.textSecondary),
                          ),
                        ),
                    ],
                  ),
                ),
                if (parada.proximosArribos.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: StyleConstants.spacingSmall,
                      vertical: StyleConstants.spacingXSmall,
                    ),
                    decoration: BoxDecoration(
                      color: Color(StyleConstants.accentColor),
                      borderRadius: BorderRadius.circular(StyleConstants.borderRadiusSmall),
                    ),
                    child: Text(
                      '${parada.proximosArribos.first.tiempoEstimadoMinutos}m',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: StyleConstants.fontSizeVerySmall,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ).toList()),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: EdgeInsets.all(StyleConstants.spacingMedium),
      decoration: BoxDecoration(
        color: Color(StyleConstants.errorColor).withOpacity(0.1),
        borderRadius: BorderRadius.circular(StyleConstants.borderRadiusMedium),
        border: Border.all(
          color: Color(StyleConstants.errorColor).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: 20,
            color: Color(StyleConstants.errorColor),
          ),
          SizedBox(width: StyleConstants.spacingSmall),
          Expanded(
            child: Text(
              _error,
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: StyleConstants.fontSizeSmall,
                color: Color(StyleConstants.errorColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Color(StyleConstants.primaryColor),
            ),
            strokeWidth: 2,
          ),
          SizedBox(height: StyleConstants.spacingSmall),
          Text(
            AppConstants.cargando,
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: StyleConstants.fontSizeSmall,
              color: Color(StyleConstants.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
