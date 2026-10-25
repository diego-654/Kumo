import 'package:flutter/foundation.dart';

/// Un punto en la Tierra, en grados (el mismo sistema que usa el GPS).
///
/// Vive en `core/` porque lo usan varias features: momentos lo guarda y el
/// mapa lo dibuja. Es Dart puro: no depende de ningún paquete de mapas.
@immutable
class GeoPoint {
  const new({required this.latitude, required this.longitude})
    : assert(
        latitude >= -90 && latitude <= 90,
        'La latitud va de -90 a 90',
      ),
      assert(
        longitude >= -180 && longitude <= 180,
        'La longitud va de -180 a 180',
      );

  /// Norte (+) o sur (-) del ecuador.
  final double latitude;

  /// Este (+) u oeste (-) de Greenwich.
  final double longitude;

  @override
  bool operator ==(Object other) =>
      other is GeoPoint &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() => 'GeoPoint($latitude, $longitude)';
}
