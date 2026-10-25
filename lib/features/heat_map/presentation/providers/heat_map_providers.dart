import 'package:flutter_riverpod/flutter_riverpod.dart';
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


final emotionZoneBuilderProvider = Provider<EmotionZoneBuilder>(
  (ref) => const EmotionZoneBuilder(),
);

final emotionZonesProvider = FutureProvider<List<EmotionZone>>((ref) async {
  final moments = await ref.watch(mapMomentsProvider.future);
  return ref.watch(emotionZoneBuilderProvider).build(moments);
});
