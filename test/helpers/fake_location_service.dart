import 'package:kumo/core/location/geo_point.dart';
import 'package:kumo/core/location/location_service.dart';

/// GPS de mentira: responde al instante con [result] y nunca toca el plugin
/// `geolocator` (en tests no existe y lanzaría `MissingPluginException`).
///
/// `implements` (no `extends`): así el compilador nos obliga a cubrir
/// cada método público de [LocationService] y no heredamos nada real.
class FakeLocationService implements LocationService {
  const new({this.result = const LocationUnavailable(), this.lastKnown});

  /// Lo que devuelve [currentLocation].
  final LocationResult result;

  /// Lo que devuelve [lastKnownLocation]; `null` = el teléfono no recuerda.
  final GeoPoint? lastKnown;

  @override
  Future<LocationResult> currentLocation({bool precise = false}) async =>
      result;

  @override
  Future<GeoPoint?> lastKnownLocation() async => lastKnown;

  @override
  Future<bool> openAppSettings() async => false;
}
