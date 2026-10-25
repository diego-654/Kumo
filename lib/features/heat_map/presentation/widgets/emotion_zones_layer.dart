import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:kumo/features/heat_map/domain/entities/emotion_zone.dart';
import 'package:kumo/features/moments/presentation/extensions/emotion_style.dart';
import 'package:latlong2/latlong.dart';

class EmotionZonesLayer extends StatelessWidget {
  const new({required this.zones, super.key});

  final List<EmotionZone> zones;

  @override
  Widget build(BuildContext context) {
    return CircleLayer(
      circles: [
        for (final zone in zones)
          CircleMarker(
            point: LatLng(zone.center.latitude, zone.center.longitude),
            radius: 170,
            useRadiusInMeter: true,
            color: zone.dominant.color.withValues(
              alpha: _opacity(zone.momentCount),
            ),
          ),
      ],
    );
  }

  /// Más momentos, más intenso: 1 → 0.35, 4 o más → 0.65.
  double _opacity(int count) => (0.25 + count * 0.1).clamp(0.35, 0.65);
}
