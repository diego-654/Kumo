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

  // Los colores viven en el tema: ver `EmotionColors` (core/theme).
}
