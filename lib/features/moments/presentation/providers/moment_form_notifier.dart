import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
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

  @override
  MomentFormState build() => const MomentFormState();

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
