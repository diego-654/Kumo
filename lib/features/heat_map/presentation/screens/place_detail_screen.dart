import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kumo/app/router/app_routes.dart';
import 'package:kumo/core/extensions/date_time_extensions.dart';
import 'package:kumo/core/widget/photo_carousel.dart';
import 'package:kumo/core/widget/photo_placeholder.dart';
import 'package:kumo/features/heat_map/presentation/providers/heat_map_providers.dart';
import 'package:kumo/features/moments/domain/entities/moment.dart';
import 'package:kumo/features/moments/domain/entities/sentiment.dart';
import 'package:kumo/features/moments/presentation/extensions/emotion_style.dart';
import 'package:kumo/features/moments/presentation/extensions/moment_photo_image.dart';
import 'package:material_ui/material_ui.dart';

/// Detalle de un lugar (boceto 6): fotos, cómo se siente la gente ahí y
/// sus momentos. Se abre al tocar un lugar en la hoja de la zona.
class PlaceDetailScreen extends ConsumerWidget {
  const new({required this.placeName, super.key});

  final String placeName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final momentsAsync = ref.watch(placeMomentsProvider(placeName));

    return Scaffold(
      body: momentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (moments) => moments.isEmpty
            ? const Center(child: Text('Aún no hay momentos públicos aquí'))
            : _PlaceView(name: placeName, moments: moments),
      ),
      // Fijo al fondo, como en el boceto.
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: SizedBox(
          height: 56,
          child: FilledButton(
            onPressed: () => context.push(AppRoutes.newMoment),
            style: FilledButton.styleFrom(
              shape: const StadiumBorder(),
              textStyle: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Text('Registrar mi momento aquí'),
          ),
        ),
      ),
    );
  }
}

enum _Tab { momentos, fotos }

class _PlaceView extends StatefulWidget {
  const new({required this.name, required this.moments});

  final String name;

  /// Nunca vacía: la pantalla muestra otro mensaje en ese caso.
  final List<Moment> moments;

  @override
  State<_PlaceView> createState() => _PlaceViewState();
}

class _PlaceViewState extends State<_PlaceView> {
  _Tab _tab = _Tab.momentos;

  @override
  Widget build(BuildContext context) {
    final moments = widget.moments;
    final photos = [
      for (final moment in moments)
        for (final photo in moment.photos) photo.image,
    ];
    final count = moments.length;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _PhotoHeader(photos: photos),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 18,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 6,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  // Sin categoría ni distancia todavía: solo lo que hay.
                  Text(
                    '$count ${count == 1 ? 'momento' : 'momentos'}',
                    style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              _FeelingCard(
                emotion: _dominantOf(moments),
                momentCount: count,
              ),
              Row(
                spacing: 8,
                children: [
                  _TabPill(
                    label: 'Momentos',
                    selected: _tab == _Tab.momentos,
                    onTap: () => setState(() => _tab = _Tab.momentos),
                  ),
                  _TabPill(
                    label: 'Fotos',
                    selected: _tab == _Tab.fotos,
                    onTap: () => setState(() => _tab = _Tab.fotos),
                  ),
                ],
              ),
              switch (_tab) {
                _Tab.momentos => Column(
                  spacing: 12,
                  children: [
                    for (final moment in moments)
                      _MomentRow(
                        moment: moment,
                        onTap: () =>
                            context.push(AppRoutes.momentDetail(moment.id)),
                      ),
                  ],
                ),
                _Tab.fotos => _PhotoGrid(photos: photos),
              },
            ],
          ),
        ),
      ],
    );
  }

  /// La emoción que más se repite. En el mapa todos los momentos tienen
  /// sentimiento, así que siempre hay al menos una.
  static Emotion _dominantOf(List<Moment> moments) {
    final counts = <Emotion, int>{};
    for (final sentiment in moments.map((m) => m.sentiment).nonNulls) {
      counts.update(sentiment.emotion, (n) => n + 1, ifAbsent: () => 1);
    }
    return counts.entries.reduce((a, b) => b.value > a.value ? b : a).key;
  }
}

/// Fotos arriba a todo el ancho, con el botón de volver encima.
class _PhotoHeader extends StatelessWidget {
  const new({required this.photos});

  final List<ImageProvider> photos;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;

    return Stack(
      children: [
        if (photos.isEmpty)
          SizedBox(height: 250 + top, child: const PhotoPlaceholder())
        else
          Padding(
            padding: EdgeInsets.only(top: top),
            child: PhotoCarousel(images: photos),
          ),
        Positioned(
          left: 16,
          top: top + 12,
          child: Material(
            color: Colors.white,
            shape: const CircleBorder(),
            elevation: 2,
            child: IconButton(
              tooltip: 'Volver',
              icon: const Icon(Icons.chevron_left_rounded),
              onPressed: () => context.pop(),
            ),
          ),
        ),
      ],
    );
  }
}

/// Tarjeta "La gente se siente alegre aquí" con el color de la emoción.
class _FeelingCard extends StatelessWidget {
  const new({required this.emotion, required this.momentCount});

  final Emotion emotion;
  final int momentCount;

  String get _phrase => switch (emotion) {
    Emotion.alegria => 'La gente se siente alegre aquí',
    Emotion.calma => 'La gente se siente tranquila aquí',
    Emotion.nostalgia => 'La gente se siente nostálgica aquí',
    Emotion.tristeza => 'La gente se siente triste aquí',
    Emotion.enojo => 'La gente se siente molesta aquí',
    Emotion.miedo => 'La gente siente miedo aquí',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: emotion.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        spacing: 12,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: emotion.color,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  _phrase,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Según $momentCount '
                  '${momentCount == 1 ? 'momento' : 'momentos'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Pestaña en forma de pastilla: rellena si está elegida, con borde si no.
class _TabPill extends StatelessWidget {
  const new({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      height: 36,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          backgroundColor: selected ? colors.onSurface : colors.surface,
          foregroundColor: selected ? colors.surface : colors.onSurface,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          shape: StadiumBorder(
            side: selected
                ? BorderSide.none
                : BorderSide(color: colors.outlineVariant, width: 1.5),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

/// Un momento del lugar: avatar, "cuándo · emoción" y su nota.
class _MomentRow extends StatelessWidget {
  const new({required this.moment, required this.onTap});

  final Moment moment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final emotion = moment.sentiment?.emotion;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          // Aún no hay usuarios: avatar genérico.
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFDDE0FA),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(
                  [
                    moment.createdAt.toHumanReadable(),
                    if (emotion != null) emotion.label,
                  ].join(' · '),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                Text(
                  moment.note,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: Color(0xFF3C3F4E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Todas las fotos del lugar en una cuadrícula de 3 columnas.
class _PhotoGrid extends StatelessWidget {
  const new({required this.photos});

  final List<ImageProvider> photos;

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return const Text('Aún no hay fotos de este lugar');
    }
    return GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
      // Va dentro del ListView de la pantalla: no hace scroll propio.
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (final photo in photos)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image(
              image: photo,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const PhotoPlaceholder(),
            ),
          ),
      ],
    );
  }
}
