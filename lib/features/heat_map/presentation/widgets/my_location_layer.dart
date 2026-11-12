import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumo/core/location/location_providers.dart';
import 'package:kumo/core/location/location_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';

/// Punto azul con halo donde está el usuario. Va dentro de `FlutterMap`,
/// después de las zonas para quedar encima. Sin ubicación no pinta nada.
class MyLocationLayer extends ConsumerWidget {
  const new({super.key});

  static const double _haloSize = 44;
  static const double _dotSize = 18;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(currentLocationProvider).value;
    if (result is! LocationFound) return const SizedBox.shrink();

    final colors = Theme.of(context).colorScheme;
    final point = result.point;

    return MarkerLayer(
      markers: [
        Marker(
          point: LatLng(point.latitude, point.longitude),
          width: _haloSize,
          height: _haloSize,
          child: DecoratedBox(
            // Halo suave: da a entender que la posición es aproximada.
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: _dotSize,
                height: _dotSize,
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.surface, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: colors.shadow.withValues(alpha: 0.25),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
