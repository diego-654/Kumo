import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';

/// Mapa base de MapTiler con un estilo suave, para que destaquen las capas
/// de emociones. Las capas extra (zonas, marcadores) llegan por [layers]
/// y se pintan encima de los tiles.
///
/// La clave se pasa al compilar, nunca en el código:
/// `flutter run --dart-define="MAPTILER_KEY=..."`. Sin clave cae a
/// OpenStreetMap en gris, que sirve para tests y desarrollo.
class MapView extends StatelessWidget {
  const new({
    super.key,
    this.initialCenter = _cdmx,
    this.initialZoom = 13,
    this.layers = const [],
    this.controller,
    this.onTap,
    this.onUserMove,
  });

  static const _cdmx = LatLng(19.4326, -99.1332);

  static const _mapTilerKey = String.fromEnvironment('MAPTILER_KEY');

  /// Estilo de MapTiler: dataviz, pastel, streets-v2, basic-v2...
  static const _mapTilerStyle = 'dataviz';

  /// Quita el color (matriz de luminancia) y aclara un 35 % hacia blanco.
  static const _muted = ColorFilter.matrix(<double>[
    0.14, 0.47, 0.05, 0, 89, //
    0.14, 0.47, 0.05, 0, 89, //
    0.14, 0.47, 0.05, 0, 89, //
    0, 0, 0, 1, 0, //
  ]);

  static Widget _mutedTile(BuildContext context, Widget tile, TileImage _) =>
      ColorFiltered(colorFilter: _muted, child: tile);

  final LatLng initialCenter;
  final double initialZoom;
  final List<Widget> layers;

  /// Para leer la cámara (zoom) o moverla desde fuera.
  final MapController? controller;

  /// Avisa dónde se tocó el mapa. Qué hacer con eso lo decide la pantalla.
  final void Function(LatLng point)? onTap;

  /// Avisa cuando el usuario mueve el mapa con el dedo (no con código).
  final VoidCallback? onUserMove;

  @override
  Widget build(BuildContext context) {
    const hasKey = _mapTilerKey != '';

    return FlutterMap(
      mapController: controller,
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: initialZoom,
        minZoom: 3,
        maxZoom: 18,
        onTap: onTap == null ? null : (_, point) => onTap!(point),
        onPositionChanged: onUserMove == null
            ? null
            : (_, hasGesture) {
                if (hasGesture) onUserMove!();
              },
      ),
      children: [
        if (hasKey)
          TileLayer(
            urlTemplate:
                'https://api.maptiler.com/maps/{style}/256/'
                '{z}/{x}/{y}{r}.png?key={key}',
            additionalOptions: const {
              'style': _mapTilerStyle,
              'key': _mapTilerKey,
            },
            retinaMode: RetinaMode.isHighDensity(context),
            userAgentPackageName: 'com.kumo.app',
          )
        else
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            tileBuilder: _mutedTile,
            userAgentPackageName: 'com.kumo.app',
          ),
        ...layers,
        const RichAttributionWidget(
          attributions: [
            if (hasKey) TextSourceAttribution('MapTiler'),
            TextSourceAttribution('OpenStreetMap contributors'),
          ],
        ),
      ],
    );
  }
}
