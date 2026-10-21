import 'package:flutter/material.dart';

/// Tema Material 3 generado a partir de un único color semilla.
abstract final class AppTheme {
  static const _seed = Color(0xFF5B6CFF);

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );
    return ThemeData(
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colorScheme.surface,
      ),
    );
  }
}
