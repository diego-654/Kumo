import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kumo/app/router/app_routes.dart';
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
    final location = _locationAction(form.locationStatus, notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(momentId == null ? 'Nuevo momento' : 'Editar momento'),
      ),
      body: form.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
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
                  detail: _locationDetail(form.locationStatus),
                  detailActionLabel: location.label,
                  onDetailAction: location.onPressed,
                  onChange: () =>
                      _askPlaceName(context, notifier, form.placeName),
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
            // Con `null` el botón se ve deshabilitado solo.
            onPressed: form.canSave ? () => _save(context, notifier) : null,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: form.isSaving
                ? const SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : Text(
                    momentId == null ? 'Guardar momento' : 'Guardar cambios',
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _save(
    BuildContext context,
    MomentFormNotifier notifier,
  ) async {
    final saved = await notifier.save();
    if (!context.mounted) return;

    if (!saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar. Intenta de nuevo.')),
      );
      return;
    }
    // Si se llegó por un enlace directo no hay a dónde volver.
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.moments);
    }
  }

  /// Texto que explica qué pasa con el GPS.
  /// `null` deja el texto por defecto del campo.
  String? _locationDetail(LocationStatus status) => switch (status) {
    LocationStatus.idle => null,
    LocationStatus.loading => 'Buscando tu ubicación…',
    LocationStatus.found => 'Ubicación lista · se mostrará en el mapa',
    LocationStatus.unavailable ||
    LocationStatus.denied ||
    LocationStatus.deniedForever => 'Sin ubicación · no aparecerá en el mapa',
  };

  /// Qué puede hacer el usuario para conseguir la ubicación, si algo.
  ({String? label, VoidCallback? onPressed}) _locationAction(
    LocationStatus status,
    MomentFormNotifier notifier,
  ) => switch (status) {
    LocationStatus.unavailable || LocationStatus.denied => (
      label: 'Reintentar',
      onPressed: notifier.retryLocation,
    ),
    // Negado para siempre: el diálogo del sistema ya no sale; toca Ajustes.
    LocationStatus.deniedForever => (
      label: 'Abrir ajustes',
      onPressed: notifier.openLocationSettings,
    ),
    LocationStatus.idle ||
    LocationStatus.loading ||
    LocationStatus.found => (label: null, onPressed: null),
  };

  /// Temporal hasta tener buscador de lugares: escribir el nombre a mano.
  /// (Las coordenadas ya llegan solas por GPS.)
  Future<void> _askPlaceName(
    BuildContext context,
    MomentFormNotifier notifier,
    String current,
  ) async {
    var value = current;
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Dónde estás?'),
        content: TextFormField(
          initialValue: current,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Ej. Café Central'),
          onChanged: (text) => value = text,
          onFieldSubmitted: (text) => Navigator.pop(dialogContext, text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, value),
            child: const Text('Listo'),
          ),
        ],
      ),
    );
    if (result != null) notifier.setPlaceName(result.trim());
  }
}
