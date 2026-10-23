import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kumo/features/moments/domain/entities/moment_photo.dart';

/// Traduce la entidad de dominio a lo que la UI sabe dibujar.
/// Usa la foto remota si ya se subió; si no, la local.
extension MomentPhotoImage on MomentPhoto {
  ImageProvider get image => remoteUrl != null
      ? NetworkImage(remoteUrl!)
      : FileImage(File(localPath!));
}
