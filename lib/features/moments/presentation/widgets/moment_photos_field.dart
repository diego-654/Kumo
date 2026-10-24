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

    // Anima el pequeño cambio de alto cuando aparece el contador.
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          // El contador solo aparece cuando ya hay fotos: antes no aporta.
          if (photos.isNotEmpty)
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
              onTap: () => _showAddOptions(context),
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
      ),
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

/// Estado vacío: un solo recuadro que se toca completo.
///
/// Mide lo mismo que la tira de miniaturas para que la pantalla no salte al
/// agregar la primera foto.
/// Cámara y Galería aparecen en el menú al tocarlo, no antes.
class _EmptyPhotos extends StatelessWidget {
  const new({required this.maxPhotos, required this.onTap});

  final int maxPhotos;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      height: _PhotoThumb.size,
      width: double.infinity,
      child: Material(
        color: colors.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colors.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 4,
            children: [
              Icon(
                Icons.add_a_photo_outlined,
                size: 32,
                color: colors.primary,
              ),
              Text(
                'Agregar fotos',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Hasta $maxPhotos',
                style: textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
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
