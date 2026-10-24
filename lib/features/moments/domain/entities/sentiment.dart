import 'package:flutter/foundation.dart';

enum Emotion { alegria, calma, nostalgia, tristeza, enojo, miedo }

@immutable
class Sentiment {
  const new({
    required this.emotion,
    required this.confidence,
    this.correctedByUser = false,
  });

  final Emotion emotion;
  final double confidence; // 0.0 a 1.0
  final bool correctedByUser;

  /// El usuario corrige la emoción que detectó la IA.
  Sentiment correctTo(Emotion newEmotion) =>
      copyWith(emotion: newEmotion, correctedByUser: true);

  Sentiment copyWith({
    Emotion? emotion,
    double? confidence,
    bool? correctedByUser,
  }) {
    return Sentiment(
      emotion: emotion ?? this.emotion,
      confidence: confidence ?? this.confidence,
      correctedByUser: correctedByUser ?? this.correctedByUser,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Sentiment &&
      other.emotion == emotion &&
      other.confidence == confidence &&
      other.correctedByUser == correctedByUser;

  @override
  int get hashCode => Object.hash(emotion, confidence, correctedByUser);
}
