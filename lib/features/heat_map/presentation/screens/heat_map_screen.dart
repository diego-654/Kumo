import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumo/core/location/geo_point.dart';
import 'package:kumo/features/heat_map/domain/services/emotion_zone_builder.dart';
import 'package:kumo/features/heat_map/presentation/providers/heat_map_providers.dart';
import 'package:kumo/features/heat_map/presentation/widgets/emotion_zones_layer.dart';
import 'package:kumo/features/heat_map/presentation/widgets/map_view.dart';
import 'package:kumo/features/heat_map/presentation/widgets/zone_summary_sheet.dart';
import 'package:latlong2/latlong.dart';

/// Mapa de calor emocional: zonas pintadas por la emoción dominante. Al
/// tocar una zona sube su resumen (boceto 5) sin salir del mapa.
class HeatMapScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<HeatMapScreen> createState() => _HeatMapScreenState();
}

class _HeatMapScreenState extends ConsumerState<HeatMapScreen> {
  final _mapController = MapController();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  /// Busca la zona en la celda tocada, con el tamaño de celda del zoom
  /// actual. Si no hay zona ahí, deselecciona y la hoja se cierra.
  void _onMapTap(LatLng point) {
    final cellSize = cellSizeForZoom(_mapController.camera.zoom.round());
    final cell = EmotionZoneBuilder(cellSizeDegrees: cellSize).cellOf(
      GeoPoint(latitude: point.latitude, longitude: point.longitude),
    );
    final zones = ref.read(emotionZonesProvider(cellSize)).value ?? [];
    final tapped = zones.where((z) => z.cell == cell).firstOrNull;
    ref.read(selectedZoneProvider.notifier).select(tapped);
  }

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(selectedZoneProvider);

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            MapView(
              controller: _mapController,
              onTap: _onMapTap,
              layers: const [EmotionZonesLayer()],
            ),
            if (selected != null)
              // La key reinicia la hoja al cambiar de zona (vuelve al 30 %).
              ZoneSummarySheet(key: ValueKey(selected.cell), zone: selected),
          ],
        ),
      ),
    );
  }
}
