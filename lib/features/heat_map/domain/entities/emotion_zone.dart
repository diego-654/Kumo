import 'package:flutter/material.dart';
import 'package:kumo/core/location/geo_point.dart';
import 'package:kumo/features/moments/domain/entities/moment.dart';
import 'package:kumo/features/moments/domain/entities/sentiment.dart';

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
}
