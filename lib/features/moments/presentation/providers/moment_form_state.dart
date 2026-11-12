import 'package:flutter/foundation.dart';
import 'package:kumo/core/location/geo_point.dart';
import 'package:kumo/features/moments/domain/entities/moment_photo.dart';

/// En qué va la búsqueda de la ubicación GPS del momento.
enum LocationStatus {
  /// No se pidió (p. ej. al editar un momento que no tenía ubicación).
  idle,
  loading,
  found,

  /// GPS apagado o sin señal: se puede reintentar.
  unavailable,

  /// El usuario negó el permiso: se le puede volver a preguntar.
  denied,

  /// Negado para siempre: solo se arregla desde Ajustes.
  deniedForever,
}

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
    this.isLoading = false,
    this.isSaving = false,
    this.location,
    this.locationStatus = LocationStatus.idle,
  });

  static const int maxPhotos = 5;

  /// Mínimo de caracteres para que la IA tenga contexto suficiente.
  static const int minNoteLength = 20;

  final List<MomentPhoto> photos;
  final String placeName;
  final String note;

  /// Si se muestra en el mapa público o solo para su autor.
  final bool isPublic;

  /// Al editar: mientras se lee el momento del repositorio.
  final bool isLoading;

  /// Mientras se guarda: evita dobles toques en el botón.
  final bool isSaving;

  /// Dónde se creó el momento. Opcional: sin ella se guarda igual, pero no
  /// aparece en el mapa.
  final GeoPoint? location;
  final LocationStatus locationStatus;

  bool get canAddPhotos => photos.length < maxPhotos;
  int get remainingPhotos => maxPhotos - photos.length;

  bool get isValid =>
      photos.isNotEmpty &&
      placeName.trim().isNotEmpty &&
      note.trim().length >= minNoteLength;

  bool get canSave => isValid && !isLoading && !isSaving;

  MomentFormState copyWith({
    List<MomentPhoto>? photos,
    String? placeName,
    String? note,
    bool? isPublic,
    bool? isLoading,
    bool? isSaving,
    GeoPoint? location,
    LocationStatus? locationStatus,
  }) {
    return MomentFormState(
      photos: photos ?? this.photos,
      placeName: placeName ?? this.placeName,
      note: note ?? this.note,
      isPublic: isPublic ?? this.isPublic,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      // Con `??` no se puede volver a `null`; hoy no hace falta borrarla.
      location: location ?? this.location,
      locationStatus: locationStatus ?? this.locationStatus,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is MomentFormState &&
      listEquals(other.photos, photos) &&
      other.placeName == placeName &&
      other.note == note &&
      other.isPublic == isPublic &&
      other.isLoading == isLoading &&
      other.isSaving == isSaving &&
      other.location == location &&
      other.locationStatus == locationStatus;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(photos),
    placeName,
    note,
    isPublic,
    isLoading,
    isSaving,
    location,
    locationStatus,
  );
}
