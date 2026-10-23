/// Rutas centralizadas: evita strings mágicos repartidos por la app.
abstract final class AppRoutes {
  static const heatMap = '/map';
  static const moments = '/moments';
  static String momentDetail(String id) => '$moments/$id';
}
