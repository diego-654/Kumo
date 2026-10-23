import 'package:flutter/foundation.dart';
import 'package:kumo/features/moments/domain/entities/moment_photo.dart';
import 'package:kumo/features/moments/domain/entities/sentiment.dart';

/// Un "momento": lo que el usuario siente en un lugar concreto.
///
/// Es una entidad de dominio pura: no sabe nada de JSON, Firebase ni UI.
/// La foto, la ubicación y la emoción clasificada por IA se añadirán
/// en sus propias tareas.
@immutable
class Moment {
  const new({
    required this.id,
    required this.placeName,
    required this.note,
    required this.createdAt,
    this.photos = const [],
    this.sentiment,
  });

  final String id;
  final String placeName;
  final String note;
  final DateTime createdAt;
  final List<MomentPhoto> photos;
  final Sentiment? sentiment;

  @override
  bool operator ==(Object other) =>
      other is Moment &&
      other.id == id &&
      other.placeName == placeName &&
      other.note == note &&
      other.createdAt == createdAt &&
      listEquals(other.photos, photos) &&
      other.sentiment == sentiment;

  @override
  int get hashCode => Object.hash(
    id,
    placeName,
    note,
    createdAt,
    Object.hashAll(photos),
    sentiment,
  );
}
