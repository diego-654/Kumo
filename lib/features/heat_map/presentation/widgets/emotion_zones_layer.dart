import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumo/features/heat_map/presentation/providers/heat_map_providers.dart';
import 'package:kumo/features/moments/presentation/extensions/emotion_style.dart';
import 'package:latlong2/latlong.dart';

/// Pinta las zonas de emoción. Va dentro de `FlutterMap`: lee el zoom con
/// `MapCamera.of` y elige el tamaño de celda (más zoom, más detalle).
class EmotionZonesLayer extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Redondeado: solo recalcula al cambiar de nivel, no en cada gesto.
    final zoom = MapCamera.of(context).zoom.round();
    final cellSize = cellSizeForZoom(zoom);
    final zones = ref.watch(emotionZonesProvider(cellSize)).value ?? [];
    final cellMeters = cellSize * 111000; // 1° ≈ 111 km
    final maxCount = zones.fold(1, (m, z) => max(m, z.momentCount));

    return CircleLayer(
      circles: [
        for (final zone in zones)
          CircleMarker(
            point: LatLng(zone.center.latitude, zone.center.longitude),
            radius: _radius(zone.momentCount, maxCount, cellMeters),
            useRadiusInMeter: true,
            color: zone.dominant.color.withValues(
              alpha: _opacity(zone.momentCount, maxCount),
            ),
          ),
      ],
    );
  }

  /// Del 25 % al 55 % de la celda: crece con el zoom y con los momentos.
  /// Con sqrt el área crece proporcional a los momentos.
  double _radius(int count, int maxCount, double cellMeters) =>
      cellMeters * (0.25 + 0.30 * sqrt(count / maxCount));

  /// De 0.3 (zona casi vacía) a 0.65 (la más llena), relativo como el radio.
  double _opacity(int count, int maxCount) =>
      0.3 + (0.65 - 0.3) * sqrt(count / maxCount);
}
