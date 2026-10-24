import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:kumo/features/moments/domain/entities/moment.dart';
import 'package:kumo/features/moments/domain/entities/moment_photo.dart';
import 'package:kumo/features/moments/presentation/providers/moment_form_state.dart';
import 'package:kumo/features/moments/presentation/providers/moments_providers.dart';

/// Un borrador por pantalla: `momentFormProvider(null)` para crear y
/// `momentFormProvider(id)` para editar. `autoDispose` lo borra al salir.
final NotifierProviderFamily<MomentFormNotifier, MomentFormState, String?>
momentFormProvider = NotifierProvider.autoDispose
    .family<MomentFormNotifier, MomentFormState, String?>(
      MomentFormNotifier.new,
    );

class MomentFormNotifier extends Notifier<MomentFormState> {
  new(this.momentId);

  /// `null` = crear; con valor = editar ese momento.
  final String? momentId;

  bool get isEditing => momentId != null;

  /// El momento tal como estaba antes de editarlo. Al guardar se parte de
  /// él para conservar lo que el formulario no toca (`createdAt`, emoción).
  Moment? _original;

  @override
  MomentFormState build() {
    final id = momentId;
    if (id == null) return const MomentFormState();

    // `build` no puede ser async: arrancamos la carga y mientras tanto la
    // pantalla muestra un indicador.
    unawaited(_loadMoment(id));
    return const MomentFormState(isLoading: true);
  }

  Future<void> _loadMoment(String id) async {
    final moment = await ref.read(momentsRepositoryProvider).getMomentById(id);
    if (!ref.mounted) return;
    _original = moment;
    state = moment == null
        ? const MomentFormState()
        : MomentFormState(
            photos: moment.photos,
            placeName: moment.placeName,
            note: moment.note,
            isPublic: moment.isPublic,
          );
  }

  // --- Fotos ---------------------------------------------------------------

  Future<void> addFromCamera() async {
    if (!state.canAddPhotos) return;
    final path = await ref.read(photoPickerServiceProvider).takePhoto();
    // Mientras la cámara estaba abierta, el usuario pudo salir de la pantalla.
    if (path == null || !ref.mounted) return;
    _addPaths([path]);
  }

  Future<void> addFromGallery() async {
    if (!state.canAddPhotos) return;
    final paths = await ref
        .read(photoPickerServiceProvider)
        .pickFromGallery(max: state.remainingPhotos);
    if (paths.isEmpty || !ref.mounted) return;
    _addPaths(paths);
  }

  /// "Repetir foto": abre la cámara y reemplaza la foto en [index].
  Future<void> retakePhoto(int index) async {
    final path = await ref.read(photoPickerServiceProvider).takePhoto();
    if (path == null || !ref.mounted) return;
    state = state.copyWith(
      photos: [...state.photos]..[index] = _newPhoto(path),
    );
  }

  void removePhoto(int index) {
    state = state.copyWith(photos: [...state.photos]..removeAt(index));
  }

  // --- Texto ---------------------------------------------------------------

  void setPlaceName(String value) => state = state.copyWith(placeName: value);

  void setNote(String value) => state = state.copyWith(note: value);

  void setIsPublic({required bool value}) =>
      state = state.copyWith(isPublic: value);

  // --- Guardar ------------------------------------------------------------

  /// Guarda el borrador. Devuelve `true` si salió bien; la pantalla decide
  /// qué hacer después (cerrar o avisar del error).
  Future<bool> save() async {
    if (!state.canSave) return false;
    state = state.copyWith(isSaving: true);

    final moment = _toMoment();
    try {
      await ref.read(momentsRepositoryProvider).saveMoment(moment);
    } on Exception {
      if (ref.mounted) state = state.copyWith(isSaving: false);
      return false;
    }

    // Si el usuario salió mientras se guardaba, ya no podemos usar `ref`.
    if (!ref.mounted) return true;
    // La lista y el detalle vuelven a leer el repositorio.
    ref
      ..invalidate(momentsProvider)
      ..invalidate(momentByIdProvider(moment.id));
    state = state.copyWith(isSaving: false);
    return true;
  }

  Moment _toMoment() {
    final placeName = state.placeName.trim();
    final note = state.note.trim();
    final original = _original;

    if (original != null) {
      // Pendiente: si cambió la nota, volver a pedir la emoción a la IA.
      return original.copyWith(
        placeName: placeName,
        note: note,
        photos: state.photos,
        isPublic: state.isPublic,
      );
    }
    return Moment(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      placeName: placeName,
      note: note,
      createdAt: DateTime.now(),
      photos: state.photos,
      isPublic: state.isPublic,
    );
  }

  // --- Privados ------------------------------------------------------------

  void _addPaths(List<String> paths) {
    // `take` evita pasarse del máximo aunque la galería devuelva de más.
    final newPhotos = paths.take(state.remainingPhotos).map(_newPhoto);
    state = state.copyWith(photos: [...state.photos, ...newPhotos]);
  }

  // Las fotos nuevas solo existen en el teléfono: `localPath`, sin URL.
  MomentPhoto _newPhoto(String path) => MomentPhoto(
    id: '${DateTime.now().microsecondsSinceEpoch}_${path.hashCode}',
    localPath: path,
  );
}
