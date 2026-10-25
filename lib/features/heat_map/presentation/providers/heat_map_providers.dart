import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumo/features/moments/domain/entities/moment.dart';
import 'package:kumo/features/moments/presentation/providers/moments_providers.dart';

final mapMomentsProvider = FutureProvider<List<Moment>>((ref) async {
  final moments = await ref.watch(momentsProvider.future);
  return moments
      .where((m) => m.isPublic && m.location != null && m.sentiment != null)
      .toList();
});
