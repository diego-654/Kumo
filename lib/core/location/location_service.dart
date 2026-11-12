import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:kumo/core/location/geo_point.dart';

/// Resultado de pedir la ubicación. Es `sealed`: un `switch` sobre él obliga
/// a tratar todos los casos, así la UI no olvida ninguno.
sealed class LocationResult {
  const new();
}

/// Tenemos posición.
final class LocationFound extends LocationResult {
  const new(this.point);

  final GeoPoint point;
}

/// El GPS del teléfono está apagado.
final class LocationServiceDisabled extends LocationResult {
  const new();
}

/// El usuario dijo "no" esta vez; se le puede volver a preguntar.
final class LocationPermissionDenied extends LocationResult {
  const new();
}

/// El usuario dijo "no" para siempre: solo se cambia desde Ajustes.
final class LocationPermissionDeniedForever extends LocationResult {
  const new();
}

/// Hay permiso pero no se consiguió posición a tiempo (p. ej. bajo techo).
final class LocationUnavailable extends LocationResult {
  const new();
}

/// Envuelve `geolocator` para que el resto de la app no dependa del plugin.
///
/// Vive en `core/` porque lo usan momentos (al crear) y el mapa.
/// En tests se reemplaza por un fake vía `locationServiceProvider`.
class LocationService {
  /// Rápido: precisión media (wifi/antenas, ~100 m) y poco tiempo de espera.
  /// Basta para centrar el mapa.
  static const LocationSettings _fast = LocationSettings(
    accuracy: LocationAccuracy.medium,
    timeLimit: Duration(seconds: 5),
  );

  /// Preciso: GPS de verdad (`high` es el valor por defecto). Tarda más,
  /// pero es lo que se guarda con el momento.
  static const LocationSettings _precise = LocationSettings(
    timeLimit: Duration(seconds: 10),
  );

  /// Pide una posición nueva. Con [precise] usa el GPS (más lento);
  /// sin él, una aproximada que llega antes.
  Future<LocationResult> currentLocation({bool precise = false}) async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return const LocationServiceDisabled();
    }

    // Solo se muestra el diálogo del sistema si aún no respondió.
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    switch (permission) {
      case LocationPermission.denied:
        return const LocationPermissionDenied();
      case LocationPermission.deniedForever:
        return const LocationPermissionDeniedForever();
      case LocationPermission.whileInUse:
      case LocationPermission.always:
      case LocationPermission.unableToDetermine:
        break;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: precise ? _precise : _fast,
      );
      return LocationFound(_toGeoPoint(position));
    } on TimeoutException {
      // Respaldo: la última posición que el teléfono recuerde.
      final last = await Geolocator.getLastKnownPosition();
      return last == null
          ? const LocationUnavailable()
          : LocationFound(_toGeoPoint(last));
    } on LocationServiceDisabledException {
      // El usuario apagó el GPS mientras esperábamos.
      return const LocationServiceDisabled();
    }
  }

  /// La última posición que el teléfono recuerda: llega al instante, pero
  /// puede ser vieja. Nunca muestra el diálogo de permisos: si no hay
  /// permiso todavía, devuelve `null` y ya lo pedirá [currentLocation].
  Future<GeoPoint?> lastKnownLocation() async {
    final permission = await Geolocator.checkPermission();
    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      return null;
    }
    try {
      final last = await Geolocator.getLastKnownPosition();
      return last == null ? null : _toGeoPoint(last);
    } on Exception {
      // Algunas plataformas (web) no la tienen: no es un error grave.
      return null;
    }
  }

  /// Abre los ajustes de la app para que el usuario conceda el permiso.
  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  GeoPoint _toGeoPoint(Position position) =>
      GeoPoint(latitude: position.latitude, longitude: position.longitude);
}
