import 'package:flutter/material.dart';
import 'package:kumo/core/widget/kumo_sheet.dart';
import 'package:kumo/core/widget/photo_placeholder.dart';
import 'package:kumo/core/widget/section_title.dart';
import 'package:kumo/features/heat_map/domain/entities/emotion_zone.dart';
import 'package:kumo/features/heat_map/presentation/widgets/emotion_breakdown.dart';
import 'package:kumo/features/moments/domain/entities/sentiment.dart';
import 'package:kumo/features/moments/presentation/extensions/emotion_style.dart';
import 'package:kumo/features/moments/presentation/extensions/moment_photo_image.dart';

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
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
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
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '$count ${count == 1 ? 'momento' : 'momentos'}',
                style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant),
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
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: emotion.color.withValues(alpha: 0.2),
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
              color: emotion.color,
              shape: BoxShape.circle,
            ),
          ),
          Text(
            emotion.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: emotion.labelColor,
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
    final count = place.momentCount;
    final cover = place.cover;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(top: BorderSide(color: Color(0xFFEEF0F5)))
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
                      ? const ColoredBox(color: Color(0xFFD5D8E8))
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${place.dominant.label} · $count '
                      '${count == 1 ? 'momento' : 'momentos'}',
                      style: TextStyle(
                        fontSize: 14,
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
