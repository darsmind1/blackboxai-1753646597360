import 'package:flutter/material.dart';
import '../models/route_model.dart';
import '../utils/constants.dart';
import 'custom_icons.dart';

class RouteCard extends StatelessWidget {
  final RouteModel route;
  final VoidCallback onTap;
  final bool isSelected;

  const RouteCard({
    Key? key,
    required this.route,
    required this.onTap,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 3 : 1,
      margin: EdgeInsets.symmetric(
        horizontal: StyleConstants.spacingSmall,
        vertical: StyleConstants.spacingXSmall,
      ),
      color: isSelected 
          ? Color(StyleConstants.primaryColor).withOpacity(0.1)
          : Color(StyleConstants.surfaceColor),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(StyleConstants.borderRadiusMedium),
        child: Padding(
          padding: EdgeInsets.all(StyleConstants.spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila superior: Tiempo y líneas de bus
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tiempo total
                  Row(
                    children: [
                      TimeIcon(
                        size: 14,
                        color: Color(StyleConstants.primaryColor),
                        minutes: route.duracionMinutos,
                      ),
                      SizedBox(width: StyleConstants.spacingXSmall),
                      Text(
                        '${route.duracionMinutos} min',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: StyleConstants.fontSizeSmall,
                          fontWeight: FontWeight.w600,
                          color: Color(StyleConstants.primaryColor),
                        ),
                      ),
                    ],
                  ),
                  // Líneas de bus
                  Row(
                    children: route.lineasBus.take(3).map((linea) => 
                      Container(
                        margin: EdgeInsets.only(left: StyleConstants.spacingXSmall),
                        padding: EdgeInsets.symmetric(
                          horizontal: StyleConstants.spacingXSmall,
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
                  ),
                ],
              ),
              
              SizedBox(height: StyleConstants.spacingSmall),
              
              // Información de ruta
              Row(
                children: [
                  // Icono de origen
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Color(StyleConstants.accentColor),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: StyleConstants.spacingSmall),
                  Expanded(
                    child: Text(
                      _formatAddress(route.origen),
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
              
              // Línea de conexión
              Container(
                margin: EdgeInsets.only(left: 3.5),
                child: Column(
                  children: List.generate(3, (index) => 
                    Container(
                      width: 1,
                      height: 3,
                      margin: EdgeInsets.symmetric(vertical: 1),
                      color: Color(StyleConstants.textSecondary).withOpacity(0.5),
                    ),
                  ),
                ),
              ),
              
              Row(
                children: [
                  // Icono de destino
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Color(StyleConstants.errorColor),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: StyleConstants.spacingSmall),
                  Expanded(
                    child: Text(
                      _formatAddress(route.destino),
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
              
              SizedBox(height: StyleConstants.spacingSmall),
              
              // Fila inferior: Detalles adicionales
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Distancia y transbordos
                  Row(
                    children: [
                      WalkIcon(
                        size: 12,
                        color: Color(StyleConstants.textSecondary),
                      ),
                      SizedBox(width: StyleConstants.spacingXSmall),
                      Text(
                        '${route.distanciaKm.toStringAsFixed(1)} km',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: StyleConstants.fontSizeVerySmall,
                          color: Color(StyleConstants.textSecondary),
                        ),
                      ),
                      if (route.numeroTransbordos > 0) ...[
                        SizedBox(width: StyleConstants.spacingSmall),
                        Icon(
                          Icons.swap_horiz,
                          size: 12,
                          color: Color(StyleConstants.textSecondary),
                        ),
                        SizedBox(width: StyleConstants.spacingXSmall),
                        Text(
                          '${route.numeroTransbordos}',
                          style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: StyleConstants.fontSizeVerySmall,
                            color: Color(StyleConstants.textSecondary),
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  // Tiempo estimado de llegada
                  if (route.tiempoEstimadoLlegada.isNotEmpty)
                    Text(
                      route.tiempoEstimadoLlegada,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: StyleConstants.fontSizeVerySmall,
                        color: Color(StyleConstants.textSecondary),
                      ),
                    ),
                ],
              ),
              
              // Pasos de la ruta (mostrar solo los principales)
              if (route.pasos.isNotEmpty) ...[
                SizedBox(height: StyleConstants.spacingSmall),
                Container(
                  height: 1,
                  color: Color(StyleConstants.textSecondary).withOpacity(0.2),
                ),
                SizedBox(height: StyleConstants.spacingSmall),
                _buildRouteSteps(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteSteps() {
    final mainSteps = route.pasos.where((step) => 
      step.modoTransporte == 'TRANSIT' || 
      (step.modoTransporte == 'WALKING' && step.duracion.contains('min'))
    ).take(3).toList();

    return Column(
      children: mainSteps.map((step) => 
        Padding(
          padding: EdgeInsets.only(bottom: StyleConstants.spacingXSmall),
          child: Row(
            children: [
              // Icono según modo de transporte
              if (step.modoTransporte == 'TRANSIT')
                BusIcon(
                  size: 12,
                  color: Color(StyleConstants.primaryColor),
                )
              else
                WalkIcon(
                  size: 12,
                  color: Color(StyleConstants.textSecondary),
                ),
              
              SizedBox(width: StyleConstants.spacingSmall),
              
              // Información del paso
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (step.lineaBus != null)
                      Text(
                        'Línea ${step.lineaBus}',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: StyleConstants.fontSizeVerySmall,
                          fontWeight: FontWeight.w500,
                          color: Color(StyleConstants.textPrimary),
                        ),
                      ),
                    if (step.paradaInicio != null)
                      Text(
                        step.paradaInicio!,
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: StyleConstants.fontSizeVerySmall,
                          color: Color(StyleConstants.textSecondary),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              
              // Duración del paso
              Text(
                step.duracion,
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: StyleConstants.fontSizeVerySmall,
                  color: Color(StyleConstants.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ).toList(),
    );
  }

  String _formatAddress(String address) {
    // Simplificar dirección para mostrar solo lo esencial
    final parts = address.split(',');
    if (parts.length > 2) {
      return '${parts[0]}, ${parts[1]}';
    }
    return address;
  }
}

// Widget para mostrar próximos arribos en una parada
class ArrivalCard extends StatelessWidget {
  final String linea;
  final String destino;
  final int tiempoMinutos;
  final String estado;

  const ArrivalCard({
    Key? key,
    required this.linea,
    required this.destino,
    required this.tiempoMinutos,
    required this.estado,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: StyleConstants.spacingXSmall),
      padding: EdgeInsets.all(StyleConstants.spacingSmall),
      decoration: BoxDecoration(
        color: Color(StyleConstants.surfaceColor),
        borderRadius: BorderRadius.circular(StyleConstants.borderRadiusSmall),
        border: Border.all(
          color: Color(StyleConstants.textSecondary).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // Icono de bus
          BusIcon(
            size: 16,
            color: Color(StyleConstants.primaryColor),
            isMoving: estado == 'EN_RUTA',
          ),
          
          SizedBox(width: StyleConstants.spacingSmall),
          
          // Información de línea
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
              linea,
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: StyleConstants.fontSizeVerySmall,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          
          SizedBox(width: StyleConstants.spacingSmall),
          
          // Destino
          Expanded(
            child: Text(
              destino,
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: StyleConstants.fontSizeVerySmall,
                color: Color(StyleConstants.textPrimary),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Tiempo de arribo
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: StyleConstants.spacingSmall,
              vertical: StyleConstants.spacingXSmall,
            ),
            decoration: BoxDecoration(
              color: _getTimeColor(),
              borderRadius: BorderRadius.circular(StyleConstants.borderRadiusSmall),
            ),
            child: Text(
              _formatTime(),
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
    );
  }

  Color _getTimeColor() {
    if (tiempoMinutos <= 2) return Color(StyleConstants.errorColor);
    if (tiempoMinutos <= 5) return Colors.orange;
    return Color(StyleConstants.accentColor);
  }

  String _formatTime() {
    if (tiempoMinutos <= 0) return 'Ya';
    if (tiempoMinutos == 1) return '1m';
    return '${tiempoMinutos}m';
  }
}
