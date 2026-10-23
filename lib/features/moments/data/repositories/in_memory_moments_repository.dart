import 'package:kumo/features/moments/domain/entities/moment.dart';
import 'package:kumo/features/moments/domain/entities/moment_photo.dart';
import 'package:kumo/features/moments/domain/repositories/moments_repository.dart';

/// Implementación temporal en memoria. Se sustituirá por una con backend
/// sin tocar dominio ni presentación: solo cambia el provider.
///
/// Arranca con [_sampleMoments] para ver la UI con datos. En los tests
/// se pasa `seed: []` para empezar vacío.
class InMemoryMomentsRepository implements MomentsRepository {
  new({List<Moment>? seed}) : _moments = [...(seed ?? _sampleMoments)];

  final List<Moment> _moments;

  static final List<Moment> _sampleMoments = [
    Moment(
      id: '1',
      placeName: 'Café Central',
      note: 'Tranquilo y acogedor',
      createdAt: DateTime(2026, 10, 20),
      photos: const [
        MomentPhoto(id: 'p1', remoteUrl: 'https://picsum.photos/id/3/800/533'),
        MomentPhoto(id: 'p2', remoteUrl: 'https://picsum.photos/id/10/800/533'),
        MomentPhoto(id: 'p3', remoteUrl: 'https://picsum.photos/id/20/800/533'),
      ],
    ),
    Moment(
      id: '2',
      placeName: 'Taquería El Güero',
      note: 'Feliz, con amigos',
      createdAt: DateTime(2026, 10, 21),
      photos: const [
        MomentPhoto(id: 'p4', remoteUrl: 'https://picsum.photos/id/42/800/533'),
        MomentPhoto(id: 'p5', remoteUrl: 'https://picsum.photos/id/48/800/533'),
      ],
    ),
  ];

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
