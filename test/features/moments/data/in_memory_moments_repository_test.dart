import 'package:flutter_test/flutter_test.dart';
import 'package:kumo/features/moments/data/repositories/in_memory_moments_repository.dart';
import 'package:kumo/features/moments/domain/entities/moment.dart';

void main() {
  group(InMemoryMomentsRepository, () {
    test('devuelve los momentos del más reciente al más antiguo', () async {
      final repository = InMemoryMomentsRepository(seed: []);
      final older = Moment(
        id: '1',
        placeName: 'Café Central',
        note: 'Tranquilo',
        createdAt: DateTime(2026),
      );
      final newer = Moment(
        id: '2',
        placeName: 'Taquería',
        note: 'Feliz',
        createdAt: DateTime(2026, 2),
      );

      await repository.saveMoment(older);
      await repository.saveMoment(newer);

      expect(await repository.getMoments(), [newer, older]);
    });

    test('saveMoment reemplaza el momento si el id ya existe', () async {
      final original = Moment(
        id: '1',
        placeName: 'Café Central',
        note: 'Tranquilo',
        createdAt: DateTime(2026),
      );
      final repository = InMemoryMomentsRepository(seed: [original]);
      final edited = original.copyWith(note: 'Lleno de gente');

      await repository.saveMoment(edited);

      expect(await repository.getMoments(), [edited]);
    });
  });
}
