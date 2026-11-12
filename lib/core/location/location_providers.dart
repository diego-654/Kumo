import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumo/core/location/location_service.dart';

/// GPS del teléfono. En tests: `locationServiceProvider.overrideWithValue`.
final locationServiceProvider = Provider<LocationService>(
  (ref) => LocationService(),
);

/// Dónde está el usuario ahora. Se guarda en caché: para pedirla de nuevo
/// (botón "centrar en mí") se hace `ref.invalidate(currentLocationProvider)`.
final currentLocationProvider = FutureProvider<LocationResult>(
  (ref) => ref.watch(locationServiceProvider).currentLocation(),
);
