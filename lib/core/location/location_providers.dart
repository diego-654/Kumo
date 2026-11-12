import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumo/core/location/location_service.dart';

/// GPS del teléfono. En tests: `locationServiceProvider.overrideWithValue`.
final locationServiceProvider = Provider<LocationService>(
  (ref) => LocationService(),
);

/// Dónde está el usuario, "rápido primero, preciso después": emite al
/// instante la última posición conocida (si la hay) y luego una nueva.
/// Para pedirla otra vez: `ref.invalidate(currentLocationProvider)`; mientras
/// se recarga, `value` conserva la anterior y el punto azul no desaparece.
final currentLocationProvider = StreamProvider<LocationResult>((ref) async* {
  final service = ref.watch(locationServiceProvider);
  final last = await service.lastKnownLocation();
  if (last != null) yield LocationFound(last);
  yield await service.currentLocation();
});
