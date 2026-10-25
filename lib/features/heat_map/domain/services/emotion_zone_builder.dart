import 'package:kumo/core/location/geo_point.dart';
import 'package:kumo/features/heat_map/domain/entities/emotion_zone.dart';
import 'package:kumo/features/moments/domain/entities/moment.dart';
import 'package:kumo/features/moments/domain/entities/sentiment.dart';

/// Agrupa momentos en celdas de una cuadrícula y calcula la emoción
/// dominante de cada celda.
class EmotionZoneBuilder {
  const new({this.cellSizeDegrees = 0.003}); // ~300 m en CDMX

  final double cellSizeDegrees;

  List<EmotionZone> build(List<Moment> moments) {
    final cells = <(int, int), List<Moment>>{};
    for (final m in moments) {
      final loc = m.location;
      if (loc == null || m.sentiment == null) continue;
      final cell = (
        (loc.latitude / cellSizeDegrees).floor(),
        (loc.longitude / cellSizeDegrees).floor(),
      );
      (cells[cell] ??= []).add(m);
    }

    return [
      for (final MapEntry(key: cell, value: group) in cells.entries)
        EmotionZone(
          center: GeoPoint(
            latitude: (cell.$1 + 0.5) * cellSizeDegrees,
            longitude: (cell.$2 + 0.5) * cellSizeDegrees,
          ),
          dominant: _dominant(group),
          momentCount: group.length,
        ),
    ];
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
