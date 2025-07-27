# Subite+ 🚌

Una aplicación Flutter moderna para la planificación de rutas urbanas en Montevideo, Uruguay, con datos en tiempo real.

## 📱 Características

### ✅ Funcionalidades Implementadas

- **Interfaz en Español**: Completamente localizada para usuarios uruguayos
- **Diseño Minimalista**: Tipografías Arial muy pequeñas y diseño limpio
- **Optimizado para Móviles**: Diseño responsivo para pantallas móviles
- **Iconografía Original**: Iconos personalizados inspirados en movilidad urbana

### 🚍 Funcionalidades de Transporte

- **Búsqueda de Rutas**: Planificación inteligente de trayectos
- **Resultados Múltiples**: Opciones variadas de trayecto
- **Tiempos en Tiempo Real**: Próximos arribos actualizados
- **Ubicación de Buses**: Seguimiento en vivo de vehículos
- **Detalles del Viaje**: Información precisa y sutil
- **Navegación Paso a Paso**: Indicaciones detalladas

### 🗺️ Mapa Interactivo

- **Centrado en Montevideo**: Exclusivamente para la ciudad
- **Google Maps Integration**: Mapas de alta calidad
- **Rutas STM**: Integración con el sistema de transporte metropolitano
- **Modo Navegación**: Similar a Moovit, solo se muestra en navegación

## 🔧 Tecnologías Utilizadas

### Frontend
- **Flutter**: Framework principal
- **Google Maps Flutter**: Integración de mapas
- **Provider**: Gestión de estado
- **Geolocator**: Servicios de ubicación

### APIs Integradas
- **Google Maps API**: `AIzaSyD1R-HlWiKZ55BMDdv1KP5anE5T5MX4YkU`
- **Google Directions API**: Cálculo de rutas optimizadas
- **STM API**: Datos en tiempo real del transporte público
  - Client ID: `d7916e2b`
  - Client Secret: `164c5cf512e692dbfcc2fbda1f0ec0a1`
  - Token URL: `https://mvdapi-auth.montevideo.gub.uy/token`
  - Base URL: `/api/transportepublico`

## 📁 Estructura del Proyecto

```
subite_plus/
├── lib/
│   ├── main.dart                 # Punto de entrada
│   ├── models/                   # Modelos de datos
│   │   ├── route_model.dart      # Modelo de rutas
│   │   └── bus_model.dart        # Modelo de buses y paradas
│   ├── screens/                  # Pantallas de la aplicación
│   │   ├── home_screen.dart      # Pantalla principal
│   │   ├── route_search_screen.dart    # Búsqueda de rutas
│   │   ├── route_results_screen.dart   # Resultados de búsqueda
│   │   └── navigation_screen.dart      # Navegación con mapa
│   ├── services/                 # Servicios de API
│   │   ├── stm_api_service.dart        # Servicio STM
│   │   ├── directions_service.dart     # Servicio Google Directions
│   │   └── location_service.dart       # Servicio de ubicación
│   ├── widgets/                  # Componentes reutilizables
│   │   ├── custom_icons.dart           # Iconografía original
│   │   ├── route_card.dart             # Tarjetas de ruta
│   │   └── step_by_step_widget.dart    # Widget de navegación
│   ├── theme/
│   │   └── app_theme.dart        # Tema minimalista
│   └── utils/
│       └── constants.dart        # Constantes y configuración
├── android/                      # Configuración Android
├── assets/                       # Recursos estáticos
└── pubspec.yaml                  # Dependencias
```

## 🚀 Instalación y Configuración

### Prerrequisitos

1. **Flutter SDK** (versión 3.10.0 o superior)
2. **Android Studio** o **VS Code** con extensiones de Flutter
3. **Dispositivo Android** o **Emulador** configurado

### Pasos de Instalación

1. **Clonar el repositorio**
   ```bash
   git clone <repository-url>
   cd subite_plus
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Configurar permisos de ubicación**
   - Los permisos ya están configurados en `android/app/src/main/AndroidManifest.xml`

4. **Ejecutar la aplicación**
   ```bash
   flutter run
   ```

## 📱 Uso de la Aplicación

### Pantalla Principal
- Visualiza próximos arribos cerca de tu ubicación
- Accede a la búsqueda de rutas
- Botón directo al modo navegación

### Búsqueda de Rutas
1. Ingresa origen y destino
2. Usa ubicación actual como origen
3. Selecciona de destinos populares
4. Obtén múltiples opciones de ruta

### Resultados de Rutas
- Compara diferentes opciones
- Ve detalles de cada trayecto
- Inicia navegación paso a paso

### Modo Navegación
- Mapa interactivo centrado en Montevideo
- Seguimiento de buses en tiempo real
- Indicaciones paso a paso
- Ubicación de paradas cercanas

## 🔑 APIs y Credenciales

### Google Maps API
- **Funciones**: Mapas, direcciones, geocoding
- **Límites**: Según plan de Google Cloud
- **Configuración**: Ya integrada en el código

### STM API (Sistema de Transporte Metropolitano)
- **Funciones**: Datos en tiempo real de buses
- **Autenticación**: OAuth 2.0 con client credentials
- **Endpoints disponibles**:
  - `/buses/linea/{linea}` - Buses por línea
  - `/buses/cercanos` - Buses cercanos
  - `/paradas/{id}` - Información de parada
  - `/paradas/cercanas` - Paradas cercanas
  - `/paradas/{id}/arribos` - Próximos arribos

## 🎨 Diseño y UX

### Principios de Diseño
- **Minimalismo**: Interfaz limpia sin elementos innecesarios
- **Tipografía**: Arial en tamaños muy pequeños
- **Colores**: Paleta minimalista (blanco, gris, azul transporte)
- **Iconografía**: Diseños originales sin librerías externas

### Optimizaciones Móviles
- Diseño responsivo para diferentes tamaños de pantalla
- Gestos táctiles intuitivos
- Optimización de batería durante navegación
- Caché de datos para uso offline básico

## 🔧 Desarrollo y Contribución

### Estructura de Código
- **Modular**: Separación clara de responsabilidades
- **Escalable**: Fácil agregar nuevas funcionalidades
- **Mantenible**: Código documentado y organizado

### Próximas Funcionalidades
- [ ] Notificaciones push para arribos
- [ ] Favoritos de rutas frecuentes
- [ ] Modo offline avanzado
- [ ] Integración con otros medios de transporte
- [ ] Historial de viajes

## 📄 Licencia

Este proyecto está desarrollado para la planificación de rutas urbanas en Montevideo, Uruguay.

## 🤝 Soporte

Para soporte técnico o consultas sobre la aplicación:
- Revisa la documentación del código
- Verifica la configuración de APIs
- Consulta los logs de la aplicación para debugging

---

**Subite+** - Tu compañero inteligente para el transporte público en Montevideo 🇺🇾
