import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kumo/app/router/app_routes.dart';
import 'package:kumo/core/extensions/date_time_extensions.dart';
import 'package:kumo/core/widget/photo_carousel.dart';
import 'package:kumo/features/moments/domain/entities/moment.dart';
import 'package:kumo/features/moments/domain/entities/sentiment.dart';
import 'package:kumo/features/moments/presentation/extensions/emotion_style.dart';
import 'package:kumo/features/moments/presentation/extensions/moment_photo_image.dart';
import 'package:kumo/features/moments/presentation/providers/moments_providers.dart';
import 'package:kumo/features/moments/presentation/widgets/emotion_chip.dart';

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
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (moment) => moment == null
            ? const Center(child: Text('Este momento ya no existe'))
            : _MomentView(moment),
      ),
      // Fijos al fondo; solo cuando el momento existe.
      bottomNavigationBar: switch (momentAsync) {
        AsyncData(value: final _?) => SafeArea(
          minimum: const EdgeInsets.all(16),
          child: _ActionButtons(
            onViewOnMap: () => context.push(AppRoutes.newMoment),
            onEdit: () => context.push(AppRoutes.editMoment(momentId)),
            onDelete: () {},
          ),
        ),
        _ => null,
      },
    );
  }
}

class _MomentView extends StatelessWidget {
  const new(this.moment);

  final Moment moment;

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
              _SentimentInfo(sentiment),
          ],
        ),
      ],
    );
  }
}

/// Explica qué emoción detectó la IA (o si el usuario la corrigió).
class _SentimentInfo extends StatelessWidget {
  const new(this.sentiment);

  final Sentiment sentiment;

  @override
  Widget build(BuildContext context) {
    final emotion = sentiment.emotion;
    final text = sentiment.correctedByUser
        ? 'Corregiste la emoción a ${emotion.label}'
        : 'La IA detectó ${emotion.label} con un '
              '${(sentiment.confidence * 100).round()}% de confianza';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: emotion.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        spacing: 10,
        children: [
          Icon(
            sentiment.correctedByUser
                ? Icons.edit_note
                : Icons.auto_awesome_outlined,
            color: emotion.labelColor,
            size: 20,
          ),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: emotion.labelColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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

  final VoidCallback onViewOnMap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
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
    final colors = Theme.of(context).colorScheme;
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
        child: SizedBox(
          height: 72,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 6,
            children: [
              Icon(icon, color: iconColor, size: 22),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
