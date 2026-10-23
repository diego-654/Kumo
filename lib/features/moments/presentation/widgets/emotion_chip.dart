import 'package:flutter/material.dart';
import 'package:kumo/core/widget/label_chip.dart';
import 'package:kumo/features/moments/domain/entities/sentiment.dart';
import 'package:kumo/features/moments/presentation/extensions/emotion_style.dart';

class EmotionChip extends StatelessWidget {
  const new({required this.emotion, super.key});

  final Emotion emotion;

  @override
  Widget build(BuildContext context) {
    return LabelChip(
      label: emotion.label,
      color: emotion.color,
      labelColor: emotion.labelColor,
    );
  }
}
