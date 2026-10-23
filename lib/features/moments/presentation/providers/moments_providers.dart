import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:kumo/features/moments/data/repositories/in_memory_moments_repository.dart';
import 'package:kumo/features/moments/domain/entities/moment.dart';
import 'package:kumo/features/moments/domain/repositories/moments_repository.dart';

/// Punto único de inyección de dependencias del repositorio.
/// En tests se sobrescribe con `momentsRepositoryProvider.overrideWithValue`.
final momentsRepositoryProvider = Provider<MomentsRepository>(
  (ref) => InMemoryMomentsRepository(),
);

final momentsProvider = FutureProvider<List<Moment>>(
  (ref) => ref.watch(momentsRepositoryProvider).getMoments(),
);

final FutureProviderFamily<Moment?, String> momentByIdProvider =
    FutureProvider.family<Moment?, String>(
      (ref, id) => ref.watch(momentsRepositoryProvider).getMomentById(id),
    );
