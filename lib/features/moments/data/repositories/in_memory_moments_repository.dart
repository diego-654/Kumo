import 'package:kumo/features/moments/domain/entities/moment.dart';
import 'package:kumo/features/moments/domain/entities/moment_photo.dart';
import 'package:kumo/features/moments/domain/entities/sentiment.dart';
import 'package:kumo/features/moments/domain/repositories/moments_repository.dart';

/// Implementación temporal en memoria. Se sustituirá por una con backend
/// sin tocar dominio ni presentación: solo cambia el provider.
///
/// Arranca con [_sampleMoments] para ver la UI con datos. En los tests
/// se pasa `seed: []` para empezar vacío.
class InMemoryMomentsRepository implements MomentsRepository {
  InMemoryMomentsRepository({List<Moment>? seed})
    : _moments = [...(seed ?? _sampleMoments)];

  final List<Moment> _moments;

  static final List<Moment> _sampleMoments = [
    Moment(
      id: '1',
      placeName: 'Café Central',
      note: 'Tranquilo y acogedor, perfecto para leer un rato',
      createdAt: DateTime(2026, 10, 20, 9, 30),
      photos: const [
        MomentPhoto(id: 'p1', remoteUrl: 'https://picsum.photos/id/3/800/533'),
        MomentPhoto(id: 'p2', remoteUrl: 'https://picsum.photos/id/10/800/533'),
        MomentPhoto(id: 'p3', remoteUrl: 'https://picsum.photos/id/20/800/533'),
      ],
      sentiment: const Sentiment(emotion: Emotion.calma, confidence: 0.91),
    ),
    Moment(
      id: '2',
      placeName: 'Taquería El Güero',
      note: 'Feliz, con amigos y los mejores tacos al pastor',
      createdAt: DateTime(2026, 10, 21, 21, 15),
      photos: const [
        MomentPhoto(id: 'p4', remoteUrl: 'https://picsum.photos/id/42/800/533'),
        MomentPhoto(id: 'p5', remoteUrl: 'https://picsum.photos/id/48/800/533'),
      ],
      sentiment: const Sentiment(emotion: Emotion.alegria, confidence: 0.95),
    ),
    Moment(
      id: '3',
      placeName: 'Parque de la infancia',
      note: 'Volví al parque donde jugaba de niño, me trajo muchos recuerdos',
      createdAt: DateTime(2026, 10, 18, 17, 45),
      photos: const [
        MomentPhoto(id: 'p6', remoteUrl: 'https://picsum.photos/id/28/800/533'),
      ],
      sentiment: const Sentiment(emotion: Emotion.nostalgia, confidence: 0.82),
    ),
    Moment(
      id: '4',
      placeName: 'Estación de tren',
      note: 'Despedí a mi hermana, se va a vivir a otra ciudad',
      createdAt: DateTime(2026, 10, 15, 7, 10),
      photos: const [
        MomentPhoto(id: 'p7', remoteUrl: 'https://picsum.photos/id/57/800/533'),
        MomentPhoto(id: 'p8', remoteUrl: 'https://picsum.photos/id/58/800/533'),
      ],
      // La IA dijo nostalgia (poca confianza) y el usuario lo corrigió.
      sentiment: const Sentiment(
        emotion: Emotion.tristeza,
        confidence: 0.54,
        correctedByUser: true,
      ),
    ),
    Moment(
      id: '5',
      placeName: 'Avenida Principal',
      note: 'Dos horas atrapado en el tráfico, llegué tarde a todo',
      createdAt: DateTime(2026, 10, 22, 8, 50),
      photos: const [
        MomentPhoto(id: 'p9', remoteUrl: 'https://picsum.photos/id/76/800/533'),
      ],
      sentiment: const Sentiment(emotion: Emotion.enojo, confidence: 0.88),
    ),
  ];

  // TODO: paginar por cursor cuando haya backend.
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

  @override
  Future<Moment?> getMomentById(String id) async {
    return _moments.where((moment) => moment.id == id).firstOrNull;
  }
}
