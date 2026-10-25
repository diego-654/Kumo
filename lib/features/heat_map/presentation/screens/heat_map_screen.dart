import 'package:flutter/material.dart';
import 'package:kumo/features/heat_map/presentation/widgets/map_view.dart';

/// Placeholder: aquí irá el mapa de calor emocional por zonas.
class HeatMapScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa emocional')),
      body: const Center(child: MapView()),
    );
  }
}
