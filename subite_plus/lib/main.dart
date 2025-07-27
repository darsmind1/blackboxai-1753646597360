import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'utils/constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configurar orientación de pantalla (solo vertical)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Configurar barra de estado
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(StyleConstants.backgroundColor),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(SubitePlusApp());
}

class SubitePlusApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Aquí se pueden agregar providers para state management si es necesario
        // ChangeNotifierProvider(create: (_) => LocationProvider()),
        // ChangeNotifierProvider(create: (_) => RouteProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        
        // Tema de la aplicación
        theme: AppTheme.lightTheme,
        
        // Configuración de localización
        locale: Locale('es', 'UY'), // Español de Uruguay
        
        // Pantalla inicial
        home: SplashScreen(),
        
        // Rutas de navegación
        routes: {
          '/home': (context) => HomeScreen(),
        },
        
        // Builder para configuraciones globales
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: 1.0, // Evitar que el usuario cambie el tamaño del texto
            ),
            child: child!,
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> 
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 0.6, curve: Curves.easeIn),
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));
    
    _startSplashSequence();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startSplashSequence() async {
    // Iniciar animación
    _animationController.forward();
    
    // Esperar a que termine la animación
    await Future.delayed(Duration(milliseconds: 2500));
    
    // Navegar a la pantalla principal
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(StyleConstants.backgroundColor),
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo de la aplicación
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Color(StyleConstants.primaryColor),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(StyleConstants.primaryColor).withOpacity(0.3),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: CustomPaint(
                          size: Size(60, 60),
                          painter: SplashBusIconPainter(),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: StyleConstants.spacingLarge),
                    
                    // Nombre de la aplicación
                    Text(
                      AppConstants.appName,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Color(StyleConstants.primaryColor),
                        letterSpacing: 1.2,
                      ),
                    ),
                    
                    SizedBox(height: StyleConstants.spacingSmall),
                    
                    // Subtítulo
                    Text(
                      'Planificación de rutas urbanas',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: StyleConstants.fontSizeSmall,
                        color: Color(StyleConstants.textSecondary),
                        letterSpacing: 0.5,
                      ),
                    ),
                    
                    SizedBox(height: StyleConstants.spacingLarge * 2),
                    
                    // Indicador de carga
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(StyleConstants.primaryColor),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: StyleConstants.spacingMedium),
                    
                    Text(
                      'Montevideo, Uruguay',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: StyleConstants.fontSizeVerySmall,
                        color: Color(StyleConstants.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Painter personalizado para el icono del splash
class SplashBusIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Cuerpo principal del bus
    final busBody = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.1, size.height * 0.2, size.width * 0.8, size.height * 0.6),
      Radius.circular(size.width * 0.08),
    );
    canvas.drawRRect(busBody, paint);

    // Ventanas
    final windowPaint = Paint()
      ..color = Color(StyleConstants.primaryColor)
      ..style = PaintingStyle.fill;

    // Ventana frontal
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.15, size.height * 0.3, size.width * 0.15, size.height * 0.25),
        Radius.circular(size.width * 0.02),
      ),
      windowPaint,
    );

    // Ventanas laterales
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.35, size.height * 0.3, size.width * 0.12, size.height * 0.25),
        Radius.circular(size.width * 0.02),
      ),
      windowPaint,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.52, size.height * 0.3, size.width * 0.12, size.height * 0.25),
        Radius.circular(size.width * 0.02),
      ),
      windowPaint,
    );

    // Ruedas
    final wheelPaint = Paint()
      ..color = Color(StyleConstants.primaryColor)
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

    // Puerta
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.68, size.height * 0.45, size.width * 0.08, size.height * 0.35),
        Radius.circular(size.width * 0.02),
      ),
      windowPaint,
    );

    // Línea de detalle
    canvas.drawLine(
      Offset(size.width * 0.1, size.height * 0.5),
      Offset(size.width * 0.9, size.height * 0.5),
      strokePaint,
    );

    // Símbolo "+" en el frente
    final plusPaint = Paint()
      ..color = Color(StyleConstants.primaryColor)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Línea horizontal del +
    canvas.drawLine(
      Offset(size.width * 0.18, size.height * 0.42),
      Offset(size.width * 0.27, size.height * 0.42),
      plusPaint,
    );

    // Línea vertical del +
    canvas.drawLine(
      Offset(size.width * 0.225, size.height * 0.37),
      Offset(size.width * 0.225, size.height * 0.47),
      plusPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
