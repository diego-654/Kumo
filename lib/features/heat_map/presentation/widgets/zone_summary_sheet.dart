import 'package:kumo/core/theme/emotion_colors.dart';
import 'package:kumo/core/widget/kumo_sheet.dart';
import 'package:kumo/core/widget/photo_placeholder.dart';
import 'package:kumo/core/widget/section_title.dart';
import 'package:kumo/features/heat_map/domain/entities/emotion_zone.dart';
import 'package:kumo/features/heat_map/presentation/widgets/emotion_breakdown.dart';
import 'package:kumo/features/moments/domain/entities/sentiment.dart';
import 'package:kumo/features/moments/presentation/extensions/emotion_style.dart';
import 'package:kumo/features/moments/presentation/extensions/moment_photo_image.dart';
import 'package:material_ui/material_ui.dart';

/// Hoja inferior con el resumen de una zona (boceto 5). Es persistente:
/// vive encima del mapa en un `Stack`, se arrastra entre alturas y deja
/// mover el mapa detrás.
class ZoneSummarySheet extends StatelessWidget {
  const new({
    required this.zone,
    this.controller,
    this.onPlaceTap,
    super.key,
  });

  final EmotionZone zone;

  /// Para subirla o bajarla por código (p. ej. al tocar otra zona).
  final DraggableScrollableController? controller;

  /// Se llama con el nombre del lugar tocado. Aquí se conectará el
  /// detalle del lugar (boceto 6).
  final ValueChanged<String>? onPlaceTap;

  @override
  Widget build(BuildContext context) {
    // Se calcula una vez por build y se comparte entre cabecera y lista.
    final places = zone.places;
    final onPlaceTap = this.onPlaceTap;

    return DraggableScrollableSheet(
      controller: controller,
      initialChildSize: 0.3,
      minChildSize: 0.15,
      maxChildSize: 0.9,
      snap: true,
      snapSizes: const [0.3, 0.6],
      builder: (context, scrollController) {
        return KumoSheetSurface(
          child: ListView(
            controller: scrollController,
            // La hoja baja hasta el borde y la barra flota encima. El
            // padding inferior deja que lo último de la lista suba por
            // encima de la barra al hacer scroll.
            padding: EdgeInsets.fromLTRB(
              20,
              0,
              20,
              28 + MediaQuery.paddingOf(context).bottom,
            ),
            children: [
              const KumoSheetHandle(),
              _ZoneHeader(zone: zone, places: places),
              const SizedBox(height: 18),
              const SectionTitle('Cómo se siente la gente aquí'),
              const SizedBox(height: 10),
              EmotionBreakdown(breakdown: zone.breakdown),
              const SizedBox(height: 18),
              const SectionTitle('Lugares destacados'),
              const SizedBox(height: 4),
              for (final (i, place) in places.indexed)
                _PlaceTile(
                  place: place,
                  showDivider: i > 0,
                  onTap: onPlaceTap == null
                      ? null
                      : () => onPlaceTap(place.name),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Nombre de la zona, número de momentos y la emoción dominante.
class _ZoneHeader extends StatelessWidget {
  const new({required this.zone, required this.places});

  final EmotionZone zone;
  final List<ZonePlace> places;

  @override
  Widget build(BuildContext context) {
    // Sin geocodificación inversa todavía: la zona se nombra por su
    // lugar con más momentos.
    final title = places.isEmpty
        ? 'Esta zona'
        : 'Cerca de ${places.first.name}';
    final count = zone.momentCount;
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                    Theme.of(
                          context,
                        ).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
              ),
              Text(
                '$count ${count == 1 ? 'momento' : 'momentos'}',
                style:
                    Theme.of(
                          context,
                        ).textTheme.bodyMedium
                        ?.copyWith(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _DominantBadge(zone.dominant),
      ],
    );
  }
}

/// Pastilla de 32 px con punto de color: la emoción dominante de la zona.
/// Es más grande que `EmotionChip` porque aquí es el dato principal.
class _DominantBadge extends StatelessWidget {
  const new(this.emotion);

  final Emotion emotion;

  @override
  Widget build(BuildContext context) {
    final emotions = EmotionColors.of(context);
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: emotions.fill(emotion).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: emotions.fill(emotion),
              shape: BoxShape.circle,
            ),
          ),
          Text(
            emotion.label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: emotions.label(emotion),
            ),
          ),
        ],
      ),
    );
  }
}

/// Fila de un lugar: foto, nombre, "Emoción · N momentos" y flecha. Las
/// filas después de la primera llevan una línea arriba ([showDivider]).
class _PlaceTile extends StatelessWidget {
  const new({required this.place, this.showDivider = false, this.onTap});

  final ZonePlace place;
  final bool showDivider;
  final VoidCallback? onTap;

  static const double _thumbSize = 52;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final count = place.momentCount;
    final cover = place.cover;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: showDivider
            ? Border(top: BorderSide(color: colors.outlineVariant))
            : null,
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            spacing: 12,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox.square(
                  dimension: _thumbSize,
                  child: cover == null
                      ? ColoredBox(color: colors.surfaceContainerHighest)
                      : Image(
                          image: cover.image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const PhotoPlaceholder(),
                        ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      place.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${place.dominant.label} · $count '
                      '${count == 1 ? 'momento' : 'momentos'}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right_rounded,
                  color: colors.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
