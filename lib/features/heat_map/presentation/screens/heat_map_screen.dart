import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kumo/app/router/app_routes.dart';
import 'package:kumo/core/location/geo_point.dart';
import 'package:kumo/core/location/location_providers.dart';
import 'package:kumo/core/location/location_service.dart';
import 'package:kumo/features/heat_map/domain/entities/emotion_zone.dart';
import 'package:kumo/features/heat_map/domain/services/emotion_zone_builder.dart';
import 'package:kumo/features/heat_map/presentation/providers/heat_map_providers.dart';
import 'package:kumo/features/heat_map/presentation/widgets/emotion_zones_layer.dart';
import 'package:kumo/features/heat_map/presentation/widgets/map_view.dart';
import 'package:kumo/features/heat_map/presentation/widgets/my_location_layer.dart';
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

  /// Zoom al centrar en el usuario: se ve el barrio.
  static const double _myLocationZoom = 15;

  /// Al abrir el mapa se centra en el usuario una sola vez, y solo si aún
  /// no lo movió él: nunca le quitamos el mapa de las manos.
  bool _autoCenterPending = true;

  /// `true` mientras esperamos el GPS tras tocar "centrar en mí".
  bool _centerRequested = false;

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

  /// "Centrar en mí": pide una posición nueva; al llegar, `_onLocation`
  /// mueve la cámara.
  void _centerOnMe() {
    _centerRequested = true;
    ref.invalidate(currentLocationProvider);
  }

  void _onLocation(LocationResult result) {
    final wanted = _centerRequested || _autoCenterPending;
    final fromButton = _centerRequested;
    _centerRequested = false;
    _autoCenterPending = false;
    if (!wanted) return;

    switch (result) {
      case LocationFound(:final point):
        unawaited(
          _map.animateTo(
            dest: LatLng(point.latitude, point.longitude),
            zoom: _myLocationZoom,
          ),
        );
      // Al abrir el mapa no molestamos con avisos; solo si lo pidió.
      case _ when !fromButton:
        break;
      case LocationPermissionDeniedForever():
        _showLocationError(
          'Activa el permiso de ubicación en Ajustes',
          actionLabel: 'Ajustes',
          onAction: () =>
              unawaited(ref.read(locationServiceProvider).openAppSettings()),
        );
      case LocationPermissionDenied():
        _showLocationError(
          'Kumo necesita permiso para ver dónde estás',
          actionLabel: 'Reintentar',
          onAction: _centerOnMe,
        );
      case LocationServiceDisabled() || LocationUnavailable():
        _showLocationError(
          'No pudimos encontrar tu ubicación. ¿Está el GPS encendido?',
          actionLabel: 'Reintentar',
          onAction: _centerOnMe,
        );
    }
  }

  void _showLocationError(
    String message, {
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: SnackBarAction(label: actionLabel, onPressed: onAction),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(selectedZoneProvider);
    final locating = ref.watch(currentLocationProvider).isLoading;

    // Cada resultado nuevo del GPS pasa por aquí (también tras invalidar).
    ref.listen(currentLocationProvider, (_, next) {
      final result = next.value;
      if (!next.isLoading && result != null) _onLocation(result);
    });

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            MapView(
              controller: _map.mapController,
              onTap: _onMapTap,
              onUserMove: () => _autoCenterPending = false,
              layers: const [EmotionZonesLayer(), MyLocationLayer()],
            ),
            // Arriba a la derecha: la hoja de zona sube desde abajo y lo
            // taparía si estuviera en la esquina inferior.
            Positioned(
              top: 12,
              right: 12,
              child: FloatingActionButton.small(
                heroTag: 'center-on-me',
                tooltip: 'Centrar en mí',
                onPressed: locating ? null : _centerOnMe,
                child: locating
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
              ),
            ),
            if (selected != null)
              // La key reinicia la hoja al cambiar de zona (vuelve al 30 %).
              ZoneSummarySheet(
                key: ValueKey(selected.cell),
                zone: selected,
                onPlaceTap: (name) => context.push(AppRoutes.placeDetail(name)),
              ),
          ],
        ),
      ),
    );
  }
}
