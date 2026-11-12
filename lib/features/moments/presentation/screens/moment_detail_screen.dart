import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kumo/app/router/app_routes.dart';
import 'package:kumo/core/extensions/date_time_extensions.dart';
import 'package:kumo/core/theme/emotion_colors.dart';
import 'package:kumo/core/widget/error_view.dart';
import 'package:kumo/core/widget/photo_carousel.dart';
import 'package:kumo/features/heat_map/presentation/providers/heat_map_providers.dart';
import 'package:kumo/features/moments/domain/entities/moment.dart';
import 'package:kumo/features/moments/domain/entities/sentiment.dart';
import 'package:kumo/features/moments/presentation/extensions/emotion_style.dart';
import 'package:kumo/features/moments/presentation/extensions/moment_photo_image.dart';
import 'package:kumo/features/moments/presentation/providers/moment_actions.dart';
import 'package:kumo/features/moments/presentation/providers/moments_providers.dart';
import 'package:kumo/features/moments/presentation/widgets/emotion_chip.dart';
import 'package:material_ui/material_ui.dart';

/// Detalle de un momento (pantalla 11 del boceto).
///
/// Solo recibe el id por la URL; busca el momento con un provider.
class MomentDetailScreen extends ConsumerWidget {
  const new({required this.momentId, super.key});

  final String momentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final momentAsync = ref.watch(momentByIdProvider(momentId));

    return Scaffold(
      appBar: AppBar(),
      body: momentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => ErrorView(
          message: 'No pudimos cargar este momento.',
          onRetry: () => ref.invalidate(momentByIdProvider(momentId)),
        ),
        data: (moment) => moment == null
            ? const Center(child: Text('Este momento ya no existe'))
            : _MomentView(
                moment,
                onCorrectEmotion: (emotion) => ref
                    .read(momentActionsProvider)
                    .correctEmotion(moment, emotion),
              ),
      ),
      // Fijos al fondo; solo cuando el momento existe.
      bottomNavigationBar: switch (momentAsync) {
        AsyncData(value: final moment?) => SafeArea(
          minimum: const EdgeInsets.all(16),
          child: _ActionButtons(
            // Sin ubicación no hay a dónde llevar el mapa: el botón se
            // oculta en vez de no hacer nada.
            onViewOnMap: moment.location == null
                ? null
                : () => _viewOnMap(context, ref, moment),
            onEdit: () => context.push(AppRoutes.editMoment(momentId)),
            onDelete: () => _confirmDelete(context, ref),
          ),
        ),
        _ => null,
      },
    );
  }

  /// Pide al mapa que se centre aquí y cambia a su pestaña. `go` (no
  /// `push`) porque el mapa ya existe en el shell: queremos ir a él, no
  /// apilar otro mapa encima.
  void _viewOnMap(BuildContext context, WidgetRef ref, Moment moment) {
    ref.read(mapFocusRequestProvider.notifier).point = moment.location;
    context.go(AppRoutes.heatMap);
  }

  /// Borrar no se puede deshacer, así que se confirma. El botón destructivo
  /// dice exactamente lo que hace ("Borrar", no "Aceptar").
  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final colors = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          title: const Text('¿Borrar este momento?'),
          content: const Text(
            'Se quitará de tu lista y del mapa. No se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colors.error,
                foregroundColor: colors.onError,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Borrar'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) return;

    await ref.read(momentActionsProvider).delete(momentId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Momento borrado')));
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.moments);
    }
  }
}

class _MomentView extends StatelessWidget {
  const new(this.moment, {required this.onCorrectEmotion});

  final Moment moment;
  final ValueChanged<Emotion> onCorrectEmotion;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: PhotoCarousel(
            images: moment.photos.map((photo) => photo.image).toList(),
          ),
        ),
        const SizedBox(height: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Row(
              spacing: 12,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    moment.placeName,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (moment.sentiment case final sentiment?)
                  EmotionChip(emotion: sentiment.emotion),
              ],
            ),
            Text(
              moment.createdAt.toHumanReadable(),
              style: textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              moment.note,
              style: textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
            if (moment.sentiment case final sentiment?)
              _SentimentInfo(
                sentiment,
                onCorrect: () async {
                  final emotion = await showModalBottomSheet<Emotion>(
                    context: context,
                    showDragHandle: true,
                    builder: (_) => _EmotionPicker(current: sentiment.emotion),
                  );
                  if (emotion != null) onCorrectEmotion(emotion);
                },
              ),
          ],
        ),
      ],
    );
  }
}

/// Explica qué emoción detectó la IA (o si el usuario la corrigió), y deja
/// corregirla: la IA se equivoca, y el usuario debe tener la última palabra.
class _SentimentInfo extends StatelessWidget {
  const new(this.sentiment, {required this.onCorrect});

  final Sentiment sentiment;
  final VoidCallback onCorrect;

  @override
  Widget build(BuildContext context) {
    final emotion = sentiment.emotion;
    final text = sentiment.correctedByUser
        ? 'Corregiste la emoción a ${emotion.label}'
        : 'La IA detectó ${emotion.label} con un '
              '${(sentiment.confidence * 100).round()}% de confianza';

    final emotions = EmotionColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
      decoration: BoxDecoration(
        color: emotions.fill(emotion).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        spacing: 10,
        children: [
          Icon(
            sentiment.correctedByUser
                ? Icons.edit_note
                : Icons.auto_awesome_outlined,
            color: emotions.label(emotion),
            size: 20,
          ),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodyMedium?.copyWith(
                color: emotions.label(emotion),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: onCorrect,
            style: TextButton.styleFrom(
              foregroundColor: emotions.label(emotion),
            ),
            child: Text(sentiment.correctedByUser ? 'Cambiar' : 'Corregir'),
          ),
        ],
      ),
    );
  }
}

/// Hoja para elegir la emoción correcta. Devuelve la elegida con
/// `Navigator.pop`, o `null` si se cierra sin elegir.
class _EmotionPicker extends StatelessWidget {
  const new({required this.current});

  final Emotion current;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final emotions = EmotionColors.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Cómo te sentiste?', style: textTheme.titleLarge),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final emotion in Emotion.values)
                  ChoiceChip(
                    label: Text(emotion.label),
                    selected: emotion == current,
                    avatar: CircleAvatar(
                      backgroundColor: emotions.fill(emotion),
                    ),
                    showCheckmark: false,
                    onSelected: (_) => Navigator.pop(context, emotion),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const new({
    required this.onViewOnMap,
    required this.onEdit,
    required this.onDelete,
  });

  /// `null` oculta el botón (el momento no tiene ubicación).
  final VoidCallback? onViewOnMap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final onViewOnMap = this.onViewOnMap;
    return Row(
      spacing: 10,
      children: [
        if (onViewOnMap != null)
          Expanded(
            child: _ActionTile(
              icon: Icons.map_outlined,
              label: 'Ver en mapa',
              onTap: onViewOnMap,
            ),
          ),
        Expanded(
          child: _ActionTile(
            icon: Icons.edit_outlined,
            label: 'Editar',
            onTap: onEdit,
          ),
        ),
        Expanded(
          child: _ActionTile(
            icon: Icons.delete_outline,
            label: 'Borrar',
            onTap: onDelete,
            isDestructive: true, // fondo rojo claro y texto rojo
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const new({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final background = isDestructive
        ? colors.errorContainer
        : colors.surfaceContainerLow;
    final iconColor = isDestructive ? colors.error : colors.primary;
    final textColor = isDestructive ? colors.error : colors.onSurface;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(18),
      // Recorta el efecto al tocar a las esquinas redondeadas.
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          // minHeight (no height fijo): con letra grande el texto crece y
          // el botón con él, en vez de cortarse.
          constraints: const BoxConstraints(minHeight: 72),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              // min: sin esto la columna ocupa todo el alto que le dejen, y
              // como bottomNavigationBar recibe hasta la pantalla entera,
              // los botones taparían el contenido.
              mainAxisSize: MainAxisSize.min,
              spacing: 6,
              children: [
                Icon(icon, color: iconColor, size: 22),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
