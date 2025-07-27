import 'package:flutter/material.dart';
import '../utils/constants.dart';

// Widget para icono de bus personalizado
class BusIcon extends StatelessWidget {
  final double size;
  final Color color;
  final bool isMoving;

  const BusIcon({
    Key? key,
    this.size = 20.0,
    this.color = const Color(StyleConstants.primaryColor),
    this.isMoving = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: BusIconPainter(color: color, isMoving: isMoving),
    );
  }
}

class BusIconPainter extends CustomPainter {
  final Color color;
  final bool isMoving;

  BusIconPainter({required this.color, required this.isMoving});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Cuerpo principal del bus
    final busBody = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.1, size.height * 0.2, size.width * 0.8, size.height * 0.6),
      Radius.circular(size.width * 0.05),
    );
    canvas.drawRRect(busBody, paint);

    // Ventanas
    final windowPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Ventana frontal
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.15, size.height * 0.3, size.width * 0.15, size.height * 0.25),
      windowPaint,
    );

    // Ventanas laterales
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.35, size.height * 0.3, size.width * 0.12, size.height * 0.25),
      windowPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.52, size.height * 0.3, size.width * 0.12, size.height * 0.25),
      windowPaint,
    );

    // Ruedas
    final wheelPaint = Paint()
      ..color = Color(StyleConstants.textPrimary)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.25, size.height * 0.85),
      size.width * 0.08,
      wheelPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.75, size.height * 0.85),
      size.width * 0.08,
      wheelPaint,
    );

    // Puerta (si está en movimiento, mostrar abierta)
    if (isMoving) {
      canvas.drawRect(
        Rect.fromLTWH(size.width * 0.68, size.height * 0.45, size.width * 0.08, size.height * 0.35),
        Paint()..color = Color(StyleConstants.textSecondary),
      );
    }

    // Líneas de detalle
    canvas.drawLine(
      Offset(size.width * 0.1, size.height * 0.45),
      Offset(size.width * 0.9, size.height * 0.45),
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Widget para icono de parada de bus
class BusStopIcon extends StatelessWidget {
  final double size;
  final Color color;
  final bool hasArrivals;

  const BusStopIcon({
    Key? key,
    this.size = 18.0,
    this.color = const Color(StyleConstants.textSecondary),
    this.hasArrivals = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: BusStopIconPainter(color: color, hasArrivals: hasArrivals),
    );
  }
}

class BusStopIconPainter extends CustomPainter {
  final Color color;
  final bool hasArrivals;

  BusStopIconPainter({required this.color, required this.hasArrivals});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Poste de la parada
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.45, size.height * 0.1, size.width * 0.1, size.height * 0.8),
      paint,
    );

    // Señal de parada (rectángulo superior)
    final signRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.1, size.height * 0.1, size.width * 0.4, size.height * 0.3),
      Radius.circular(size.width * 0.02),
    );
    canvas.drawRRect(signRect, strokePaint);

    // Texto "BUS" simulado con líneas
    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 0.2),
      Offset(size.width * 0.45, size.height * 0.2),
      Paint()..color = color..strokeWidth = 1.0,
    );
    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 0.3),
      Offset(size.width * 0.35, size.height * 0.3),
      Paint()..color = color..strokeWidth = 1.0,
    );

    // Base de la parada
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.35, size.height * 0.85, size.width * 0.3, size.height * 0.1),
      paint,
    );

    // Indicador de arribos próximos
    if (hasArrivals) {
      final indicatorPaint = Paint()
        ..color = Color(StyleConstants.accentColor)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.2),
        size.width * 0.08,
        indicatorPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Widget para icono de navegación/dirección
class NavigationIcon extends StatelessWidget {
  final double size;
  final Color color;
  final double rotation; // en radianes

  const NavigationIcon({
    Key? key,
    this.size = 16.0,
    this.color = const Color(StyleConstants.primaryColor),
    this.rotation = 0.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: CustomPaint(
        size: Size(size, size),
        painter: NavigationIconPainter(color: color),
      ),
    );
  }
}

class NavigationIconPainter extends CustomPainter {
  final Color color;

  NavigationIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Flecha de navegación
    final path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.1); // Punta superior
    path.lineTo(size.width * 0.8, size.height * 0.7); // Esquina derecha
    path.lineTo(size.width * 0.5, size.height * 0.6); // Centro inferior
    path.lineTo(size.width * 0.2, size.height * 0.7); // Esquina izquierda
    path.close();

    canvas.drawPath(path, paint);

    // Sombra sutil
    final shadowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      path.shift(Offset(1, 1)),
      shadowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Widget para icono de tiempo/reloj
class TimeIcon extends StatelessWidget {
  final double size;
  final Color color;
  final int minutes; // para mostrar tiempo aproximado

  const TimeIcon({
    Key? key,
    this.size = 14.0,
    this.color = const Color(StyleConstants.textSecondary),
    this.minutes = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: TimeIconPainter(color: color, minutes: minutes),
    );
  }
}

class TimeIconPainter extends CustomPainter {
  final Color color;
  final int minutes;

  TimeIconPainter({required this.color, required this.minutes});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Círculo del reloj
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * 0.4,
      paint,
    );

    // Centro del reloj
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * 0.05,
      fillPaint,
    );

    // Manecilla de minutos (basada en el tiempo)
    final minuteAngle = (minutes % 60) * 6 * (3.14159 / 180) - (3.14159 / 2);
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.5),
      Offset(
        size.width * 0.5 + (size.width * 0.3) * math.cos(minuteAngle),
        size.height * 0.5 + (size.width * 0.3) * math.sin(minuteAngle),
      ),
      Paint()..color = color..strokeWidth = 1.0,
    );

    // Manecilla de hora
    final hourAngle = ((minutes ~/ 60) % 12) * 30 * (3.14159 / 180) - (3.14159 / 2);
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.5),
      Offset(
        size.width * 0.5 + (size.width * 0.2) * math.cos(hourAngle),
        size.height * 0.5 + (size.width * 0.2) * math.sin(hourAngle),
      ),
      Paint()..color = color..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Widget para icono de caminar
class WalkIcon extends StatelessWidget {
  final double size;
  final Color color;

  const WalkIcon({
    Key? key,
    this.size = 16.0,
    this.color = const Color(StyleConstants.textSecondary),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: WalkIconPainter(color: color),
    );
  }
}

class WalkIconPainter extends CustomPainter {
  final Color color;

  WalkIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // Cabeza
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.2),
      size.width * 0.08,
      paint,
    );

    // Cuerpo
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.28),
      Offset(size.width * 0.5, size.height * 0.65),
      paint,
    );

    // Brazo izquierdo
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.4),
      Offset(size.width * 0.3, size.height * 0.5),
      paint,
    );

    // Brazo derecho
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.4),
      Offset(size.width * 0.7, size.height * 0.35),
      paint,
    );

    // Pierna izquierda (en movimiento)
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.65),
      Offset(size.width * 0.35, size.height * 0.9),
      paint,
    );

    // Pierna derecha
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.65),
      Offset(size.width * 0.6, size.height * 0.85),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Importar math para las funciones trigonométricas
import 'dart:math' as math;
