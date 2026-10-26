import 'package:flutter/material.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumo/core/location/geo_point.dart';
import 'package:kumo/features/heat_map/domain/entities/emotion_zone.dart';
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

class _HeatMapScreenState extends ConsumerState<HeatMapScreen>
    with TickerProviderStateMixin {
  /// Controller con movimientos animados. Si tocas otra zona a mitad del
  /// movimiento, cancela el anterior en vez de mezclarlos.
  late final _map = AnimatedMapController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
    curve: Curves.easeOutCubic,
    cancelPreviousAnimations: true,
  );

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  /// Busca la zona en la celda tocada, con el tamaño de celda del zoom
  /// actual. Si no hay zona ahí, deselecciona y la hoja se cierra.
  Future<void> _onMapTap(LatLng point) async {
    final cellSize = cellSizeForZoom(_map.mapController.camera.zoom.round());
    final cell = EmotionZoneBuilder(cellSizeDegrees: cellSize).cellOf(
      GeoPoint(latitude: point.latitude, longitude: point.longitude),
    );
    final zones = ref.read(emotionZonesProvider(cellSize)).value ?? [];
    final tapped = zones.where((z) => z.cell == cell).firstOrNull;
    ref.read(selectedZoneProvider.notifier).select(tapped);
    if (tapped != null) await _focusOn(tapped);
  }

  /// Desliza la cámara hasta dejar la zona centrada en el área visible
  /// arriba de la hoja (que ocupa el 30 % inferior), sin cambiar el zoom.
  Future<void> _focusOn(EmotionZone zone) async {
    final sheetHeight = _map.mapController.camera.size.height * 0.3;
    await _map.animateTo(
      dest: LatLng(zone.center.latitude, zone.center.longitude),
      offset: Offset(0, -sheetHeight / 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(selectedZoneProvider);

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            MapView(
              controller: _map.mapController,
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
