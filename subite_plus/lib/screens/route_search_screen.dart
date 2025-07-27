import 'package:flutter/material.dart';
import '../models/route_model.dart';
import '../services/directions_service.dart';
import '../services/location_service.dart';
import '../utils/constants.dart';
import '../widgets/custom_icons.dart';
import 'route_results_screen.dart';

class RouteSearchScreen extends StatefulWidget {
  @override
  _RouteSearchScreenState createState() => _RouteSearchScreenState();
}

class _RouteSearchScreenState extends State<RouteSearchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _origenController = TextEditingController();
  final _destinoController = TextEditingController();
  
  bool _isLoading = false;
  bool _useCurrentLocation = false;
  List<Map<String, dynamic>> _origenSuggestions = [];
  List<Map<String, dynamic>> _destinoSuggestions = [];
  bool _showOrigenSuggestions = false;
  bool _showDestinoSuggestions = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  @override
  void dispose() {
    _origenController.dispose();
    _destinoController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentLocation() async {
    try {
      final ubicacion = await LocationService.getCurrentLocationAsText();
      if (ubicacion != AppConstants.ubicacionActual) {
        setState(() {
          _origenController.text = ubicacion;
          _useCurrentLocation = true;
        });
      }
    } catch (e) {
      print('Error cargando ubicación actual: $e');
    }
  }

  Future<void> _searchPlaces(String query, bool isOrigen) async {
    if (query.length < 3) {
      setState(() {
        if (isOrigen) {
          _origenSuggestions = [];
          _showOrigenSuggestions = false;
        } else {
          _destinoSuggestions = [];
          _showDestinoSuggestions = false;
        }
      });
      return;
    }

    try {
      final suggestions = await DirectionsService.searchPlaces(query);
      setState(() {
        if (isOrigen) {
          _origenSuggestions = suggestions;
          _showOrigenSuggestions = suggestions.isNotEmpty;
        } else {
          _destinoSuggestions = suggestions;
          _showDestinoSuggestions = suggestions.isNotEmpty;
        }
      });
    } catch (e) {
      print('Error buscando lugares: $e');
    }
  }

  Future<void> _searchRoutes() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final origen = _origenController.text.trim();
      final destino = _destinoController.text.trim();

      // Validar que las direcciones estén en Montevideo
      final origenValid = await DirectionsService.validateAddressInMontevideo(origen);
      final destinoValid = await DirectionsService.validateAddressInMontevideo(destino);

      if (!origenValid || !destinoValid) {
        _showErrorDialog('Las direcciones deben estar dentro de Montevideo.');
        return;
      }

      // Buscar rutas
      final routes = await DirectionsService.getPublicTransitRoutes(
        origen: origen,
        destino: destino,
        departureTime: DateTime.now(),
        alternatives: true,
      );

      if (routes.isEmpty) {
        _showErrorDialog(AppConstants.noRutasEncontradas);
        return;
      }

      // Navegar a resultados
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RouteResultsScreen(
            routes: routes,
            origen: origen,
            destino: destino,
          ),
        ),
      );

    } catch (e) {
      _showErrorDialog(AppConstants.errorConexion);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Error',
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: StyleConstants.fontSizeMedium,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: StyleConstants.fontSizeSmall,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
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

  void _swapLocations() {
    final temp = _origenController.text;
    setState(() {
      _origenController.text = _destinoController.text;
      _destinoController.text = temp;
      _useCurrentLocation = false;
    });
  }

  void _useCurrentLocationAsOrigin() async {
    try {
      final ubicacion = await LocationService.getCurrentLocationAsText();
      setState(() {
        _origenController.text = ubicacion;
        _useCurrentLocation = true;
        _showOrigenSuggestions = false;
      });
    } catch (e) {
      _showErrorDialog('No se pudo obtener la ubicación actual');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(StyleConstants.backgroundColor),
      appBar: AppBar(
        title: Text(
          AppConstants.buscarRuta,
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: StyleConstants.fontSizeLarge,
            fontWeight: FontWeight.w600,
          ),
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
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(StyleConstants.spacingMedium),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Campos de búsqueda
                  _buildSearchFields(),
                  
                  SizedBox(height: StyleConstants.spacingLarge),
                  
                  // Opciones adicionales
                  _buildAdditionalOptions(),
                  
                  SizedBox(height: StyleConstants.spacingLarge),
                  
                  // Botón de búsqueda
                  _buildSearchButton(),
                  
                  SizedBox(height: StyleConstants.spacingMedium),
                  
                  // Sugerencias rápidas
                  _buildQuickSuggestions(),
                ],
              ),
            ),
          ),
          
          // Sugerencias de origen
          if (_showOrigenSuggestions)
            _buildSuggestionsList(_origenSuggestions, true),
          
          // Sugerencias de destino
          if (_showDestinoSuggestions)
            _buildSuggestionsList(_destinoSuggestions, false),
        ],
      ),
    );
  }

  Widget _buildSearchFields() {
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
        children: [
          // Campo origen
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
                child: TextFormField(
                  controller: _origenController,
                  decoration: InputDecoration(
                    labelText: AppConstants.origen,
                    hintText: 'Ingresa dirección de origen',
                    border: InputBorder.none,
                    suffixIcon: _useCurrentLocation
                        ? Icon(
                            Icons.my_location,
                            size: 18,
                            color: Color(StyleConstants.primaryColor),
                          )
                        : IconButton(
                            icon: Icon(
                              Icons.my_location,
                              size: 18,
                              color: Color(StyleConstants.textSecondary),
                            ),
                            onPressed: _useCurrentLocationAsOrigin,
                          ),
                  ),
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: StyleConstants.fontSizeSmall,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa una dirección de origen';
                    }
                    return null;
                  },
                  onChanged: (value) => _searchPlaces(value, true),
                  onTap: () {
                    setState(() {
                      _showDestinoSuggestions = false;
                    });
                  },
                ),
              ),
            ],
          ),
          
          SizedBox(height: StyleConstants.spacingMedium),
          
          // Línea divisoria con botón de intercambio
          Row(
            children: [
              SizedBox(width: 18), // Alinear con los círculos
              Expanded(
                child: Container(
                  height: 1,
                  color: Color(StyleConstants.textSecondary).withOpacity(0.3),
                ),
              ),
              IconButton(
                onPressed: _swapLocations,
                icon: Icon(
                  Icons.swap_vert,
                  color: Color(StyleConstants.primaryColor),
                  size: 20,
                ),
                padding: EdgeInsets.all(StyleConstants.spacingSmall),
                constraints: BoxConstraints(),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: Color(StyleConstants.textSecondary).withOpacity(0.3),
                ),
              ),
            ],
          ),
          
          SizedBox(height: StyleConstants.spacingMedium),
          
          // Campo destino
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
                child: TextFormField(
                  controller: _destinoController,
                  decoration: InputDecoration(
                    labelText: AppConstants.destino,
                    hintText: 'Ingresa dirección de destino',
                    border: InputBorder.none,
                  ),
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: StyleConstants.fontSizeSmall,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa una dirección de destino';
                    }
                    return null;
                  },
                  onChanged: (value) => _searchPlaces(value, false),
                  onTap: () {
                    setState(() {
                      _showOrigenSuggestions = false;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Opciones de búsqueda',
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: StyleConstants.fontSizeMedium,
            fontWeight: FontWeight.w600,
            color: Color(StyleConstants.textPrimary),
          ),
        ),
        
        SizedBox(height: StyleConstants.spacingSmall),
        
        Container(
          padding: EdgeInsets.all(StyleConstants.spacingMedium),
          decoration: BoxDecoration(
            color: Color(StyleConstants.surfaceColor),
            borderRadius: BorderRadius.circular(StyleConstants.borderRadiusMedium),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  TimeIcon(
                    size: 16,
                    color: Color(StyleConstants.primaryColor),
                  ),
                  SizedBox(width: StyleConstants.spacingSmall),
                  Text(
                    'Salir ahora',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: StyleConstants.fontSizeSmall,
                      color: Color(StyleConstants.textPrimary),
                    ),
                  ),
                  Spacer(),
                  Text(
                    DateTime.now().toString().substring(11, 16),
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: StyleConstants.fontSizeSmall,
                      color: Color(StyleConstants.textSecondary),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: StyleConstants.spacingSmall),
              
              Row(
                children: [
                  BusIcon(
                    size: 16,
                    color: Color(StyleConstants.primaryColor),
                  ),
                  SizedBox(width: StyleConstants.spacingSmall),
                  Text(
                    'Solo transporte público',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: StyleConstants.fontSizeSmall,
                      color: Color(StyleConstants.textPrimary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _searchRoutes,
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: StyleConstants.spacingSmall),
                  Text(
                    'Buscando...',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: StyleConstants.fontSizeSmall,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 18),
                  SizedBox(width: StyleConstants.spacingSmall),
                  Text(
                    AppConstants.buscarRuta,
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: StyleConstants.fontSizeSmall,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
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

  Widget _buildQuickSuggestions() {
    final suggestions = [
      'Terminal Tres Cruces',
      'Ciudad Vieja',
      'Pocitos',
      'Punta Carretas',
      'Montevideo Shopping',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Destinos populares',
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: StyleConstants.fontSizeMedium,
            fontWeight: FontWeight.w600,
            color: Color(StyleConstants.textPrimary),
          ),
        ),
        
        SizedBox(height: StyleConstants.spacingSmall),
        
        Wrap(
          spacing: StyleConstants.spacingSmall,
          runSpacing: StyleConstants.spacingSmall,
          children: suggestions.map((suggestion) => 
            GestureDetector(
              onTap: () {
                setState(() {
                  _destinoController.text = suggestion;
                  _showDestinoSuggestions = false;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: StyleConstants.spacingMedium,
                  vertical: StyleConstants.spacingSmall,
                ),
                decoration: BoxDecoration(
                  color: Color(StyleConstants.surfaceColor),
                  borderRadius: BorderRadius.circular(StyleConstants.borderRadiusMedium),
                  border: Border.all(
                    color: Color(StyleConstants.textSecondary).withOpacity(0.2),
                  ),
                ),
                child: Text(
                  suggestion,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: StyleConstants.fontSizeVerySmall,
                    color: Color(StyleConstants.textPrimary),
                  ),
                ),
              ),
            ),
          ).toList(),
        ),
      ],
    );
  }

  Widget _buildSuggestionsList(List<Map<String, dynamic>> suggestions, bool isOrigen) {
    return Positioned(
      top: isOrigen ? 140 : 220,
      left: StyleConstants.spacingMedium,
      right: StyleConstants.spacingMedium,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(StyleConstants.borderRadiusMedium),
        child: Container(
          constraints: BoxConstraints(maxHeight: 200),
          decoration: BoxDecoration(
            color: Color(StyleConstants.backgroundColor),
            borderRadius: BorderRadius.circular(StyleConstants.borderRadiusMedium),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final suggestion = suggestions[index];
              return ListTile(
                dense: true,
                leading: Icon(
                  Icons.location_on,
                  size: 16,
                  color: Color(StyleConstants.textSecondary),
                ),
                title: Text(
                  suggestion['description'] ?? '',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: StyleConstants.fontSizeSmall,
                    color: Color(StyleConstants.textPrimary),
                  ),
                ),
                onTap: () {
                  setState(() {
                    if (isOrigen) {
                      _origenController.text = suggestion['description'] ?? '';
                      _showOrigenSuggestions = false;
                      _useCurrentLocation = false;
                    } else {
                      _destinoController.text = suggestion['description'] ?? '';
                      _showDestinoSuggestions = false;
                    }
                  });
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
