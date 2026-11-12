import 'package:flutter/material.dart';
import 'package:kumo/core/widget/kumo_sheet.dart';
import 'package:kumo/features/heat_map/domain/entities/emotion_zone.dart';

/// Hoja inferior con el resumen de una zona (boceto 5). Es persistente:
/// vive encima del mapa en un `Stack`, se arrastra entre alturas y deja
/// mover el mapa detrás.
class ZoneSummarySheet extends StatelessWidget {
  const new({required this.zone, this.controller, super.key});

  final EmotionZone zone;

  /// Para subirla o bajarla por código (p. ej. al tocar otra zona).
  final DraggableScrollableController? controller;

  @override
  Widget build(BuildContext context) {
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
              _header(context),
              const SizedBox(height: 18),
              _SectionTitle(
                'Cómo se siente la gente aquí ${zone.moments.map(
                  (e) => e.note,
                )}',
              ),
              const SizedBox(height: 10),
              _emotionBreakdown(context),
              const SizedBox(height: 18),
              const _SectionTitle('Lugares destacados'),
              const SizedBox(height: 4),
              _topPlaces(context),
            ],
          ),
        );
      },
    );
  }

  /// Nombre de la zona, "N momentos · últimos 7 días" y el chip de la
  /// emoción dominante (zone.dominant).
  Widget _header(BuildContext context) {
    return const SizedBox.shrink();
  }

  /// Barra con el reparto (zone.breakdown) y su leyenda en dos columnas.
  Widget _emotionBreakdown(BuildContext context) {
    return const SizedBox.shrink();
  }

  /// Lugares de la zona agrupando zone.moments por placeName, con su
  /// emoción y número de momentos. Al tocar uno irá al detalle del lugar.
  Widget   _topPlaces(BuildContext context) {
    return const SizedBox.shrink();
  }
}

/// Título de sección del boceto: 13 px, negrita, mayúsculas.
class _SectionTitle extends StatelessWidget {
  const new(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: Color(0xFF3C3F4E),
      ),
    );
  }
}
