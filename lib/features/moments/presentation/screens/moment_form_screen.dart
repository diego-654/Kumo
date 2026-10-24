import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumo/features/moments/presentation/providers/moment_form_notifier.dart';
import 'package:kumo/features/moments/presentation/providers/moment_form_state.dart';
import 'package:kumo/features/moments/presentation/widgets/moment_note_field.dart';
import 'package:kumo/features/moments/presentation/widgets/moment_photos_field.dart';
import 'package:kumo/features/moments/presentation/widgets/moment_place_field.dart';
import 'package:kumo/features/moments/presentation/widgets/moment_share_field.dart';

/// Crear (`momentId == null`) o editar un momento (pantalla 8 del boceto).
///
/// Solo arma las secciones y las conecta con el notifier.
class MomentFormScreen extends ConsumerWidget {
  const new({this.momentId, super.key});

  final String? momentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(momentFormProvider(momentId));
    final notifier = ref.read(momentFormProvider(momentId).notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(momentId == null ? 'Nuevo momento' : 'Editar momento'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          MomentPhotosField(
            photos: form.photos,
            maxPhotos: MomentFormState.maxPhotos,
            onAddFromCamera: notifier.addFromCamera,
            onAddFromGallery: notifier.addFromGallery,
            onRetake: notifier.retakePhoto,
            onRemove: notifier.removePhoto,
          ),
          const SizedBox(height: 24),
          MomentPlaceField(
            placeName: form.placeName,
            // Pendiente: abrir el buscador de lugares.
            onChange: () {},
          ),
          const SizedBox(height: 24),
          MomentNoteField(
            initialValue: form.note,
            minLength: MomentFormState.minNoteLength,
            onChanged: notifier.setNote,
          ),
          const SizedBox(height: 24),
          MomentShareField(
            isPublic: form.isPublic,
            onChanged: (value) => notifier.setIsPublic(value: value),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: FilledButton(
            // Pendiente: `form.isValid ? notifier.save : null`. Con `null`
            // el botón se ve deshabilitado solo.
            onPressed: () {},
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: Text(
              momentId == null ? 'Guardar momento' : 'Guardar cambios',
            ),
          ),
        ),
      ),
    );
  }
}
