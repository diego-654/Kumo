import 'package:kumo/features/moments/domain/entities/sentiment.dart';
import 'package:material_ui/material_ui.dart';

/// Colores de las emociones como parte del tema.
///
/// `ColorScheme` solo trae roles genéricos (primary, surface...), así que
/// los colores propios de Kumo viajan en una `ThemeExtension`. Ventajas:
/// - Hay una versión clara y otra oscura, y Flutter elige sola según el
///   tema activo (también si el usuario cambia el modo del sistema).
/// - `lerp` permite que la transición entre temas sea animada.
///
/// Uso: `final emotions = EmotionColors.of(context);`
/// `emotions.fill(Emotion.calma)` o `emotions.label(Emotion.calma)`.
@immutable
class EmotionColors extends ThemeExtension<EmotionColors> {
  const new({required this.fills, required this.labels});

  /// Color de relleno: puntos, barras, zonas del mapa y fondos tenues.
  /// Son tonos medios, así que sirven igual en claro y en oscuro.
  final Map<Emotion, Color> fills;

  /// Color de texto e iconos sobre un fondo tenue de la emoción. En claro
  /// es un tono oscuro; en oscuro, uno claro, para que siempre contraste.
  final Map<Emotion, Color> labels;

  static const Map<Emotion, Color> _fills = {
    Emotion.alegria: Color(0xFFF5B83D),
    Emotion.calma: Color(0xFF3BB5A6),
    Emotion.nostalgia: Color(0xFF9B7BD9),
    Emotion.tristeza: Color(0xFF4A86E8),
    Emotion.enojo: Color(0xFFE5484D), // rojo coral
    Emotion.miedo: Color(0xFF64748B), // gris pizarra
  };

  static const light = EmotionColors(
    fills: _fills,
    labels: {
      Emotion.alegria: Color(0xFF6B4A00),
      Emotion.calma: Color(0xFF0E5A51),
      Emotion.nostalgia: Color(0xFF4A2F8F),
      Emotion.tristeza: Color(0xFF1F4E9C),
      Emotion.enojo: Color(0xFF8E1B1F),
      Emotion.miedo: Color(0xFF334155),
    },
  );

  static const dark = EmotionColors(
    fills: _fills,
    labels: {
      Emotion.alegria: Color(0xFFFFD98A),
      Emotion.calma: Color(0xFF8EE0D5),
      Emotion.nostalgia: Color(0xFFD3C2F7),
      Emotion.tristeza: Color(0xFFADCBFA),
      Emotion.enojo: Color(0xFFFFB0B2),
      Emotion.miedo: Color(0xFFCBD5E1),
    },
  );

  /// Lee la extensión del tema. Si falta (p. ej. un test con
  /// `MaterialApp` sin nuestro tema), usa la paleta según el brillo.
  static EmotionColors of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<EmotionColors>() ??
        (theme.brightness == Brightness.dark ? dark : light);
  }

  Color fill(Emotion emotion) => fills[emotion]!;
  Color label(Emotion emotion) => labels[emotion]!;

  @override
  EmotionColors copyWith({
    Map<Emotion, Color>? fills,
    Map<Emotion, Color>? labels,
  }) =>
      EmotionColors(fills: fills ?? this.fills, labels: labels ?? this.labels);

  @override
  EmotionColors lerp(EmotionColors? other, double t) {
    if (other == null) return this;
    Map<Emotion, Color> mix(Map<Emotion, Color> a, Map<Emotion, Color> b) => {
      for (final e in Emotion.values) e: Color.lerp(a[e], b[e], t)!,
    };
    return EmotionColors(
      fills: mix(fills, other.fills),
      labels: mix(labels, other.labels),
    );
  }
}
