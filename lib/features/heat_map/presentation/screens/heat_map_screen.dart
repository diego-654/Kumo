import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumo/features/heat_map/presentation/providers/heat_map_providers.dart';
import 'package:kumo/features/heat_map/presentation/widgets/map_view.dart';
import 'package:kumo/features/heat_map/presentation/widgets/moments_circle_layer.dart';

/// Placeholder: aquí irá el mapa de calor emocional por zonas.
class HeatMapScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moments = ref.watch(mapMomentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mapa emocional')),
      body: Center(
        child: MapView(
          layers: [
            if (moments case AsyncData(:final value))
              MomentsCircleLayer(moments: value),
          ],
        ),
      ),
    );
  }
}
