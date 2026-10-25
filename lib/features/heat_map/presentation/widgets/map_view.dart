import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Mapa base de OpenStreetMap. Las capas extra (zonas, marcadores)
/// llegan por [layers] y se pintan encima de los tiles.
class MapView extends StatelessWidget {
  const new({
    super.key,
    this.initialCenter = _cdmx,
    this.initialZoom = 13,
    this.layers = const [],
  });

  static const _cdmx = LatLng(19.4326, -99.1332);

  final LatLng initialCenter;
  final double initialZoom;
  final List<Widget> layers;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: initialZoom,
        minZoom: 3,
        maxZoom: 18,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.kumo.app',
        ),
        ...layers,
        const RichAttributionWidget(
          attributions: [
            TextSourceAttribution('OpenStreetMap contributors'),
          ],
        ),
      ],
    );
  }
}
