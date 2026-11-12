import 'package:kumo/core/theme/emotion_colors.dart';
import 'package:kumo/core/widget/label_chip.dart';
import 'package:kumo/features/moments/domain/entities/sentiment.dart';
import 'package:kumo/features/moments/presentation/extensions/emotion_style.dart';
import 'package:material_ui/material_ui.dart';

class EmotionChip extends StatelessWidget {
  const new({required this.emotion, super.key});

  final Emotion emotion;

  @override
  Widget build(BuildContext context) {
    final emotions = EmotionColors.of(context);
    return LabelChip(
      label: emotion.label,
      color: emotions.fill(emotion),
      labelColor: emotions.label(emotion),
    );
  }
}
