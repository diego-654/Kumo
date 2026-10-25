import 'package:flutter/material.dart';
import 'package:kumo/features/heat_map/presentation/widgets/emotion_zones_layer.dart';
import 'package:kumo/features/heat_map/presentation/widgets/map_view.dart';

/// Mapa de calor emocional: zonas pintadas por la emoción dominante.
class HeatMapScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Scaffold(
        body: Center(
          child: MapView(layers: [EmotionZonesLayer()]),
        ),
      ),
    );
  }
}
