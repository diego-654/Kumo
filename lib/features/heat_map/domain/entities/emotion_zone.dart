import 'package:flutter/material.dart';
import 'package:kumo/core/location/geo_point.dart';
import 'package:kumo/features/moments/domain/entities/sentiment.dart';

@immutable
class EmotionZone {
  const new({
    required this.center,
    required this.dominant,
    required this.momentCount,
  });

  final GeoPoint center; // centro de la celda
  final Emotion dominant; // emoción que más pesa
  final int momentCount; // para la intensidad
}
