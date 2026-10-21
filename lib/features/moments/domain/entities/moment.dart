import 'package:flutter/foundation.dart';

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
  });

  final String id;
  final String placeName;
  final String note;
  final DateTime createdAt;

  @override
  bool operator ==(Object other) =>
      other is Moment &&
      other.id == id &&
      other.placeName == placeName &&
      other.note == note &&
      other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(id, placeName, note, createdAt);
}
