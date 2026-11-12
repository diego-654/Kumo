import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumo/core/location/location_service.dart';

/// GPS del teléfono. En tests: `locationServiceProvider.overrideWithValue`.
final locationServiceProvider = Provider<LocationService>(
  (ref) => LocationService(),
);
