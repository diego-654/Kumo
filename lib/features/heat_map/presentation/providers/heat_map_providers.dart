import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:kumo/features/heat_map/domain/entities/emotion_zone.dart';
import 'package:kumo/features/heat_map/domain/services/emotion_zone_builder.dart';
import 'package:kumo/features/moments/domain/entities/moment.dart';
import 'package:kumo/features/moments/presentation/providers/moments_providers.dart';

final mapMomentsProvider = FutureProvider<List<Moment>>((ref) async {
  final moments = await ref.watch(momentsProvider.future);
  return moments
      .where((m) => m.isPublic && m.location != null && m.sentiment != null)
      .toList();
});

/// Momentos públicos de un lugar, del más reciente al más antiguo (boceto
/// 6). Por ahora el lugar se identifica por su nombre: no hay entidad
/// `Place` con id propio todavía.
final FutureProviderFamily<List<Moment>, String> placeMomentsProvider =
    FutureProvider.family<List<Moment>, String>((ref, placeName) async {
      final moments = await ref.watch(mapMomentsProvider.future);
      return moments.where((m) => m.placeName == placeName).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });

/// Zonas para un tamaño de celda. Riverpod guarda cada tamaño en caché,
/// así que al volver a un zoom ya visitado no recalcula.
final FutureProviderFamily<List<EmotionZone>, double> emotionZonesProvider =
    FutureProvider.family<List<EmotionZone>, double>((ref, cellSize) async {
      final moments = await ref.watch(mapMomentsProvider.future);
      return EmotionZoneBuilder(cellSizeDegrees: cellSize).build(moments);
    });

/// Zoom 15 → 0.003° (~330 m). Cada nivel que te alejas, el doble.
/// Mínimo ~165 m, máximo ~2.6 km.
double cellSizeForZoom(int zoom) =>
    (0.003 * pow(2, 15 - zoom)).clamp(0.0015, 0.024);

/// La zona que el usuario tocó; `null` = ninguna (la hoja no se muestra).
final selectedZoneProvider =
    NotifierProvider<SelectedZoneNotifier, EmotionZone?>(
      SelectedZoneNotifier.new,
    );

class SelectedZoneNotifier extends Notifier<EmotionZone?> {
  @override
  EmotionZone? build() => null;

  void select(EmotionZone? zone) => state = zone;
}
