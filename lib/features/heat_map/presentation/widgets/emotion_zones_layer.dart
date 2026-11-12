import 'dart:math';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumo/core/theme/emotion_colors.dart';
import 'package:kumo/features/heat_map/domain/entities/emotion_zone.dart';
import 'package:kumo/features/heat_map/presentation/providers/heat_map_providers.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';

/// Pinta las zonas de emoción como degradados radiales (boceto 4). Va
/// dentro de `FlutterMap`: lee el zoom con `MapCamera.of` y elige el
/// tamaño de celda (más zoom, más detalle).
class EmotionZonesLayer extends ConsumerWidget {
  const new({super.key});

  static const _distance = Distance();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final camera = MapCamera.of(context);
    // Redondeado: solo recalcula al cambiar de nivel, no en cada gesto.
    final cellSize = cellSizeForZoom(camera.zoom.round());
    final zones = ref.watch(emotionZonesProvider(cellSize)).value ?? [];
    final cellMeters = cellSize * 111000; // 1° ≈ 111 km
    final maxCount = zones.fold(1, (m, z) => max(m, z.momentCount));

    // Con una zona seleccionada, las demás se atenúan para enfocarla. Si
    // la seleccionada no está en este zoom, no se atenúa nada.
    final selected = ref.watch(selectedZoneProvider)?.cell;
    final focus = zones.any((z) => z.cell == selected) ? selected : null;
    final emotions = EmotionColors.of(context);

    final blobs = [
      for (final zone in zones)
        _blob(
          camera,
          zone,
          cellMeters,
          emotions,
          sqrt(zone.momentCount / maxCount),
          faded: focus != null && zone.cell != focus,
        ),
    ];

    return MobileLayerTransformer(
      child: CustomPaint(size: camera.size, painter: _ZonesPainter(blobs)),
    );
  }

  /// [weight] va de 0 (zona casi vacía) a 1 (la más llena). Con sqrt el
  /// área crece proporcional a los momentos.
  _Blob _blob(
    MapCamera camera,
    EmotionZone zone,
    double cellMeters,
    EmotionColors emotions,
    double weight, {
    required bool faded,
  }) {
    final center = LatLng(zone.center.latitude, zone.center.longitude);
    // Del 45 % al 85 % de la celda: el borde se desvanece, así que más
    // grande que un círculo plano para que las vecinas se fundan.
    final meters = cellMeters * (0.45 + 0.40 * weight);
    final offset = camera.getOffsetFromOrigin(center);
    final edge = camera.getOffsetFromOrigin(
      _distance.offset(center, meters, 180),
    );
    return (
      center: offset,
      radius: (offset - edge).distance,
      color: emotions.fill(zone.dominant),
      // Opacidad del centro; al 35 % si otra zona tiene el foco.
      strength: (0.55 + 0.35 * weight) * (faded ? 0.35 : 1),
    );
  }
}

typedef _Blob = ({Offset center, double radius, Color color, double strength});

/// Pinta cada zona como en el boceto: centro fuerte que se desvanece.
class _ZonesPainter extends CustomPainter {
  new(this.blobs);

  final List<_Blob> blobs;

  @override
  void paint(Canvas canvas, Size size) {
    for (final b in blobs) {
      final rect = Rect.fromCircle(center: b.center, radius: b.radius);
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            b.color.withValues(alpha: b.strength),
            b.color.withValues(alpha: b.strength * 0.4),
            b.color.withValues(alpha: 0),
          ],
          stops: const [0, 0.45, 1],
        ).createShader(rect);
      canvas.drawCircle(b.center, b.radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ZonesPainter oldDelegate) => true; // el mapa se mueve
}
