import 'package:kumo/core/theme/emotion_colors.dart';
import 'package:kumo/features/moments/domain/entities/sentiment.dart';
import 'package:kumo/features/moments/presentation/extensions/emotion_style.dart';
import 'package:material_ui/material_ui.dart';

/// Botón del mapa que explica qué significa cada color.
///
/// Quien abre Kumo por primera vez ve manchas de colores sin contexto: una
/// leyenda a un toque es la forma más barata de que el mapa se entienda.
class EmotionLegendButton extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      heroTag: 'emotion-legend',
      tooltip: 'Qué significan los colores',
      onPressed: () => showModalBottomSheet<void>(
        context: context,
        // Por encima de la barra de navegación, no debajo de ella: la barra
        // vive en el shell y el navigator de la pestaña queda por debajo.
        useRootNavigator: true,
        showDragHandle: true,
        builder: (_) => const EmotionLegendSheet(),
      ),
      child: const Icon(Icons.palette_outlined),
    );
  }
}

class EmotionLegendSheet extends StatelessWidget {
  const new({super.key});

  static String _meaning(Emotion emotion) => switch (emotion) {
    Emotion.alegria => 'La gente la pasa bien aquí',
    Emotion.calma => 'Un lugar tranquilo para estar',
    Emotion.nostalgia => 'Despierta recuerdos',
    Emotion.tristeza => 'Momentos difíciles o despedidas',
    Emotion.enojo => 'Algo molesta: tráfico, filas, ruido',
    Emotion.miedo => 'La gente se siente insegura',
  };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final emotions = EmotionColors.of(context);

    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        children: [
          Text('Cómo leer el mapa', style: textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Cada zona toma el color de la emoción que más se repite en '
            'los momentos de ese lugar. Cuanto más intenso, más momentos.',
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          for (final emotion in Emotion.values)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: emotions.fill(emotion),
                  shape: BoxShape.circle,
                ),
              ),
              title: Text(emotion.label, style: textTheme.titleMedium),
              subtitle: Text(_meaning(emotion)),
            ),
        ],
      ),
    );
  }
}
