import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kumo/features/moments/domain/entities/moment.dart';
import 'package:kumo/features/moments/domain/entities/sentiment.dart';
import 'package:kumo/features/moments/presentation/providers/moments_providers.dart';

/// Acciones sobre un momento ya guardado: borrar y corregir su emoción.
///
/// Vive en un provider para que las pantallas no hablen directo con el
/// repositorio, y para que después de cada cambio se invaliden los
/// providers correctos (lista, detalle y, en cadena, el mapa).
final momentActionsProvider = Provider<MomentActions>(MomentActions.new);

class MomentActions {
  const new(this._ref);

  final Ref _ref;

  Future<void> delete(String id) async {
    await _ref.read(momentsRepositoryProvider).deleteMoment(id);
    _refresh(id);
  }

  /// El usuario dice que la IA se equivocó. Si el momento aún no tiene
  /// emoción (pendiente de análisis), no hay nada que corregir.
  Future<void> correctEmotion(Moment moment, Emotion emotion) async {
    final sentiment = moment.sentiment;
    if (sentiment == null || sentiment.emotion == emotion) return;
    await _ref
        .read(momentsRepositoryProvider)
        .saveMoment(moment.copyWith(sentiment: sentiment.correctTo(emotion)));
    _refresh(moment.id);
  }

  /// `momentsProvider` arrastra al mapa: sus providers dependen de él.
  void _refresh(String id) => _ref
    ..invalidate(momentsProvider)
    ..invalidate(momentByIdProvider(id));
}
