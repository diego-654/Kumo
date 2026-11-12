import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';

/// Mapa base de MapTiler a color, con versión clara y oscura que sigue al
/// tema de la app. Las capas extra (zonas, marcadores) llegan por [layers]
/// y se pintan encima de los tiles.
///
/// La clave se pasa al compilar, nunca en el código:
/// `flutter run --dart-define="MAPTILER_KEY=..."`. Sin clave cae a
/// OpenStreetMap con el color suavizado, que sirve para tests y desarrollo.
///
/// Para probar otro estilo sin tocar código:
/// `--dart-define="MAPTILER_STYLE=pastel"`. Si el estilo tiene variante
/// oscura (`<estilo>-dark`), se usa sola en modo oscuro.
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

  /// Estilo de MapTiler: streets-v2, bright-v2, pastel, basic-v2,
  /// outdoor-v2... (catálogo en cloud.maptiler.com/maps).
  static const _mapTilerStyle = String.fromEnvironment(
    'MAPTILER_STYLE',
    defaultValue: 'streets-v2',
  );

  /// Estilos de MapTiler que tienen variante `-dark`.
  static const _stylesWithDark = {
    'streets-v2',
    'basic-v2',
    'bright-v2',
    'outdoor-v2',
    'dataviz',
  };

  /// El estilo según el tema: en oscuro, un mapa claro deslumbra y hace
  /// que las zonas se vean lavadas.
  static String _styleFor(Brightness brightness) =>
      brightness == Brightness.dark && _stylesWithDark.contains(_mapTilerStyle)
      ? '$_mapTilerStyle-dark'
      : _mapTilerStyle;

  /// Deja el 70 % de la saturación y aclara un 10 % hacia blanco: el mapa
  /// conserva su color (parques verdes, agua azul) pero queda un paso por
  /// detrás de las zonas de emociones, que son lo importante.
  ///
  /// Cómo leer la matriz: cada fila calcula un canal (R, G, B, A) a partir
  /// de los cuatro de entrada más un desplazamiento (0-255). Los pesos
  /// 0.21/0.72/0.07 son la luminancia que percibe el ojo.
  static const _softened = ColorFilter.matrix(<double>[
    0.687, 0.193, 0.020, 0, 25, //
    0.057, 0.823, 0.020, 0, 25, //
    0.057, 0.193, 0.650, 0, 25, //
    0, 0, 0, 1, 0, //
  ]);

  static Widget _softenedTile(
    BuildContext context,
    Widget tile,
    TileImage _,
  ) => ColorFiltered(colorFilter: _softened, child: tile);

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

    final style = _styleFor(Theme.of(context).brightness);

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
            // La key cambia con el estilo: al pasar de claro a oscuro,
            // Flutter crea una capa nueva y descarta los tiles del estilo
            // anterior en vez de mezclarlos con los nuevos.
            key: ValueKey(style),
            urlTemplate:
                'https://api.maptiler.com/maps/{style}/256/'
                '{z}/{x}/{y}{r}.png?key={key}',
            additionalOptions: {'style': style, 'key': _mapTilerKey},
            retinaMode: RetinaMode.isHighDensity(context),
            userAgentPackageName: 'com.kumo.app',
          )
        else
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            tileBuilder: _softenedTile,
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
