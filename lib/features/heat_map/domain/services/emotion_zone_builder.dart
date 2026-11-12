import 'package:kumo/core/location/geo_point.dart';
import 'package:kumo/features/heat_map/domain/entities/emotion_zone.dart';
import 'package:kumo/features/moments/domain/entities/moment.dart';
import 'package:kumo/features/moments/domain/entities/sentiment.dart';

/// Agrupa momentos en celdas de una cuadrícula y calcula la emoción
/// dominante de cada celda.
class EmotionZoneBuilder {
  const new({this.cellSizeDegrees = 0.003}); // ~300 m en CDMX

  final double cellSizeDegrees;

  /// (fila, columna) de la celda donde cae [point]. La usan el builder y la
  /// pantalla al tocar el mapa, así la fórmula vive en un solo sitio.
  (int, int) cellOf(GeoPoint point) => (
    (point.latitude / cellSizeDegrees).floor(),
    (point.longitude / cellSizeDegrees).floor(),
  );

  List<EmotionZone> build(List<Moment> moments) {
    final cells = <(int, int), List<Moment>>{};
    for (final m in moments) {
      final loc = m.location;
      if (loc == null || m.sentiment == null) continue;
      (cells[cellOf(loc)] ??= []).add(m);
    }

    return [
      for (final MapEntry(key: cell, value: group) in cells.entries)
        EmotionZone(
          cell: cell,
          center: GeoPoint(
            latitude: (cell.$1 + 0.5) * cellSizeDegrees,
            longitude: (cell.$2 + 0.5) * cellSizeDegrees,
          ),
          dominant: _dominant(group),
          breakdown: _breakdown(group),
          moments: List.unmodifiable(group),
        ),
    ];
  }

  /// Cuántos momentos hay de cada emoción.
  Map<Emotion, int> _breakdown(List<Moment> group) {
    final counts = <Emotion, int>{};
    for (final m in group) {
      final emotion = m.sentiment!.emotion;
      counts[emotion] = (counts[emotion] ?? 0) + 1;
    }
    return Map.unmodifiable(counts);
  }

  /// La emoción que más suma, pesando cada momento por su confianza.
  Emotion _dominant(List<Moment> group) {
    final scores = <Emotion, double>{};
    for (final m in group) {
      final s = m.sentiment!;
      scores[s.emotion] = (scores[s.emotion] ?? 0) + s.confidence;
    }
    return scores.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }
}
