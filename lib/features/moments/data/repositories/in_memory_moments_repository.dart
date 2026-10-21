import 'package:kumo/features/moments/domain/entities/moment.dart';
import 'package:kumo/features/moments/domain/repositories/moments_repository.dart';

/// Implementación temporal en memoria. Se sustituirá por una con backend
/// sin tocar dominio ni presentación: solo cambia el provider.
class InMemoryMomentsRepository implements MomentsRepository {
  final List<Moment> _moments = [];

  @override
  Future<List<Moment>> getMoments() async {
    final sorted = [..._moments]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(sorted);
  }

  @override
  Future<void> addMoment(Moment moment) async {
    _moments.add(moment);
  }
}
