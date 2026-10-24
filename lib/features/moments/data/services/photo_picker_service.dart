import 'package:image_picker/image_picker.dart';

/// Envuelve `image_picker` para que el resto de la app no dependa del plugin.
///
/// Devuelve rutas locales: con ellas se crean los `MomentPhoto` (`localPath`)
/// antes de subirlos. En tests se reemplaza por un fake vía provider.
class PhotoPickerService {
  new({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// Calidad de compresión (0-100): fotos más livianas, subidas más rápidas.
  static const int _imageQuality = 80;

  /// Abre la cámara. Devuelve `null` si el usuario cancela.
  Future<String?> takePhoto() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: _imageQuality,
    );
    return file?.path;
  }

  /// Abre la galería y deja elegir hasta [max] fotos.
  /// Devuelve una lista vacía si el usuario cancela.
  Future<List<String>> pickFromGallery({required int max}) async {
    if (max <= 0) return const [];

    // `pickMultiImage` exige un límite de 2 o más.
    if (max == 1) {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: _imageQuality,
      );
      return [?file?.path];
    }

    final files = await _picker.pickMultiImage(
      limit: max,
      imageQuality: _imageQuality,
    );
    return files.map((file) => file.path).toList();
  }
}
