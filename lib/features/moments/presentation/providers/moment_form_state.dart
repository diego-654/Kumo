import 'package:flutter/foundation.dart';
import 'package:kumo/features/moments/domain/entities/moment_photo.dart';

/// Borrador de la pantalla "Nuevo momento" / "Editar momento".
///
/// Es estado de UI, no una entidad: se convierte en `Moment` al guardar.
@immutable
class MomentFormState {
  const new({
    this.photos = const [],
    this.placeName = '',
    this.note = '',
    this.isPublic = true,
  });

  static const int maxPhotos = 5;

  /// Mínimo de caracteres para que la IA tenga contexto suficiente.
  static const int minNoteLength = 20;

  final List<MomentPhoto> photos;
  final String placeName;
  final String note;

  /// Si se muestra en el mapa público o solo para su autor.
  final bool isPublic;

  bool get canAddPhotos => photos.length < maxPhotos;
  int get remainingPhotos => maxPhotos - photos.length;

  bool get isValid =>
      photos.isNotEmpty &&
      placeName.trim().isNotEmpty &&
      note.trim().isNotEmpty;

  MomentFormState copyWith({
    List<MomentPhoto>? photos,
    String? placeName,
    String? note,
    bool? isPublic,
  }) {
    return MomentFormState(
      photos: photos ?? this.photos,
      placeName: placeName ?? this.placeName,
      note: note ?? this.note,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is MomentFormState &&
      listEquals(other.photos, photos) &&
      other.placeName == placeName &&
      other.note == note &&
      other.isPublic == isPublic;

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(photos), placeName, note, isPublic);
}
