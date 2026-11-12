import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kumo/app/router/app_routes.dart';
import 'package:kumo/features/heat_map/presentation/providers/heat_map_providers.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';

/// Momentos que la IA aún no analizó: punto gris, más pequeño que el de
/// "mi ubicación" y sin halo, para no confundirlos. No cuentan en las zonas.
/// Va encima de las zonas y debajo de `MyLocationLayer`.
class PendingMomentsLayer extends ConsumerWidget {
  const new({super.key});

  static const double _dotSize = 12;

  /// Área táctil mayor que el punto: un dedo no acierta en 12 px.
  static const double _tapSize = 32;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moments = ref.watch(pendingMapMomentsProvider).value ?? [];
    if (moments.isEmpty) return const SizedBox.shrink();

    final colors = Theme.of(context).colorScheme;

    return MarkerLayer(
      markers: [
        for (final moment in moments)
          Marker(
            point: LatLng(
              moment.location!.latitude,
              moment.location!.longitude,
            ),
            width: _tapSize,
            height: _tapSize,
            // El GestureDetector gana el toque antes que el `onTap` del
            // mapa, así tocar el punto no selecciona la zona de debajo.
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => context.push(AppRoutes.momentDetail(moment.id)),
              child: Tooltip(
                message: 'Pendiente de análisis',
                child: Center(
                  child: Container(
                    width: _dotSize,
                    height: _dotSize,
                    decoration: BoxDecoration(
                      color: colors.outline.withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.surface, width: 2),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
