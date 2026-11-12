import 'package:flutter/material.dart';
import 'package:kumo/core/location/geo_point.dart';
import 'package:kumo/features/moments/domain/entities/moment.dart';
import 'package:kumo/features/moments/domain/entities/moment_photo.dart';
import 'package:kumo/features/moments/domain/entities/sentiment.dart';

/// Un lugar dentro de una zona: su nombre, la emoción que más se repite
/// ahí, cuántos momentos tiene y una foto de portada si alguno trae foto
/// (para "Lugares destacados" del boceto 5).
typedef ZonePlace = ({
  String name,
  Emotion dominant,
  int momentCount,
  MomentPhoto? cover,
});

@immutable
class EmotionZone {
  const new({
    required this.cell,
    required this.center,
    required this.dominant,
    required this.breakdown,
    required this.moments,
  });

  /// (fila, columna) en la cuadrícula. Sirve para saber qué zona se tocó.
  final (int, int) cell;
  final GeoPoint center; // centro de la celda
  final Emotion dominant; // emoción que más pesa

  /// Cuántos momentos hay de cada emoción (para la barra del boceto 5).
  final Map<Emotion, int> breakdown;

  /// Los momentos de la zona (para sacar sus lugares destacados).
  final List<Moment> moments;

  int get momentCount => moments.length; // para la intensidad

  /// Lugares de la zona agrupando los momentos por `placeName`, del que
  /// tiene más momentos al que tiene menos.
  List<ZonePlace> get places {
    final byName = <String, List<Moment>>{};
    for (final moment in moments) {
      (byName[moment.placeName] ??= []).add(moment);
    }
    return [
      for (final MapEntry(key: name, value: list) in byName.entries)
        (
          name: name,
          dominant: _dominantOf(list),
          momentCount: list.length,
          cover: list.expand((m) => m.photos).firstOrNull,
        ),
    ]..sort((a, b) => b.momentCount.compareTo(a.momentCount));
  }

  /// La emoción que más se repite en [list]. Si ninguno tiene emoción,
  /// usa la dominante de la zona.
  Emotion _dominantOf(List<Moment> list) {
    final counts = <Emotion, int>{};
    for (final sentiment in list.map((m) => m.sentiment).nonNulls) {
      counts.update(sentiment.emotion, (n) => n + 1, ifAbsent: () => 1);
    }
    if (counts.isEmpty) return dominant;
    return counts.entries.reduce((a, b) => b.value > a.value ? b : a).key;
  }
}
