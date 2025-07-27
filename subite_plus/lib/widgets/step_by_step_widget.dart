import 'package:flutter/material.dart';
import '../models/route_model.dart';
import '../utils/constants.dart';
import 'custom_icons.dart';

class StepByStepWidget extends StatelessWidget {
  final List<StepModel> steps;
  final int currentStepIndex;
  final VoidCallback? onNextStep;
  final VoidCallback? onPreviousStep;

  const StepByStepWidget({
    Key? key,
    required this.steps,
    this.currentStepIndex = 0,
    this.onNextStep,
    this.onPreviousStep,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) {
      return Container(
        padding: EdgeInsets.all(StyleConstants.spacingMedium),
        child: Text(
          'No hay indicaciones disponibles',
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: StyleConstants.fontSizeSmall,
            color: Color(StyleConstants.textSecondary),
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Color(StyleConstants.backgroundColor),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(StyleConstants.borderRadiusMedium),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
                  AppConstants.indicacionesPaso,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: StyleConstants.fontSizeMedium,
                    fontWeight: FontWeight.w600,
                    color: Color(StyleConstants.textPrimary),
                  ),
                ),
                Text(
                  '${currentStepIndex + 1}/${steps.length}',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: StyleConstants.fontSizeSmall,
                    color: Color(StyleConstants.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: StyleConstants.spacingMedium),
          
          // Paso actual destacado
          if (currentStepIndex < steps.length)
            _buildCurrentStep(steps[currentStepIndex]),
          
          SizedBox(height: StyleConstants.spacingSmall),
          
          // Lista de pasos
          Container(
            height: 200,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: StyleConstants.spacingMedium),
              itemCount: steps.length,
              itemBuilder: (context, index) {
                return _buildStepItem(
                  steps[index], 
                  index, 
                  index == currentStepIndex,
                  index < currentStepIndex,
                );
              },
            ),
          ),
          
          // Controles de navegación
          _buildNavigationControls(),
          
          SizedBox(height: StyleConstants.spacingMedium),
        ],
      ),
    );
  }

  Widget _buildCurrentStep(StepModel step) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: StyleConstants.spacingMedium),
      padding: EdgeInsets.all(StyleConstants.spacingMedium),
      decoration: BoxDecoration(
        color: Color(StyleConstants.primaryColor).withOpacity(0.1),
        borderRadius: BorderRadius.circular(StyleConstants.borderRadiusMedium),
        border: Border.all(
          color: Color(StyleConstants.primaryColor).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _getStepIcon(step, true),
              SizedBox(width: StyleConstants.spacingSmall),
              Expanded(
                child: Text(
                  _getStepTitle(step),
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: StyleConstants.fontSizeMedium,
                    fontWeight: FontWeight.w600,
                    color: Color(StyleConstants.primaryColor),
                  ),
                ),
              ),
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
                  step.duracion,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: StyleConstants.fontSizeVerySmall,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: StyleConstants.spacingSmall),
          
          Text(
            _cleanInstruction(step.instruccion),
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: StyleConstants.fontSizeSmall,
              color: Color(StyleConstants.textPrimary),
            ),
          ),
          
          if (step.paradaInicio != null || step.paradaFin != null) ...[
            SizedBox(height: StyleConstants.spacingSmall),
            _buildStopInfo(step),
          ],
        ],
      ),
    );
  }

  Widget _buildStepItem(StepModel step, int index, bool isCurrent, bool isCompleted) {
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
                  color: isCurrent 
                      ? Color(StyleConstants.primaryColor)
                      : isCompleted 
                          ? Color(StyleConstants.accentColor)
                          : Color(StyleConstants.surfaceColor),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCurrent || isCompleted
                        ? Colors.transparent
                        : Color(StyleConstants.textSecondary).withOpacity(0.3),
                  ),
                ),
                child: Center(
                  child: isCompleted
                      ? Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.white,
                        )
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: StyleConstants.fontSizeVerySmall,
                            fontWeight: FontWeight.w600,
                            color: isCurrent ? Colors.white : Color(StyleConstants.textSecondary),
                          ),
                        ),
                ),
              ),
              if (index < steps.length - 1)
                Container(
                  width: 2,
                  height: 30,
                  color: isCompleted 
                      ? Color(StyleConstants.accentColor)
                      : Color(StyleConstants.textSecondary).withOpacity(0.2),
                ),
            ],
          ),
          
          SizedBox(width: StyleConstants.spacingSmall),
          
          // Contenido del paso
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _getStepIcon(step, isCurrent),
                    SizedBox(width: StyleConstants.spacingXSmall),
                    Expanded(
                      child: Text(
                        _getStepTitle(step),
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: StyleConstants.fontSizeSmall,
                          fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                          color: isCurrent 
                              ? Color(StyleConstants.primaryColor)
                              : isCompleted
                                  ? Color(StyleConstants.textSecondary)
                                  : Color(StyleConstants.textPrimary),
                        ),
                      ),
                    ),
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
                
                if (step.paradaInicio != null && step.modoTransporte == 'TRANSIT')
                  Padding(
                    padding: EdgeInsets.only(
                      top: StyleConstants.spacingXSmall,
                      left: 20,
                    ),
                    child: Text(
                      'Desde: ${step.paradaInicio}',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: StyleConstants.fontSizeVerySmall,
                        color: Color(StyleConstants.textSecondary),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStopInfo(StepModel step) {
    return Container(
      padding: EdgeInsets.all(StyleConstants.spacingSmall),
      decoration: BoxDecoration(
        color: Color(StyleConstants.surfaceColor),
        borderRadius: BorderRadius.circular(StyleConstants.borderRadiusSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (step.paradaInicio != null)
            Row(
              children: [
                BusStopIcon(
                  size: 12,
                  color: Color(StyleConstants.accentColor),
                ),
                SizedBox(width: StyleConstants.spacingXSmall),
                Expanded(
                  child: Text(
                    'Subir en: ${step.paradaInicio}',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: StyleConstants.fontSizeVerySmall,
                      color: Color(StyleConstants.textPrimary),
                    ),
                  ),
                ),
              ],
            ),
          
          if (step.paradaFin != null) ...[
            if (step.paradaInicio != null) SizedBox(height: StyleConstants.spacingXSmall),
            Row(
              children: [
                BusStopIcon(
                  size: 12,
                  color: Color(StyleConstants.errorColor),
                ),
                SizedBox(width: StyleConstants.spacingXSmall),
                Expanded(
                  child: Text(
                    'Bajar en: ${step.paradaFin}',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: StyleConstants.fontSizeVerySmall,
                      color: Color(StyleConstants.textPrimary),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavigationControls() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: StyleConstants.spacingMedium),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botón anterior
          TextButton.icon(
            onPressed: currentStepIndex > 0 ? onPreviousStep : null,
            icon: Icon(
              Icons.arrow_back_ios,
              size: 14,
              color: currentStepIndex > 0 
                  ? Color(StyleConstants.primaryColor)
                  : Color(StyleConstants.textSecondary).withOpacity(0.5),
            ),
            label: Text(
              'Anterior',
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: StyleConstants.fontSizeSmall,
                color: currentStepIndex > 0 
                    ? Color(StyleConstants.primaryColor)
                    : Color(StyleConstants.textSecondary).withOpacity(0.5),
              ),
            ),
          ),
          
          // Botón siguiente
          TextButton.icon(
            onPressed: currentStepIndex < steps.length - 1 ? onNextStep : null,
            label: Text(
              'Siguiente',
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: StyleConstants.fontSizeSmall,
                color: currentStepIndex < steps.length - 1 
                    ? Color(StyleConstants.primaryColor)
                    : Color(StyleConstants.textSecondary).withOpacity(0.5),
              ),
            ),
            icon: Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: currentStepIndex < steps.length - 1 
                  ? Color(StyleConstants.primaryColor)
                  : Color(StyleConstants.textSecondary).withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getStepIcon(StepModel step, bool isActive) {
    final color = isActive 
        ? Color(StyleConstants.primaryColor)
        : Color(StyleConstants.textSecondary);

    switch (step.modoTransporte) {
      case 'TRANSIT':
        return BusIcon(
          size: 16,
          color: color,
          isMoving: isActive,
        );
      case 'WALKING':
        return WalkIcon(
          size: 16,
          color: color,
        );
      default:
        return NavigationIcon(
          size: 16,
          color: color,
        );
    }
  }

  String _getStepTitle(StepModel step) {
    if (step.modoTransporte == 'TRANSIT' && step.lineaBus != null) {
      return 'Tomar línea ${step.lineaBus}';
    } else if (step.modoTransporte == 'WALKING') {
      return 'Caminar ${step.distancia}';
    } else {
      return 'Continuar';
    }
  }

  String _cleanInstruction(String instruction) {
    // Limpiar HTML tags y formatear para mejor legibilidad
    return instruction
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('<', '<')
        .replaceAll('>', '>')
        .trim();
  }
}

// Widget compacto para mostrar el paso actual en la parte superior del mapa
class CurrentStepIndicator extends StatelessWidget {
  final StepModel currentStep;
  final int stepNumber;
  final int totalSteps;

  const CurrentStepIndicator({
    Key? key,
    required this.currentStep,
    required this.stepNumber,
    required this.totalSteps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(StyleConstants.spacingMedium),
      padding: EdgeInsets.all(StyleConstants.spacingMedium),
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
      child: Row(
        children: [
          _getStepIcon(),
          SizedBox(width: StyleConstants.spacingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStepTitle(),
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: StyleConstants.fontSizeSmall,
                    fontWeight: FontWeight.w600,
                    color: Color(StyleConstants.textPrimary),
                  ),
                ),
                Text(
                  '${currentStep.duracion} • Paso $stepNumber de $totalSteps',
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
  }

  Widget _getStepIcon() {
    switch (currentStep.modoTransporte) {
      case 'TRANSIT':
        return BusIcon(
          size: 20,
          color: Color(StyleConstants.primaryColor),
          isMoving: true,
        );
      case 'WALKING':
        return WalkIcon(
          size: 20,
          color: Color(StyleConstants.primaryColor),
        );
      default:
        return NavigationIcon(
          size: 20,
          color: Color(StyleConstants.primaryColor),
        );
    }
  }

  String _getStepTitle() {
    if (currentStep.modoTransporte == 'TRANSIT' && currentStep.lineaBus != null) {
      return 'Línea ${currentStep.lineaBus}';
    } else if (currentStep.modoTransporte == 'WALKING') {
      return 'Caminar ${currentStep.distancia}';
    } else {
      return 'Continuar';
    }
  }
}
