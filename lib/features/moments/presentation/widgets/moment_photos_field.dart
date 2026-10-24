import 'package:flutter/material.dart';
import 'package:kumo/core/widget/photo_placeholder.dart';
import 'package:kumo/features/moments/domain/entities/moment_photo.dart';
import 'package:kumo/features/moments/presentation/extensions/moment_photo_image.dart';

/// Sección de fotos del formulario (pantalla 8 del boceto, con varias fotos).
///
/// Solo dibuja y avisa con callbacks: no sabe nada de Riverpod ni de la
/// cámara. Sin fotos muestra un bloque grande para empezar; con fotos, una
/// tira horizontal de miniaturas y un `+` al final.
class MomentPhotosField extends StatelessWidget {
  const new({
    required this.photos,
    required this.maxPhotos,
    required this.onAddFromCamera,
    required this.onAddFromGallery,
    required this.onRetake,
    required this.onRemove,
    super.key,
  });

  final List<MomentPhoto> photos;
  final int maxPhotos;
  final VoidCallback onAddFromCamera;
  final VoidCallback onAddFromGallery;
  final ValueChanged<int> onRetake;
  final ValueChanged<int> onRemove;

  bool get _canAdd => photos.length < maxPhotos;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Fotos',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${photos.length} / $maxPhotos',
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        if (photos.isEmpty)
          _EmptyPhotos(
            maxPhotos: maxPhotos,
            onCamera: onAddFromCamera,
            onGallery: onAddFromGallery,
          )
        else
          SizedBox(
            height: _PhotoThumb.size,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length + (_canAdd ? 1 : 0),
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                if (index == photos.length) {
                  return _AddTile(onTap: () => _showAddOptions(context));
                }
                return _PhotoThumb(
                  photo: photos[index],
                  isCover: index == 0,
                  onTap: () => _showPhotoOptions(context, index),
                );
              },
            ),
          ),
      ],
    );
  }

  Future<void> _showAddOptions(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Tomar foto'),
              onTap: () {
                Navigator.pop(sheetContext);
                onAddFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Elegir de galería'),
              onTap: () {
                Navigator.pop(sheetContext);
                onAddFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPhotoOptions(BuildContext context, int index) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final error = Theme.of(sheetContext).colorScheme.error;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.replay),
                title: const Text('Repetir foto'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  onRetake(index);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: error),
                title: Text('Quitar', style: TextStyle(color: error)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  onRemove(index);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Estado vacío: invita a tomar la primera foto, la acción principal.
class _EmptyPhotos extends StatelessWidget {
  const new({
    required this.maxPhotos,
    required this.onCamera,
    required this.onGallery,
  });

  final int maxPhotos;
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        spacing: 12,
        children: [
          Icon(Icons.add_a_photo_outlined, size: 40, color: colors.primary),
          Text(
            'Fotografía el lugar',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'Puedes agregar hasta $maxPhotos fotos. '
            'La primera será la portada.',
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onCamera,
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Cámara'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onGallery,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Galería'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.onSurface,
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PhotoThumb extends StatelessWidget {
  const new({
    required this.photo,
    required this.isCover,
    required this.onTap,
  });

  static const double size = 120;

  final MomentPhoto photo;
  final bool isCover;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox.square(
          dimension: size,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image(
                image: photo.image,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const PhotoPlaceholder(),
              ),
              if (isCover)
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: colors.inverseSurface.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Portada',
                      style: TextStyle(
                        color: colors.onInverseSurface,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  const new({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox.square(
          dimension: _PhotoThumb.size,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 6,
            children: [
              Icon(Icons.add, color: colors.primary, size: 28),
              Text(
                'Agregar',
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
