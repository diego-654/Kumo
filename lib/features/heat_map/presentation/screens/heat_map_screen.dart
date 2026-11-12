import 'dart:async';

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
import 'package:kumo/features/heat_map/presentation/widgets/emotion_legend.dart';
import 'package:kumo/features/heat_map/presentation/widgets/emotion_zones_layer.dart';
import 'package:kumo/features/heat_map/presentation/widgets/map_view.dart';
import 'package:kumo/features/heat_map/presentation/widgets/my_location_layer.dart';
import 'package:kumo/features/heat_map/presentation/widgets/pending_moments_layer.dart';
import 'package:kumo/features/heat_map/presentation/widgets/zone_summary_sheet.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';

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

  /// Si la posición nueva se aleja menos que esto, no movemos la cámara.
  static const double _recenterMeters = 30;

  static const _distance = Distance();

  /// La cámara sigue al usuario hasta que él mueva el mapa con el dedo:
  /// nunca le quitamos el mapa de las manos. Arranca en `true` para
  /// centrar al abrir, y el botón la vuelve a activar.
  bool _followUser = true;

  /// Dónde centramos la última vez, para no repetir el movimiento.
  LatLng? _lastCentered;

  /// Solo avisamos de errores si el usuario tocó el botón.
  bool _fromButton = false;

  /// Zoom al llevar la cámara a un momento: se ve la calle.
  static const double _focusZoom = 16;

  @override
  void initState() {
    super.initState();
    // listenManual (y no ref.listen en build) porque necesitamos
    // `fireImmediately`: si la petición llegó antes de que el mapa
    // existiera (abriste el detalle desde un enlace), también se atiende.
    ref.listenManual(mapFocusRequestProvider, (_, point) {
      if (point == null) return;
      // Esperamos al primer frame: antes el MapController no está listo.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _followUser = false; // que el GPS no nos robe la cámara
        final dest = LatLng(point.latitude, point.longitude);
        _lastCentered = dest;
        unawaited(_map.animateTo(dest: dest, zoom: _focusZoom));
        ref.read(mapFocusRequestProvider.notifier).point = null;
      });
    }, fireImmediately: true);
  }

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
    ref.read(selectedZoneProvider.notifier).zone = tapped;
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

  /// "Centrar en mí": centra YA con la posición que tengamos y, en paralelo,
  /// pide una nueva. Si la nueva está lejos, `_onLocation` corrige.
  void _centerOnMe() {
    _followUser = true;
    _fromButton = true;
    if (ref.read(currentLocationProvider).value case LocationFound(
      :final point,
    )) {
      _moveTo(LatLng(point.latitude, point.longitude));
    }
    ref.invalidate(currentLocationProvider);
  }

  void _moveTo(LatLng dest) {
    _lastCentered = dest;
    unawaited(_map.animateTo(dest: dest, zoom: _myLocationZoom));
  }

  /// Llega dos veces por búsqueda: la última conocida y luego la nueva.
  void _onLocation(LocationResult result) {
    if (result case LocationFound(:final point)) {
      final dest = LatLng(point.latitude, point.longitude);
      final last = _lastCentered;
      final farEnough = last == null || _distance(last, dest) > _recenterMeters;
      if (_followUser && farEnough) _moveTo(dest);
      return;
    }

    // Al abrir el mapa no molestamos con avisos; solo si lo pidió.
    if (!_fromButton) return;
    _fromButton = false;
    switch (result) {
      case LocationFound():
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
    final location = ref.watch(currentLocationProvider);
    // Spinner solo si aún no tenemos ninguna posición que enseñar.
    final locating = location.isLoading && location.value is! LocationFound;

    // Cada resultado nuevo del GPS pasa por aquí (también tras invalidar).
    ref.listen(currentLocationProvider, (_, next) {
      final result = next.value;
      if (!next.isLoading && result != null) _onLocation(result);
    });

    // bottom: false deja que el mapa llegue hasta abajo, detrás de la barra
    // de vidrio. El padding inferior sigue en MediaQuery para quien lo
    // necesite (la atribución del mapa y la hoja de zona lo usan).
    return SafeArea(
      bottom: false,
      child: Scaffold(
        body: Stack(
          children: [
            MapView(
              controller: _map.mapController,
              onTap: _onMapTap,
              onUserMove: () => _followUser = false,
              layers: const [
                EmotionZonesLayer(),
                PendingMomentsLayer(),
                MyLocationLayer(),
              ],
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
            // Arriba a la izquierda, simétrico al de ubicación.
            const Positioned(top: 12, left: 12, child: EmotionLegendButton()),
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
