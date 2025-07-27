import 'package:flutter/material.dart';
import '../models/route_model.dart';
import '../services/stm_api_service.dart';
import '../utils/constants.dart';
import '../widgets/custom_icons.dart';
import '../widgets/route_card.dart';
import 'navigation_screen.dart';

class RouteResultsScreen extends StatefulWidget {
  final List<RouteModel> routes;
  final String origen;
  final String destino;

  const RouteResultsScreen({
    Key? key,
    required this.routes,
    required this.origen,
    required this.destino,
  }) : super(key: key);

  @override
  _RouteResultsScreenState createState() => _RouteResultsScreenState();
}

class _RouteResultsScreenState extends State<RouteResultsScreen> {
  int _selectedRouteIndex = 0;
  bool _isLoadingRealTimeData = false;
  List<RouteModel> _routesWithRealTimeData = [];

  @override
  void initState() {
    super.initState();
    _routesWithRealTimeData = List.from(widget.routes);
    _loadRealTimeData();
  }

  Future<void> _loadRealTimeData() async {
    setState(() {
      _isLoadingRealTimeData = true;
    });

    try {
      // Enriquecer rutas con datos en tiempo real de STM
      for (int i = 0; i < _routesWithRealTimeData.length; i++) {
        final route = _routesWithRealTimeData[i];
        
        // Obtener información en tiempo real para cada línea de bus
        for (String linea in route.lineasBus) {
          try {
            final buses = await StmApiService.getBusesByLine(linea);
            final lineInfo = await StmApiService.getLineInfo(linea);
            
            // Actualizar información de la ruta con datos reales
            // (En una implementación real, aquí actualizarías los tiempos estimados)
            
          } catch (e) {
            print('Error obteniendo datos de línea $linea: $e');
          }
        }
      }
    } catch (e) {
      print('Error cargando datos en tiempo real: $e');
    } finally {
      setState(() {
        _isLoadingRealTimeData = false;
      });
    }
  }

  void _startNavigation(RouteModel route) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NavigationScreen(
          selectedRoute: route,
          origen: widget.origen,
          destino: widget.destino,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(StyleConstants.backgroundColor),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppConstants.opcionesTrayecto,
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: StyleConstants.fontSizeLarge,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${_routesWithRealTimeData.length} opciones encontradas',
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: StyleConstants.fontSizeVerySmall,
                color: Color(StyleConstants.textSecondary),
              ),
            ),
          ],
        ),
        backgroundColor: Color(StyleConstants.backgroundColor),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color(StyleConstants.textPrimary),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Color(StyleConstants.primaryColor),
              size: 20,
            ),
            onPressed: _loadRealTimeData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Información de origen y destino
          _buildRouteHeader(),
          
          // Lista de rutas
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadRealTimeData,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: StyleConstants.spacingMedium,
                  vertical: StyleConstants.spacingSmall,
                ),
                itemCount: _routesWithRealTimeData.length,
                itemBuilder: (context, index) {
                  final route = _routesWithRealTimeData[index];
                  return RouteCard(
                    route: route,
                    isSelected: index == _selectedRouteIndex,
                    onTap: () {
                      setState(() {
                        _selectedRouteIndex = index;
                      });
                      _showRouteDetails(route);
                    },
                  );
                },
              ),
            ),
          ),
          
          // Botón de navegación
          _buildNavigationButton(),
        ],
      ),
    );
  }

  Widget _buildRouteHeader() {
    return Container(
      margin: EdgeInsets.all(StyleConstants.spacingMedium),
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
        children: [
          // Origen
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Color(StyleConstants.accentColor),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: StyleConstants.spacingSmall),
              Expanded(
                child: Text(
                  widget.origen,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: StyleConstants.fontSizeSmall,
                    fontWeight: FontWeight.w500,
                    color: Color(StyleConstants.textPrimary),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          // Línea de conexión
          Container(
            margin: EdgeInsets.only(left: 5.5, top: 4, bottom: 4),
            child: Column(
              children: List.generate(3, (index) => 
                Container(
                  width: 1,
                  height: 4,
                  margin: EdgeInsets.symmetric(vertical: 1),
                  color: Color(StyleConstants.textSecondary).withOpacity(0.5),
                ),
              ),
            ),
          ),
          
          // Destino
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Color(StyleConstants.errorColor),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: StyleConstants.spacingSmall),
              Expanded(
                child: Text(
                  widget.destino,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: StyleConstants.fontSizeSmall,
                    fontWeight: FontWeight.w500,
                    color: Color(StyleConstants.textPrimary),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          // Indicador de datos en tiempo real
          if (_isLoadingRealTimeData) ...[
            SizedBox(height: StyleConstants.spacingSmall),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(StyleConstants.primaryColor),
                    ),
                  ),
                ),
                SizedBox(width: StyleConstants.spacingSmall),
                Text(
                  'Actualizando datos en tiempo real...',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: StyleConstants.fontSizeVerySmall,
                    color: Color(StyleConstants.textSecondary),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavigationButton() {
    if (_routesWithRealTimeData.isEmpty) return SizedBox.shrink();

    final selectedRoute = _routesWithRealTimeData[_selectedRouteIndex];

    return Container(
      padding: EdgeInsets.all(StyleConstants.spacingMedium),
      decoration: BoxDecoration(
        color: Color(StyleConstants.backgroundColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Resumen de la ruta seleccionada
          Container(
            padding: EdgeInsets.all(StyleConstants.spacingSmall),
            decoration: BoxDecoration(
              color: Color(StyleConstants.primaryColor).withOpacity(0.1),
              borderRadius: BorderRadius.circular(StyleConstants.borderRadiusSmall),
            ),
            child: Row(
              children: [
                TimeIcon(
                  size: 16,
                  color: Color(StyleConstants.primaryColor),
                  minutes: selectedRoute.duracionMinutos,
                ),
                SizedBox(width: StyleConstants.spacingSmall),
                Text(
                  '${selectedRoute.duracionMinutos} min',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: StyleConstants.fontSizeSmall,
                    fontWeight: FontWeight.w600,
                    color: Color(StyleConstants.primaryColor),
                  ),
                ),
                SizedBox(width: StyleConstants.spacingMedium),
                ...selectedRoute.lineasBus.take(3).map((linea) => 
                  Container(
                    margin: EdgeInsets.only(right: StyleConstants.spacingXSmall),
                    padding: EdgeInsets.symmetric(
                      horizontal: StyleConstants.spacingSmall,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Color(StyleConstants.primaryColor),
                      borderRadius: BorderRadius.circular(StyleConstants.borderRadiusSmall),
                    ),
                    child: Text(
                      linea,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: StyleConstants.fontSizeVerySmall,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ).toList(),
                Spacer(),
                if (selectedRoute.numeroTransbordos > 0)
                  Row(
                    children: [
                      Icon(
                        Icons.swap_horiz,
                        size: 14,
                        color: Color(StyleConstants.textSecondary),
                      ),
                      SizedBox(width: StyleConstants.spacingXSmall),
                      Text(
                        '${selectedRoute.numeroTransbordos}',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: StyleConstants.fontSizeVerySmall,
                          color: Color(StyleConstants.textSecondary),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          
          SizedBox(height: StyleConstants.spacingMedium),
          
          // Botón de navegación
          Container(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _startNavigation(selectedRoute),
              icon: NavigationIcon(
                size: 18,
                color: Colors.white,
              ),
              label: Text(
                AppConstants.modoNavegacion,
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: StyleConstants.fontSizeMedium,
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
          ),
        ],
      ),
    );
  }

  void _showRouteDetails(RouteModel route) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Color(StyleConstants.backgroundColor),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(StyleConstants.borderRadiusMedium),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.symmetric(vertical: StyleConstants.spacingSmall),
                decoration: BoxDecoration(
                  color: Color(StyleConstants.textSecondary).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Título
              Padding(
                padding: EdgeInsets.symmetric(horizontal: StyleConstants.spacingMedium),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppConstants.detallesViaje,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: StyleConstants.fontSizeLarge,
                        fontWeight: FontWeight.w600,
                        color: Color(StyleConstants.textPrimary),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _startNavigation(route);
                      },
                      child: Text(
                        'Iniciar',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: StyleConstants.fontSizeSmall,
                          color: Color(StyleConstants.primaryColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Detalles de la ruta
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: StyleConstants.spacingMedium),
                  children: [
                    // Resumen
                    _buildRouteSummary(route),
                    
                    SizedBox(height: StyleConstants.spacingMedium),
                    
                    // Pasos detallados
                    _buildDetailedSteps(route),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteSummary(RouteModel route) {
    return Container(
      padding: EdgeInsets.all(StyleConstants.spacingMedium),
      decoration: BoxDecoration(
        color: Color(StyleConstants.surfaceColor),
        borderRadius: BorderRadius.circular(StyleConstants.borderRadiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Duración total',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: StyleConstants.fontSizeVerySmall,
                      color: Color(StyleConstants.textSecondary),
                    ),
                  ),
                  Text(
                    '${route.duracionMinutos} min',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: StyleConstants.fontSizeLarge,
                      fontWeight: FontWeight.w600,
                      color: Color(StyleConstants.primaryColor),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Distancia',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: StyleConstants.fontSizeVerySmall,
                      color: Color(StyleConstants.textSecondary),
                    ),
                  ),
                  Text(
                    '${route.distanciaKm.toStringAsFixed(1)} km',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: StyleConstants.fontSizeMedium,
                      fontWeight: FontWeight.w500,
                      color: Color(StyleConstants.textPrimary),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          if (route.numeroTransbordos > 0) ...[
            SizedBox(height: StyleConstants.spacingSmall),
            Row(
              children: [
                Icon(
                  Icons.swap_horiz,
                  size: 16,
                  color: Color(StyleConstants.textSecondary),
                ),
                SizedBox(width: StyleConstants.spacingXSmall),
                Text(
                  '${route.numeroTransbordos} transbordo${route.numeroTransbordos > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: StyleConstants.fontSizeSmall,
                    color: Color(StyleConstants.textSecondary),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailedSteps(RouteModel route) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pasos del viaje',
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: StyleConstants.fontSizeMedium,
            fontWeight: FontWeight.w600,
            color: Color(StyleConstants.textPrimary),
          ),
        ),
        
        SizedBox(height: StyleConstants.spacingSmall),
        
        ...route.pasos.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isLast = index == route.pasos.length - 1;
          
          return Container(
            margin: EdgeInsets.only(bottom: StyleConstants.spacingSmall),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Indicador de paso
                Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Color(StyleConstants.primaryColor),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: _getStepIcon(step),
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 40,
                        color: Color(StyleConstants.textSecondary).withOpacity(0.2),
                      ),
                  ],
                ),
                
                SizedBox(width: StyleConstants.spacingSmall),
                
                // Contenido del paso
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (step.lineaBus != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: StyleConstants.spacingSmall,
                            vertical: StyleConstants.spacingXSmall,
                          ),
                          decoration: BoxDecoration(
                            color: Color(StyleConstants.primaryColor),
                            borderRadius: BorderRadius.circular(StyleConstants.borderRadiusSmall),
                          ),
                          child: Text(
                            'Línea ${step.lineaBus}',
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: StyleConstants.fontSizeVerySmall,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      
                      SizedBox(height: StyleConstants.spacingXSmall),
                      
                      Text(
                        _getStepDescription(step),
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: StyleConstants.fontSizeSmall,
                          color: Color(StyleConstants.textPrimary),
                        ),
                      ),
                      
                      Text(
                        '${step.duracion} • ${step.distancia}',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: StyleConstants.fontSizeVerySmall,
                          color: Color(StyleConstants.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _getStepIcon(StepModel step) {
    switch (step.modoTransporte) {
      case 'TRANSIT':
        return BusIcon(
          size: 12,
          color: Colors.white,
        );
      case 'WALKING':
        return WalkIcon(
          size: 12,
          color: Colors.white,
        );
      default:
        return NavigationIcon(
          size: 12,
          color: Colors.white,
        );
    }
  }

  String _getStepDescription(StepModel step) {
    if (step.modoTransporte == 'TRANSIT') {
      String desc = '';
      if (step.paradaInicio != null) {
        desc += 'Subir en ${step.paradaInicio}';
      }
      if (step.paradaFin != null) {
        if (desc.isNotEmpty) desc += ' y ';
        desc += 'bajar en ${step.paradaFin}';
      }
      return desc.isNotEmpty ? desc : 'Viaje en bus';
    } else {
      return step.instruccion.replaceAll(RegExp(r'<[^>]*>'), '');
    }
  }
}
