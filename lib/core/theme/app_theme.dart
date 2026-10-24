import 'package:flutter/material.dart';

/// Tema Material 3 de Kumo.
///
/// La paleta vive aquí: los widgets leen los colores con
/// `Theme.of(context).colorScheme` y nunca escriben un `Color(0x...)`.
abstract final class AppTheme {
  static const _seed = Color(0xFF3442D9);

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final generated = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );
    // En claro fijamos los tonos exactos del boceto. En oscuro dejamos los
    // que genera la semilla, que ya tienen buen contraste.
    final colorScheme = brightness == Brightness.light
        ? generated.copyWith(
            primary: const Color(0xFF3442D9),
            onSurface: const Color(0xFF1B1C24),
            onSurfaceVariant: const Color(0xFF555869),
            surfaceContainerLow: const Color(0xFFF4F5FB),
            outlineVariant: const Color(0xFFC9CCDB),
            error: const Color(0xFF9B1C1C),
            errorContainer: const Color(0xFFFCEBEB),
          )
        : generated;
    final inputRadius = BorderRadius.circular(12);
    return ThemeData(
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colorScheme.surface,
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: colorScheme.surface,
        hintStyle: TextStyle(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(borderRadius: inputRadius),
        enabledBorder: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
