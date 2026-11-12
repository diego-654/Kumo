import 'package:kumo/features/moments/domain/entities/sentiment.dart';
import 'package:kumo/features/moments/presentation/extensions/emotion_style.dart';
import 'package:material_ui/material_ui.dart';

/// Barra con el reparto de emociones y su leyenda en dos columnas. La usan
/// la hoja de zona (boceto 5) y el detalle del lugar (boceto 6).
class EmotionBreakdown extends StatelessWidget {
  const new({required this.breakdown, super.key});

  /// Cuántos momentos hay de cada emoción.
  final Map<Emotion, int> breakdown;

  @override
  Widget build(BuildContext context) {
    // De mayor a menor, sin las emociones que no aparecen.
    final entries = breakdown.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (entries.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cada tramo ocupa un ancho proporcional a sus momentos (flex).
        ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: SizedBox(
            height: 14,
            child: Row(
              // Sin stretch, ColoredBox (que no tiene hijo) toma alto 0.
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final e in entries)
                  Expanded(
                    flex: e.value,
                    child: ColoredBox(color: e.key.color),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            const gap = 16.0;
            final itemWidth = (constraints.maxWidth - gap) / 2;
            return Wrap(
              spacing: gap,
              runSpacing: 6,
              children: [
                for (final e in entries)
                  SizedBox(
                    width: itemWidth,
                    child: _LegendItem(emotion: e.key),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const new({required this.emotion});

  final Emotion emotion;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: emotion.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            emotion.label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF3C3F4E)),
          ),
        ),
      ],
    );
  }
}
