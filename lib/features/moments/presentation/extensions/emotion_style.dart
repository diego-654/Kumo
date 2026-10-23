import 'dart:ui';

import 'package:kumo/features/moments/domain/entities/sentiment.dart';

extension EmotionStyle on Emotion {
  String get label => switch (this) {
    Emotion.alegria => 'Alegría',
    Emotion.calma => 'Calma',
    Emotion.nostalgia => 'Nostalgia',
    Emotion.tristeza => 'Tristeza',
    Emotion.enojo => 'Enojo',
    Emotion.miedo => 'Miedo',
  };

  Color get color => switch (this) {
    Emotion.alegria => const Color(0xFFF5B83D),
    Emotion.calma => const Color(0xFF3BB5A6),
    Emotion.nostalgia => const Color(0xFF9B7BD9),
    Emotion.tristeza => const Color(0xFF4A86E8),
    Emotion.enojo => const Color(0xFFE5484D), // rojo coral
    Emotion.miedo => const Color(0xFF64748B), // gris pizarra
  };

  Color get labelColor => switch (this) {
    Emotion.alegria => const Color(0xFF6B4A00),
    Emotion.calma => const Color(0xFF0E5A51),
    Emotion.nostalgia => const Color(0xFF4A2F8F),
    Emotion.tristeza => const Color(0xFF1F4E9C),
    Emotion.enojo => const Color(0xFF8E1B1F),
    Emotion.miedo => const Color(0xFF334155),
  };
}
