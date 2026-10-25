import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:kumo/features/moments/domain/entities/moment.dart';
import 'package:kumo/features/moments/presentation/extensions/emotion_style.dart';
import 'package:latlong2/latlong.dart';

class MomentsCircleLayer extends StatelessWidget {
  const new({required this.moments, super.key});

  final List<Moment> moments;

  @override
  Widget build(BuildContext context) {
    return CircleLayer(
      circles: [
        for (final m in moments)
          CircleMarker(
            point: LatLng(m.location!.latitude, m.location!.longitude),
            radius: 60,
            useRadiusInMeter: true,
            color: m.sentiment!.emotion.color.withValues(alpha: 0.45),
          ),
      ],
    );
  }
}
