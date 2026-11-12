/// Rutas centralizadas: evita strings mágicos repartidos por la app.
abstract final class AppRoutes {
  static const heatMap = '/map';
  static const moments = '/moments';
  static String momentDetail(String id) => '$moments/$id';
  static const newMoment = '/new-moment';
  static String editMoment(String id) => '$moments/$id/edit';

  /// Detalle de un lugar. Mientras no haya id propio, el id es el nombre
  /// codificado (los espacios y tildes no pueden ir tal cual en la URL).
  static const placeDetailPath = '/place/:id';
  static String placeDetail(String placeName) =>
      '/place/${Uri.encodeComponent(placeName)}';
}
